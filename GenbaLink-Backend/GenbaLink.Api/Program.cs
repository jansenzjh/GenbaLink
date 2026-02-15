using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using GenbaLink.DB;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<GenbaLinkDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// Services
builder.Services.AddScoped<IDemandAggregator, DemandAggregator>();
builder.Services.AddScoped<IInventoryService, InventoryService>();
builder.Services.AddScoped<IKafkaProducerService, KafkaProducerService>();
builder.Services.AddScoped<SchemaUpgrader>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
else
{
    // For containerized environments like Cloud Run, HTTPS is usually handled by the load balancer.
    // app.UseHttpsRedirection(); 
}

app.MapControllers();

// Database Seeding
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        // Run database migrations
        var upgrader = services.GetRequiredService<SchemaUpgrader>();
        upgrader.Upgrade();
        
        var context = services.GetRequiredService<GenbaLinkDbContext>();
        // EnsureCreated removed in favor of Evolve migrations
        
        await DataSeeder.SeedAsync(context);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred seeding the DB.");
    }
}

app.Run();
