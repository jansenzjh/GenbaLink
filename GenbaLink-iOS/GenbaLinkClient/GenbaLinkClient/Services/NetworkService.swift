import Foundation
import Combine

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // Using localhost for simulator.
    private let baseURL = "http://localhost:5045/api"
    
    func syncBatch(signals: [DemandSignal]) async throws {
        guard !signals.isEmpty else { return }
        
        let batchId = UUID()
        let payload: [String: Any] = [
            "storeId": "JP-TOKYO-001", // Hardcoded for demo
            "batchId": batchId.uuidString,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "signals": signals.map { signal in
                [
                    "id": signal.id.uuidString,
                    "rawInput": signal.rawInput,
                    "extractedAttributes": [
                        "category": signal.extractedCategory,
                        "color": signal.extractedColor,
                        "size": signal.extractedSize
                    ],
                    "capturedAt": ISO8601DateFormatter().string(from: signal.capturedAt)
                ]
            }
        ]
        
        guard let url = URL(string: "\(baseURL)/demand/batch") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sync batch"])
        }
    }
}
