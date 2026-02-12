using GenbaLink.Core.Entities;
using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using GenbaLink.Shared.DTOs;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Linq;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Services;

public class DemandAggregator : IDemandAggregator
{
    private readonly GenbaLinkDbContext _context;
    private readonly ILogger<DemandAggregator> _logger;
    private readonly IKafkaProducerService _kafkaProducer;
    private readonly int _demandThreshold;

    public DemandAggregator(
        GenbaLinkDbContext context, 
        ILogger<DemandAggregator> logger,
        IKafkaProducerService kafkaProducer,
        IConfiguration configuration)
    {
        _context = context;
        _logger = logger;
        _kafkaProducer = kafkaProducer;
        _demandThreshold = configuration.GetValue<int>("Kafka:DemandAlertThreshold", 10);
    }

    public async Task ProcessBatchAsync(DemandBatchDto batch)
    {
        _logger.LogInformation($"Processing batch {batch.BatchId} from store {batch.StoreId}");

        var signals = batch.Signals.Select(s => new DemandSignal
        {
            Id = s.Id,
            StoreId = batch.StoreId,
            BatchId = batch.BatchId,
            RawInput = s.RawInput,
            ExtractedCategory = s.ExtractedAttributes.Category,
            ExtractedColor = s.ExtractedAttributes.Color,
            ExtractedSize = s.ExtractedAttributes.Size,
            CapturedAtUtc = s.CapturedAt,
            ProcessedAtUtc = System.DateTime.UtcNow
        }).ToList();

        await _context.DemandSignals.AddRangeAsync(signals);
        await _context.SaveChangesAsync();

        _logger.LogInformation($"Saved {signals.Count} signals.");

        // Check for High Demand
        foreach (var signal in signals)
        {
            // Count existing signals for same attributes
            var count = await _context.DemandSignals
                .CountAsync(s => s.ExtractedCategory == signal.ExtractedCategory &&
                                 s.ExtractedColor == signal.ExtractedColor &&
                                 s.ExtractedSize == signal.ExtractedSize);
            
            if (count >= _demandThreshold)
            {
                await _kafkaProducer.PublishHighDemandEventAsync(
                    signal.ExtractedCategory, 
                    signal.ExtractedColor, 
                    signal.ExtractedSize, 
                    count);
            }
        }
    }
}
