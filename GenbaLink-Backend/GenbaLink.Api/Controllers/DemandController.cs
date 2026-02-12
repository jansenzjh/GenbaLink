using GenbaLink.Core.Interfaces;
using GenbaLink.Shared.DTOs;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace GenbaLink.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DemandController : ControllerBase
{
    private readonly IDemandAggregator _aggregator;

    public DemandController(IDemandAggregator aggregator)
    {
        _aggregator = aggregator;
    }

    [HttpPost("batch")]
    public async Task<IActionResult> SubmitBatch([FromBody] DemandBatchDto batch)
    {
        if (batch == null || batch.Signals == null || batch.Signals.Count == 0)
        {
            return BadRequest("Invalid batch data.");
        }

        await _aggregator.ProcessBatchAsync(batch);
        return Ok(new { message = "Batch received and processing initiated." });
    }
}
