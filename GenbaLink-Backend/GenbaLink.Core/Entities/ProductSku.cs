using System;

namespace GenbaLink.Core.Entities;

public class ProductSku
{
    public string Id { get; set; } = string.Empty; // e.g. "456789" (Uniqlo style)
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockLevel { get; set; }
    
    // For validation or logic
    public bool IsLowStock(int threshold) => StockLevel <= threshold;
}
