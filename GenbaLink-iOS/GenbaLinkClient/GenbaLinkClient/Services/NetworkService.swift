import Foundation
import Combine

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // Configurable baseURL from Info.plist
    private let baseURL: String = {
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            return url
        }
        // Fallback to local if not found
        return "https://localhost:5000/api"
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func fetchInventory() async throws -> [ProductSku] {
        guard let url = URL(string: "\(baseURL)/inventory") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try decoder.decode([ProductSku].self, from: data)
    }
    
    func adjustStock(skuId: String, change: Int) async throws {
        var urlComponents = URLComponents(string: "\(baseURL)/inventory/adjust")
        urlComponents?.queryItems = [
            URLQueryItem(name: "skuId", value: skuId),
            URLQueryItem(name: "change", value: String(change))
        ]
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func syncBatch(signals: [DemandSignal]) async throws {
        guard !signals.isEmpty else { return }
        
        let batchId = UUID()
        let payload = DemandBatchPayload(
            storeId: "JP-TOKYO-001", // Hardcoded for demo
            batchId: batchId,
            timestamp: Date(),
            signals: signals.map { signal in
                DemandSignalPayload(
                    id: signal.id,
                    rawInput: signal.rawInput,
                    extractedAttributes: ExtractedAttributesPayload(
                        category: signal.extractedCategory,
                        color: signal.extractedColor,
                        size: signal.extractedSize
                    ),
                    capturedAt: signal.capturedAt
                )
            }
        )
        
        guard let url = URL(string: "\(baseURL)/demand/batch") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sync batch"])
        }
    }
}

// Internal DTOs for matching backend expectations
struct DemandBatchPayload: Encodable {
    let storeId: String
    let batchId: UUID
    let timestamp: Date
    let signals: [DemandSignalPayload]
}

struct DemandSignalPayload: Encodable {
    let id: UUID
    let rawInput: String
    let extractedAttributes: ExtractedAttributesPayload
    let capturedAt: Date
}

struct ExtractedAttributesPayload: Encodable {
    let category: String
    let color: String
    let size: String
}
