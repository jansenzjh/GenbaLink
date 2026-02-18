using GenbaLink.Core.Entities;
using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Shared.DTOs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Google.Cloud.Firestore;

namespace GenbaLink.Infrastructure.Services;

public class DemandAggregator : IDemandAggregator
{
    private readonly FirestoreRepository _repository;
    private readonly ILogger<DemandAggregator> _logger;
    private readonly IMessageProducerService _messageProducer;
    private readonly int _demandThreshold;

    public DemandAggregator(
        FirestoreRepository repository, 
        ILogger<DemandAggregator> logger,
        IMessageProducerService messageProducer,
        IConfiguration configuration)
    {
        _repository = repository;
        _logger = logger;
        _messageProducer = messageProducer;
        _demandThreshold = configuration.GetValue<int>("PubSub:DemandAlertThreshold", 10);
    }

    public async Task ProcessBatchAsync(DemandBatchDto batch)
    {
        _logger.LogInformation($"Processing batch {batch.BatchId} from store {batch.StoreId}");

        var collection = _repository.GetCollection("DemandSignals");

        foreach (var s in batch.Signals)
        {
            var data = new Dictionary<string, object>
            {
                { "Id", s.Id.ToString() },
                { "StoreId", batch.StoreId },
                { "BatchId", batch.BatchId.ToString() },
                { "RawInput", s.RawInput },
                { "ExtractedCategory", s.ExtractedAttributes.Category },
                { "ExtractedColor", s.ExtractedAttributes.Color },
                { "ExtractedSize", s.ExtractedAttributes.Size },
                { "CapturedAtUtc", DateTime.SpecifyKind(s.CapturedAt, DateTimeKind.Utc) },
                { "ProcessedAtUtc", DateTime.UtcNow }
            };

            await collection.Document(s.Id.ToString()).SetAsync(data);

            // Check for High Demand
            Query query = collection
                .WhereEqualTo("ExtractedCategory", s.ExtractedAttributes.Category)
                .WhereEqualTo("ExtractedColor", s.ExtractedAttributes.Color)
                .WhereEqualTo("ExtractedSize", s.ExtractedAttributes.Size);
            
            var snapshot = await query.GetSnapshotAsync();
            int count = snapshot.Count;
            
            if (count >= _demandThreshold)
            {
                await _messageProducer.PublishHighDemandEventAsync(
                    s.ExtractedAttributes.Category, 
                    s.ExtractedAttributes.Color, 
                    s.ExtractedAttributes.Size, 
                    count);
            }
        }

        _logger.LogInformation($"Saved {batch.Signals.Count} signals.");
    }
}
