using GenbaLink.Core.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace GenbaLink.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InventoryController : ControllerBase
{
    private readonly IInventoryService _inventoryService;

    public InventoryController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllSkus()
    {
        var skus = await _inventoryService.GetAllSkusAsync();
        return Ok(skus);
    }

    [HttpPost("adjust")]
    public async Task<IActionResult> AdjustStock([FromQuery] string skuId, [FromQuery] int change)
    {
        await _inventoryService.UpdateStockAsync(skuId, change);
        return Ok(new { message = "Stock adjusted." });
    }
}
