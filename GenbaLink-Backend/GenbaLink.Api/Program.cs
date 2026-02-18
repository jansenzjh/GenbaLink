using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Infrastructure.Services;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Ensure the app binds to all interfaces (required for Cloud Run)
builder.WebHost.UseUrls("http://0.0.0.0:8080");

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

// Root endpoint for quick verification/health check
app.MapGet("/", () => "GenbaLink API is operational");
app.MapGet("/health", () => Results.Ok("Healthy"));

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

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
            logger.LogInformation("Starting background Firestore seeding...");
            var repository = services.GetRequiredService<FirestoreRepository>();
            await DataSeeder.SeedAsync(repository);
            logger.LogInformation("Firestore seeding completed successfully.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during non-blocking Firestore seeding.");
        }
    }
});

try
{
    app.Run();
}
catch (Exception ex)
{
    Console.WriteLine($"CRITICAL STARTUP FAILURE: {ex}");
    throw;
}
