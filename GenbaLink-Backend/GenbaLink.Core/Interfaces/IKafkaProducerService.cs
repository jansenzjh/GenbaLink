using System.Threading.Tasks;

namespace GenbaLink.Core.Interfaces;

public interface IKafkaProducerService
{
    Task PublishInventoryLowEventAsync(string skuId, int currentStock);
    Task PublishHighDemandEventAsync(string category, string color, string size, int totalRequests);
}
