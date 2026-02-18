using Google.Cloud.Firestore;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GenbaLink.Infrastructure.Data;

public class FirestoreRepository
{
    private readonly FirestoreDb _db;

    public FirestoreRepository(IConfiguration configuration)
    {
        string projectId = configuration["Firestore:ProjectId"] ?? throw new System.ArgumentNullException("Firestore:ProjectId");
        
        // Use Builder for better credential discovery in various environments
        var builder = new FirestoreDbBuilder { ProjectId = projectId };
        _db = builder.Build();
    }

    public CollectionReference GetCollection(string collectionName) => _db.Collection(collectionName);

    public async Task AddAsync<T>(string collectionName, string documentId, T item)
    {
        var docRef = _db.Collection(collectionName).Document(documentId);
        await docRef.SetAsync(item);
    }

    public async Task<T?> GetAsync<T>(string collectionName, string documentId)
    {
        var docRef = _db.Collection(collectionName).Document(documentId);
        var snapshot = await docRef.GetSnapshotAsync();
        if (snapshot.Exists)
        {
            return snapshot.ConvertTo<T>();
        }
        return default;
    }

    public async Task<List<T>> GetAllAsync<T>(string collectionName)
    {
        var collectionRef = _db.Collection(collectionName);
        var snapshot = await collectionRef.GetSnapshotAsync();
        var results = new List<T>();
        foreach (var doc in snapshot.Documents)
        {
            results.Add(doc.ConvertTo<T>());
        }
        return results;
    }

    public async Task UpdateAsync(string collectionName, string documentId, Dictionary<string, object> updates)
    {
        var docRef = _db.Collection(collectionName).Document(documentId);
        await docRef.UpdateAsync(updates);
    }
}
