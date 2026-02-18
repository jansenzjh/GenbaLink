using GenbaLink.Worker;

var builder = WebApplication.CreateBuilder(args);

// Register Services
builder.Services.AddSingleton<IWarehouseHandler, WarehouseHandler>();
builder.Services.AddHostedService<PubSubConsumerService>();

// Add simple health check endpoints for Cloud Run
var app = builder.Build();

app.MapGet("/", () => "GenbaLink Worker is running!");
app.MapGet("/health", () => Results.Ok("Healthy"));

app.Run();
