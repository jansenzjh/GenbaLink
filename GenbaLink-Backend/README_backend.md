# GenbaLink Backend (.NET 9)

The high-performance core of GenbaLink, built with ASP.NET Core Web API.

## Prerequisites
- .NET 9 SDK
- Docker & Docker Compose (for containerized setup)

## Containerization & Local Development

To run the entire stack (API + MariaDB) locally using Docker:

```bash
docker-compose up --build
```

The API will be available at `http://localhost:8080`.

## Database
The project uses **MariaDB** for data persistence. The database schema is managed by **Evolve** migrations and automatically applied on startup.

### Database Migrations
Database migrations are handled by the `GenbaLink.DB` project. 
- **Scripts**: Located in `GenbaLink.DB/Scripts`.
- **Naming**: `V{Major}_{Minor}_{Patch}__{Description}.sql`.

## Configuration
Configuration is managed in `appsettings.json` or via environment variables in Docker.

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Port=3306;Database=genbalink;Uid=root;Pwd=genba_password;"
  }
}
```

## Key Endpoints
- **GET /api/inventory**: List all SKUs.
- **POST /api/inventory/adjust**: Adjust stock levels.
- **POST /api/demand/batch**: Submit a batch of demand signals.

## Deployment & Production Considerations

### POC vs. Production Architecture

The current `docker-compose` setup is designed for **POC (Proof of Concept) and Demo purposes**. It runs both the application and the database on the same virtual machine (VM).

#### Production Best Practices:
In a production environment (e.g., on GCP), you should **separate the Application from the Database**:

1.  **Scalability**: Decoupling allows you to scale the API (using Cloud Run or GKE) independently of the database.
2.  **Maintenance**: Updating the database or the application becomes easier with zero-downtime deployments.
3.  **Managed Services**: For MariaDB/MySQL on GCP, it is highly recommended to use **Cloud SQL**. This provides automated backups, patching, and high availability.
4.  **Security**: Databases should be in a private subnet, only accessible by the application layer.
5.  **Persistence**: While the POC uses Docker volumes, production data should rely on managed storage solutions with redundancy.

## Running Locally (Bare Metal)
If you wish to run the API without Docker:
1. Ensure a MariaDB instance is running.
2. Update the `DefaultConnection` in `appsettings.json`.
3. Run:
```bash
cd GenbaLink.Api
dotnet run
```
