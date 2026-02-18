#!/bin/bash

# Stop on any error
set -e

# Configuration - Replace with your GCP project details
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1" # Or your preferred region
API_SERVICE_NAME="genbalink-api"
WORKER_SERVICE_NAME="genbalink-worker"
REPOSITORY="genbalink-repo"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No GCP project ID found. Please set your project using 'gcloud config set project [PROJECT_ID]'"
    exit 1
fi

echo "Deploying GenbaLink Backend to Project: $PROJECT_ID in Region: $REGION"

# 1. Enable Required APIs
echo "Enabling necessary GCP APIs..."
gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    pubsub.googleapis.com \
    firestore.googleapis.com \
    cloudbuild.googleapis.com

# 2. Create Artifact Registry if it doesn't exist
echo "Setting up Artifact Registry..."
if ! gcloud artifacts repositories describe $REPOSITORY --location=$REGION > /dev/null 2>&1; then
    gcloud artifacts repositories create $REPOSITORY \
        --repository-format=docker \
        --location=$REGION \
        --description="GenbaLink Docker Repository"
fi

# 3. Create Pub/Sub Topics and Subscriptions (if they don't exist)
echo "Setting up Pub/Sub topics and subscriptions..."
gcloud pubsub topics create inventory-low 2>/dev/null || true
gcloud pubsub topics create high-demand 2>/dev/null || true
gcloud pubsub subscriptions create inventory-low-sub --topic=inventory-low 2>/dev/null || true
gcloud pubsub subscriptions create high-demand-sub --topic=high-demand 2>/dev/null || true

# 4. Build both images using Cloud Build in one go
echo "Building API and Worker images via Cloud Build..."
API_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$API_SERVICE_NAME:latest"
WORKER_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$WORKER_SERVICE_NAME:latest"

cat > cloudbuild.yaml <<EOF
steps:
# Build API
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '$API_IMAGE', '-f', 'Dockerfile', '.']
# Build Worker
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '$WORKER_IMAGE', '-f', 'Dockerfile.worker', '.']
images:
- '$API_IMAGE'
- '$WORKER_IMAGE'
EOF

gcloud builds submit --config cloudbuild.yaml .
rm cloudbuild.yaml

# 5. Deploy API to Cloud Run
echo "Deploying API to Cloud Run..."
gcloud run deploy $API_SERVICE_NAME \
    --image $API_IMAGE \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --timeout 300 \
    --set-env-vars "Firestore__ProjectId=$PROJECT_ID,PubSub__ProjectId=$PROJECT_ID,PubSub__InventoryTopicId=inventory-low,PubSub__DemandTopicId=high-demand"

# 6. Deploy Worker to Cloud Run
echo "Deploying Worker to Cloud Run..."
gcloud run deploy $WORKER_SERVICE_NAME \
    --image $WORKER_IMAGE \
    --region $REGION \
    --platform managed \
    --no-allow-unauthenticated \
    --no-cpu-throttling \
    --min-instances 1 \
    --timeout 300 \
    --set-env-vars "Firestore__ProjectId=$PROJECT_ID,PubSub__ProjectId=$PROJECT_ID,PubSub__InventorySubscriptionId=inventory-low-sub,PubSub__DemandSubscriptionId=high-demand-sub"

echo "Deployment Complete!"
echo "API URL: $(gcloud run services describe $API_SERVICE_NAME --region $REGION --format='value(status.url)')"
