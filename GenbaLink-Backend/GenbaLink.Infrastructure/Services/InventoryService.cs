using GenbaLink.Core.Entities;
using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Services;

public class InventoryService : IInventoryService
{
    private readonly FirestoreRepository _repository;
    private readonly IMessageProducerService _messageProducer;
    private readonly ILogger<InventoryService> _logger;
    private readonly int _lowStockThreshold;

    public InventoryService(
        FirestoreRepository repository, 
        IMessageProducerService messageProducer,
        IConfiguration configuration,
        ILogger<InventoryService> logger)
    {
        _repository = repository;
        _messageProducer = messageProducer;
        _logger = logger;
        _lowStockThreshold = configuration.GetValue<int>("Inventory:LowStockThreshold", 10);
    }

    public async Task<IEnumerable<ProductSku>> GetAllSkusAsync()
    {
        return await _repository.GetAllAsync<ProductSku>("ProductSkus");
    }

    public async Task<ProductSku?> GetSkuAsync(string skuId)
    {
        return await _repository.GetAsync<ProductSku>("ProductSkus", skuId);
    }

    public async Task UpdateStockAsync(string skuId, int quantityChange)
    {
        var sku = await _repository.GetAsync<ProductSku>("ProductSkus", skuId);
        if (sku == null)
        {
            _logger.LogWarning($"SKU {skuId} not found during stock update.");
            return;
        }

        sku.StockLevel += quantityChange;
        
        // Prevent negative stock
        if (sku.StockLevel < 0) sku.StockLevel = 0;

        await _repository.AddAsync("ProductSkus", sku.Id, sku);

        if (sku.IsLowStock(_lowStockThreshold))
        {
            await _messageProducer.PublishInventoryLowEventAsync(sku.Id, sku.StockLevel);
        }
    }
}
