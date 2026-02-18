using GenbaLink.Worker;

var builder = Host.CreateApplicationBuilder(args);

// Register Services
builder.Services.AddSingleton<IWarehouseHandler, WarehouseHandler>();
builder.Services.AddHostedService<PubSubConsumerService>();

var host = builder.Build();
host.Run();
