using GenbaLink.Core.Interfaces;
using Google.Cloud.PubSub.V1;
using Google.Protobuf;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using System.Text.Json;

namespace GenbaLink.Infrastructure.Services;

public class PubSubProducerService : IMessageProducerService
{
    private readonly string _projectId;
    private readonly string _inventoryTopicId;
    private readonly string _demandTopicId;
    private readonly ILogger<PubSubProducerService> _logger;

    public PubSubProducerService(IConfiguration configuration, ILogger<PubSubProducerService> logger)
    {
        _projectId = configuration["PubSub:ProjectId"] ?? throw new System.ArgumentNullException("PubSub:ProjectId");
        _inventoryTopicId = configuration["PubSub:InventoryTopicId"] ?? "inventory-low";
        _demandTopicId = configuration["PubSub:DemandTopicId"] ?? "high-demand";
        _logger = logger;
    }

    public async Task PublishInventoryLowEventAsync(string skuId, int currentStock)
    {
        try
        {
            var topicName = TopicName.FromProjectTopic(_projectId, _inventoryTopicId);
            var publisher = await PublisherClient.CreateAsync(topicName);

            var message = new { SkuId = skuId, CurrentStock = currentStock, Timestamp = DateTime.UtcNow };
            string json = JsonSerializer.Serialize(message);

            _logger.LogInformation($"Publishing to topic {topicName}...");
            string messageId = await publisher.PublishAsync(json);
            _logger.LogInformation($"Published inventory low event for {skuId}. Message ID: {messageId}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to publish inventory low event for {skuId} to topic {_inventoryTopicId}");
        }
    }

    public async Task PublishHighDemandEventAsync(string category, string color, string size, int totalRequests)
    {
        try
        {
            var topicName = TopicName.FromProjectTopic(_projectId, _demandTopicId);
            var publisher = await PublisherClient.CreateAsync(topicName);

            var message = new 
            { 
                Category = category, 
                Color = color, 
                Size = size, 
                TotalRequests = totalRequests, 
                Timestamp = DateTime.UtcNow 
            };
            string json = JsonSerializer.Serialize(message);

            _logger.LogInformation($"Publishing to topic {topicName}...");
            string messageId = await publisher.PublishAsync(json);
            _logger.LogInformation($"Published high demand event for {category}/{color}/{size}. Message ID: {messageId}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Failed to publish high demand event for {category}/{color}/{size} to topic {_demandTopicId}");
        }
    }
}
