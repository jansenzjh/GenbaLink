using System;
using Google.Cloud.Firestore;

namespace GenbaLink.Core.Entities;

[FirestoreData]
public class DemandSignal
{
    [FirestoreProperty]
    public string Id { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string StoreId { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string BatchId { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string RawInput { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string ExtractedCategory { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string ExtractedColor { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public string ExtractedSize { get; set; } = string.Empty;
    
    [FirestoreProperty]
    public DateTime CapturedAtUtc { get; set; }
    
    [FirestoreProperty]
    public DateTime ProcessedAtUtc { get; set; }
}
