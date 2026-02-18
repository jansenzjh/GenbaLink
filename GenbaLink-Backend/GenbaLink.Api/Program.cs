using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Infrastructure.Services;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapControllers();

// Database Seeding
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var repository = services.GetRequiredService<FirestoreRepository>();
        await DataSeeder.SeedAsync(repository);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred seeding Firestore.");
    }
}

app.Run();
