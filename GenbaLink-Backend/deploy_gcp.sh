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
    firestore.googleapis.com

# 1a. Grant IAM Permissions to Default Service Account
echo "Ensuring service account has necessary permissions..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
SERVICE_ACCOUNT="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"

echo "Granting Firestore and Pub/Sub roles to $SERVICE_ACCOUNT..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/datastore.user" --quiet > /dev/null

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/pubsub.publisher" --quiet > /dev/null

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/pubsub.subscriber" --quiet > /dev/null

# 2. Configure Docker Authentication (Required for local push)
echo "Configuring Docker for Artifact Registry..."
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

# 3. Create Artifact Registry if it doesn't exist
echo "Setting up Artifact Registry..."
if ! gcloud artifacts repositories describe $REPOSITORY --location=$REGION > /dev/null 2>&1; then
    gcloud artifacts repositories create $REPOSITORY \
        --repository-format=docker \
        --location=$REGION \
        --description="GenbaLink Docker Repository"
fi

# 4. Create Pub/Sub Topics and Subscriptions (if they don't exist)
echo "Setting up Pub/Sub topics and subscriptions..."
gcloud pubsub topics create inventory-low 2>/dev/null || true
gcloud pubsub topics create high-demand 2>/dev/null || true
gcloud pubsub subscriptions create inventory-low-sub --topic=inventory-low 2>/dev/null || true
gcloud pubsub subscriptions create high-demand-sub --topic=high-demand 2>/dev/null || true

# 5. Build and Push images locally
API_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$API_SERVICE_NAME:latest"
WORKER_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$WORKER_SERVICE_NAME:latest"

echo "Building API image locally (forcing linux/amd64)..."
docker build --platform linux/amd64 -t "$API_IMAGE" -f Dockerfile .
echo "Pushing API image..."
docker push "$API_IMAGE"

echo "Building Worker image locally (forcing linux/amd64)..."
docker build --platform linux/amd64 -t "$WORKER_IMAGE" -f Dockerfile.worker .
echo "Pushing Worker image..."
docker push "$WORKER_IMAGE"

# 6. Deploy API to Cloud Run
echo "Deploying API to Cloud Run..."
gcloud run deploy $API_SERVICE_NAME \
    --image $API_IMAGE \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --timeout 300 \
    --set-env-vars "Firestore__ProjectId=$PROJECT_ID,PubSub__ProjectId=$PROJECT_ID,PubSub__InventoryTopicId=inventory-low,PubSub__DemandTopicId=high-demand"

# 7. Deploy Worker to Cloud Run
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
