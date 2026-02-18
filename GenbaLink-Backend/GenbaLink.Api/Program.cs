using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Infrastructure.Services;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Cloud Run provides the port via the PORT environment variable
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Firestore and Pub/Sub Repositories
builder.Services.AddSingleton<FirestoreRepository>();
builder.Services.AddScoped<IMessageProducerService, PubSubProducerService>();

// Domain Services
builder.Services.AddScoped<IDemandAggregator, DemandAggregator>();
builder.Services.AddScoped<IInventoryService, InventoryService>();

var app = builder.Build();

// Simple health check for Cloud Run
app.MapGet("/", () => "GenbaLink API is operational");
app.MapGet("/health", () => Results.Ok("Healthy"));

app.MapControllers();

// Database Seeding (Non-blocking background task)
_ = Task.Run(async () =>
{
    using (var scope = app.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        var logger = services.GetRequiredService<ILogger<Program>>();
        try
        {
            logger.LogInformation("Background Firestore seeding started...");
            var repository = services.GetRequiredService<FirestoreRepository>();
            await DataSeeder.SeedAsync(repository);
            logger.LogInformation("Background Firestore seeding completed.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during background Firestore seeding.");
        }
    }
});

app.Run();
