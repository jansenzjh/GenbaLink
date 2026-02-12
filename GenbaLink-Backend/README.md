# GenbaLink Backend (.NET 10 / 8)

The high-performance core of GenbaLink, built with ASP.NET Core Web API.

## Prerequisites
- .NET 10 SDK (or .NET 8)
- Kafka (Optional, for alerts)

## Configuration
Configuration is managed in `appsettings.Development.json`.

```json
{
  "Kafka": {
    "BootstrapServers": "localhost:9092",
    "Topic": "inventory-alerts",
    "DemandAlertThreshold": 10
  },
  "Inventory": {
    "LowStockThreshold": 10
  }
}
```

- `DemandAlertThreshold`: Number of accumulated demand signals for a specific attribute set (Category/Color/Size) that triggers a "High Demand" Kafka alert.
- `LowStockThreshold`: Inventory level that triggers a "Low Inventory" Kafka alert.

## Running the API
```bash
cd GenbaLink.Api
dotnet run
```
The API listens on `http://localhost:5045`.

## Key Endpoints
- **GET /api/inventory**: List all 1000+ mock SKUs.
- **POST /api/inventory/adjust?skuId={id}&change={qty}**: Adjust stock. Triggers Kafka alert if stock < threshold.
- **POST /api/demand/batch**: submit a batch of demand signals. Triggers Kafka alert if accumulated demand for an item >= `DemandAlertThreshold`.

## Database
Uses SQLite (`genbalink.db`). The database schema is managed by **Evolve** migrations and automatically applied on startup.

## Database Migrations
Database migrations are handled by the `GenbaLink.DB` project. This ensures that the database schema is versioned and reproducible.

### How it works
1.  **Project**: `GenbaLink.DB` is a Class Library containing the migration logic (`SchemaUpgrader`) and SQL scripts.
2.  **Execution**: On application startup (`Program.cs`), the `SchemaUpgrader.Upgrade()` method is called to apply any pending migrations.
3.  **Scripts**: SQL migration scripts are located in `GenbaLink.DB/Scripts`. They are embedded into the assembly and executed by Evolve.

### Adding a new migration
1.  Create a new SQL file in `GenbaLink.DB/Scripts`.
2.  Follow the naming convention: `V{Major}_{Minor}_{Patch}__{Description}.sql`.
    *   Example: `V1_0_1__Add_Customer_Table.sql`
    *   Note: Two underscores `__` separate the version from the description.
3.  Write standard SQL DDL/DML statements.
4.  Rebuild and run the application. Evolve will detect the new script and apply it.
