using System;
using Google.Cloud.Firestore;

namespace GenbaLink.Core.Entities;

[FirestoreData]
public class ProductSku
{
    [FirestoreProperty]
    public string Id { get; set; } = string.Empty; // e.g. "456789" (Uniqlo style)
    
    [FirestoreProperty]
    public string Name { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string Category { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string Color { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string Size { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public double Price { get; set; } // Changed from decimal to double for Firestore compatibility
    
    [FirestoreProperty]
    public int StockLevel { get; set; }
    
    // For validation or logic
    public bool IsLowStock(int threshold) => StockLevel <= threshold;
}
