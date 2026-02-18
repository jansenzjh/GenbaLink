# GenbaLink Backend: Cloud-Native Retail Intelligence

**GenbaLink** (from the Japanese word *Genba*, meaning "the actual place") is a high-performance retail intelligence backend designed to bridge the gap between the shop floor (stores) and supply chain logistics. 

Built with **.NET 9** and architected for **Google Cloud Platform (GCP)**, this system provides real-time demand signal aggregation and automated inventory intelligence through a decoupled, event-driven architecture.

---

## 🏗 System Architecture

GenbaLink is composed of two primary services that interact via managed GCP services, ensuring high scalability and zero-maintenance overhead.

1.  **GenbaLink.Api (Web API)**: The entry point for stores to submit demand batches and manage local inventory.
2.  **GenbaLink.Worker (Background Service)**: A decoupled consumer that processes real-time events and simulates warehouse fulfillment and logistics planning.
3.  **Google Cloud Firestore**: A serverless NoSQL document database providing real-time data synchronization.
4.  **Google Cloud Pub/Sub**: A global messaging bus used to trigger asynchronous logistics workflows.

### The Event-Driven Loop
- **Store** → submits demand → **API** → saves to **Firestore** & publishes to **Pub/Sub**.
- **Pub/Sub** → triggers → **Worker** → logs **Warehouse/Logistics actions**.

---

## 🚀 Key Features

- **Real-time Demand Aggregation**: Intelligent processing of raw customer demand signals from the field.
- **Automated Inventory Alerts**: Automatic detection of low-stock levels with immediate downstream notification.
- **Logistics Intelligence**: Smart monitoring of demand frequency to identify "High Demand" trends before they lead to stockouts.
- **Cloud-Native Design**: Fully serverless storage and messaging, eliminating the need for database migrations, connection strings, or server patching.

---

## 🛠 Tech Stack

- **Framework**: .NET 9 (C#)
- **Database**: Google Cloud Firestore (NoSQL)
- **Messaging**: Google Cloud Pub/Sub
- **Architecture**: Clean Architecture / Domain-Driven Design (DDD)
- **Deployment**: Optimized for Google Cloud Run

---

## 📂 Project Structure

- **`GenbaLink.Api`**: ASP.NET Core Web API handling HTTP requests.
- **`GenbaLink.Worker`**: .NET Worker Service for background event processing.
- **`GenbaLink.Core`**: The "Heart" of the system—contains Domain Entities and Interfaces.
- **`GenbaLink.Infrastructure`**: Concrete implementations for Firestore, Pub/Sub, and Data access.
- **`GenbaLink.Shared`**: Data Transfer Objects (DTOs) shared across the ecosystem.

---

## 🚦 Getting Started

### Prerequisites
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0)
- A Google Cloud Project with Firestore and Pub/Sub enabled.
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated:
  ```bash
  gcloud auth application-default login
  ```

### Local Setup
1.  **Clone the repository** and navigate to the backend directory.
2.  **Configure Project IDs**: Update `appsettings.json` in both `GenbaLink.Api` and `GenbaLink.Worker` with your GCP Project ID.
3.  **Run the API**:
    ```bash
    dotnet run --project GenbaLink.Api/GenbaLink.Api.csproj
    ```
    *Note: The API will automatically seed 100 diverse product SKUs into Firestore on first run.*
4.  **Run the Worker**:
    ```bash
    dotnet run --project GenbaLink.Worker/GenbaLink.Worker.csproj
    ```

---

## 🧪 Testing the Ecosystem

### 1. View Inventory
```bash
curl http://localhost:5045/api/inventory
```

### 2. Submit Demand (Triggers High Demand Alert)
```bash
curl -X POST http://localhost:5045/api/demand/batch \
-H "Content-Type: application/json" \
-d '{
  "storeId": "STORE_NY_01",
  "batchId": "'$(uuidgen)'",
  "signals": [
    {
      "id": "'$(uuidgen)'",
      "rawInput": "Customer looking for White Linen Shirt",
      "extractedAttributes": { "category": "Men tops", "color": "White", "size": "M" },
      "capturedAt": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
    }
  ]
}'
```
*Watch the **Worker Console** for fulfillment alerts.*

---

## 💎 Why This Architecture?

By migrating from a traditional SQL/Kafka setup to Firestore/Pub/Sub, GenbaLink achieves:
- **Zero Maintenance**: No schema migrations, SQL servers, or Kafka clusters to manage.
- **Scalability**: Seamlessly scales from a single store to thousands globally.
- **Developer Velocity**: Reduced the codebase by ~40% by offloading infrastructure complexity to GCP.
