using Microsoft.Extensions.Logging;
using System.Text.Json;
using System.Threading.Tasks;

namespace GenbaLink.Worker;

public interface IWarehouseHandler
{
    Task ProcessInventoryLowAsync(string messageJson);
    Task ProcessHighDemandAsync(string messageJson);
}

public class WarehouseHandler : IWarehouseHandler
{
    private readonly ILogger<WarehouseHandler> _logger;

    public WarehouseHandler(ILogger<WarehouseHandler> logger)
    {
        _logger = logger;
    }

    public Task ProcessInventoryLowAsync(string messageJson)
    {
        try
        {
            using var doc = JsonDocument.Parse(messageJson);
            var root = doc.RootElement;
            string skuId = root.GetProperty("SkuId").GetString() ?? "Unknown";
            int stock = root.GetProperty("CurrentStock").GetInt32();

            _logger.LogInformation($">>> WAREHOUSE ACTION: Warehouse notified: SKU {skuId} is low ({stock}). Scheduling restock for shelf A-{skuId.Substring(0, 2)}.");
        }
        catch (System.Exception ex)
        {
            _logger.LogWarning($"Could not parse inventory message: {ex.Message}");
        }
        return Task.CompletedTask;
    }

    public Task ProcessHighDemandAsync(string messageJson)
    {
        try
        {
            using var doc = JsonDocument.Parse(messageJson);
            var root = doc.RootElement;
            string category = root.GetProperty("Category").GetString() ?? "Unknown";
            string color = root.GetProperty("Color").GetString() ?? "Unknown";
            string size = root.GetProperty("Size").GetString() ?? "Unknown";
            int count = root.GetProperty("TotalRequests").GetInt32();

            _logger.LogInformation($">>> FULFILLMENT ALERT: Marketing & Logistics alerted: High demand for {category} ({color}/{size}) - {count} requests. Increasing production priority.");
        }
        catch (System.Exception ex)
        {
            _logger.LogWarning($"Could not parse high demand message: {ex.Message}");
        }
        return Task.CompletedTask;
    }
}
