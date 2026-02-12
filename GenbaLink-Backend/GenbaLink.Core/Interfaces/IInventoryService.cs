using System.Collections.Generic;
using System.Threading.Tasks;
using GenbaLink.Core.Entities;

namespace GenbaLink.Core.Interfaces;

public interface IInventoryService
{
    Task<IEnumerable<ProductSku>> GetAllSkusAsync();
    Task<ProductSku?> GetSkuAsync(string skuId);
    Task UpdateStockAsync(string skuId, int quantityChange);
}
