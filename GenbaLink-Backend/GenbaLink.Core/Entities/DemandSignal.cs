using System;

namespace GenbaLink.Core.Entities;

public class DemandSignal
{
    public Guid Id { get; set; }
    public string StoreId { get; set; } = string.Empty;
    public Guid BatchId { get; set; }
    public string RawInput { get; set; } = string.Empty;
    
    // Storing aggregated attributes as JSON string or separate fields?
    // Let's use specific fields for querying + JSON for flexibility if needed.
    public string ExtractedCategory { get; set; } = string.Empty;
    public string ExtractedColor { get; set; } = string.Empty;
    public string ExtractedSize { get; set; } = string.Empty;
    
    public DateTime CapturedAtUtc { get; set; }
    public DateTime ProcessedAtUtc { get; set; }
}
