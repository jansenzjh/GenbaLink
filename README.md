# GenbaLink: "Invisible Demand" Intelligence System

GenbaLink is a "Genba-First" intelligence system that captures unsatisfied demand from the store floor using on-device AI and aggregates it in a high-performance backend.

## Architecture

### Backend (.NET 10 / 8)
- **Framework**: ASP.NET Core Web API
- **Database**: SQLite
- **Architecture**: Clean Architecture (Api, Core, Infrastructure, Shared)
- **Key Features**:
  - **Demand Aggregator**: Receives batched signals from iOS.
  - **Inventory Service**: Manages 1000+ Mock SKUs (Uniqlo-style).
  - **Kafka Integration**: Publishes `InventoryLowEvent` to topic `inventory-alerts` when stock < 10.

### Frontend (iOS)
- **Framework**: SwiftUI
- **AI Engine**: MLX Swift (running Qwen2.5-3B-Instruct-4bit locally).
- **Persistence**: SwiftData (Local Buffer).
- **Networking**: Syncs batches to Backend.

## How to Run

### 1. Backend
```bash
cd GenbaLink-Backend/GenbaLink.Api
dotnet run
```
The API will start at `http://localhost:5045`.

**Test Endpoints:**
- Get Inventory: `curl http://localhost:5045/api/inventory`
- Simulate Sale (Trigger Kafka): `curl -X POST "http://localhost:5045/api/inventory/adjust?skuId={SKU_ID}&change=-50"`

### 2. iOS App
1. Open `GenbaLink-iOS/GenbaLinkClient/GenbaLinkClient.xcodeproj` in Xcode.
2. Ensure **MLX Swift** dependencies are added (if not, add `https://github.com/ml-explore/mlx-swift`).
3. Run on Simulator or Device.
4. **Capture Tab**: Type "Customer wants a red XL down jacket" and click "Analyze".
5. **Dashboard Tab**: Click "Sync to Corporate" to send data to the backend.

## Kafka Configuration
To see Kafka messages, ensure a Kafka broker is running at `localhost:9092`.
If not running, the backend will log errors but continue to function.
