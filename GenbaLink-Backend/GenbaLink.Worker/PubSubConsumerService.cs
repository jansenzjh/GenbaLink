using Google.Cloud.PubSub.V1;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace GenbaLink.Worker;

public class PubSubConsumerService : BackgroundService
{
    private readonly ILogger<PubSubConsumerService> _logger;
    private readonly IWarehouseHandler _warehouseHandler;
    private readonly string _projectId;
    private readonly string _inventorySubId;
    private readonly string _demandSubId;

    public PubSubConsumerService(
        IConfiguration configuration, 
        ILogger<PubSubConsumerService> logger,
        IWarehouseHandler warehouseHandler)
    {
        _logger = logger;
        _warehouseHandler = warehouseHandler;
        _projectId = configuration["PubSub:ProjectId"] ?? throw new ArgumentNullException("PubSub:ProjectId");
        _inventorySubId = configuration["PubSub:InventorySubscriptionId"] ?? "inventory-low-sub";
        _demandSubId = configuration["PubSub:DemandSubscriptionId"] ?? "high-demand-sub";
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("GenbaLink.Worker: Starting Pub/Sub Consumer Background Service...");

        // Start tasks for both subscriptions
        var inventoryTask = StartSubscriptionListener(_inventorySubId, _warehouseHandler.ProcessInventoryLowAsync, stoppingToken);
        var demandTask = StartSubscriptionListener(_demandSubId, _warehouseHandler.ProcessHighDemandAsync, stoppingToken);

        await Task.WhenAll(inventoryTask, demandTask);
    }

    private async Task StartSubscriptionListener(string subscriptionId, Func<string, Task> messageProcessor, CancellationToken stoppingToken)
    {
        var subscriptionName = SubscriptionName.FromProjectSubscription(_projectId, subscriptionId);
        
        try
        {
            _logger.LogInformation($"Worker: Attempting to subscribe to {subscriptionName}...");
            var subscriber = await SubscriberClient.CreateAsync(subscriptionName);
            
            await subscriber.StartAsync(async (message, token) =>
            {
                string text = message.Data.ToStringUtf8();
                _logger.LogInformation($"[SUBSCRIPTION: {subscriptionId}] Received Message: {text}");

                await messageProcessor(text);

                return SubscriberClient.Reply.Ack;
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Worker: Error in subscription listener for {subscriptionId}.");
        }
    }
}
