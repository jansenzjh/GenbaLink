using Confluent.Kafka;
using GenbaLink.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Services;

public class KafkaProducerService : IKafkaProducerService
{
    private readonly ILogger<KafkaProducerService> _logger;
    private readonly IProducer<Null, string> _producer;
    private readonly string _topic;

    public KafkaProducerService(IConfiguration configuration, ILogger<KafkaProducerService> logger)
    {
        _logger = logger;
        var config = new ProducerConfig
        {
            BootstrapServers = configuration["Kafka:BootstrapServers"] ?? "localhost:9092"
        };
        _topic = configuration["Kafka:Topic"] ?? "inventory-alerts";
        _producer = new ProducerBuilder<Null, string>(config).Build();
    }

    public async Task PublishInventoryLowEventAsync(string skuId, int currentStock)
    {
        var eventData = new
        {
            Event = "InventoryLow",
            SkuId = skuId,
            CurrentStock = currentStock,
            Timestamp = DateTime.UtcNow
        };

        var message = JsonSerializer.Serialize(eventData);

        try
        {
            await _producer.ProduceAsync(_topic, new Message<Null, string> { Value = message });
            _logger.LogInformation($"Published low inventory event for SKU {skuId}");
        }
        catch (ProduceException<Null, string> e)
        {
            _logger.LogError($"Delivery failed: {e.Error.Reason}");
        }
    }

    public async Task PublishHighDemandEventAsync(string category, string color, string size, int totalRequests)
    {
        var eventData = new
        {
            Event = "HighDemand",
            Attributes = new { Category = category, Color = color, Size = size },
            TotalRequests = totalRequests,
            Timestamp = DateTime.UtcNow
        };

        var message = JsonSerializer.Serialize(eventData);

        try
        {
            await _producer.ProduceAsync(_topic, new Message<Null, string> { Value = message });
            _logger.LogInformation($"Published HIGH DEMAND event for {color} {size} {category} (Count: {totalRequests})");
        }
        catch (ProduceException<Null, string> e)
        {
            _logger.LogError($"Delivery failed: {e.Error.Reason}");
        }
    }
}
