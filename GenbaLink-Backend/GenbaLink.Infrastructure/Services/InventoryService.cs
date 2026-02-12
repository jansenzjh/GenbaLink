using GenbaLink.Core.Entities;
using GenbaLink.Core.Interfaces;
using GenbaLink.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Services;

public class InventoryService : IInventoryService
{
    private readonly GenbaLinkDbContext _context;
    private readonly IKafkaProducerService _kafkaProducer;
    private readonly ILogger<InventoryService> _logger;
    private readonly int _lowStockThreshold;

    public InventoryService(
        GenbaLinkDbContext context, 
        IKafkaProducerService kafkaProducer,
        IConfiguration configuration,
        ILogger<InventoryService> logger)
    {
        _context = context;
        _kafkaProducer = kafkaProducer;
        _logger = logger;
        _lowStockThreshold = configuration.GetValue<int>("Inventory:LowStockThreshold", 10);
    }

    public async Task<IEnumerable<ProductSku>> GetAllSkusAsync()
    {
        return await _context.ProductSkus.ToListAsync();
    }

    public async Task<ProductSku?> GetSkuAsync(string skuId)
    {
        return await _context.ProductSkus.FindAsync(skuId);
    }

    public async Task UpdateStockAsync(string skuId, int quantityChange)
    {
        var sku = await _context.ProductSkus.FindAsync(skuId);
        if (sku == null)
        {
            _logger.LogWarning($"SKU {skuId} not found during stock update.");
            return;
        }

        sku.StockLevel += quantityChange;
        
        // Prevent negative stock
        if (sku.StockLevel < 0) sku.StockLevel = 0;

        await _context.SaveChangesAsync();

        if (sku.IsLowStock(_lowStockThreshold))
        {
            await _kafkaProducer.PublishInventoryLowEventAsync(sku.Id, sku.StockLevel);
        }
    }
}
