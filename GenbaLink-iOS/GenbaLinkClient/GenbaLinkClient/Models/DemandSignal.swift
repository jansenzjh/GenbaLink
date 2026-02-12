import Foundation
import SwiftData

@Model
class DemandSignal: Identifiable, Codable {
    var id: UUID
    var rawInput: String
    var extractedCategory: String
    var extractedColor: String
    var extractedSize: String
    var capturedAt: Date
    var isSynced: Bool
    
    init(rawInput: String, category: String, color: String, size: String) {
        self.id = UUID()
        self.rawInput = rawInput
        self.extractedCategory = category
        self.extractedColor = color
        self.extractedSize = size
        self.capturedAt = Date()
        self.isSynced = false
    }
    
    // Codable conformance for network
    enum CodingKeys: String, CodingKey {
        case id, rawInput, capturedAt
        case extractedAttributes
    }
    
    struct ExtractedAttributes: Codable {
        let category: String
        let color: String
        let size: String
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rawInput = try container.decode(String.self, forKey: .rawInput)
        capturedAt = try container.decode(Date.self, forKey: .capturedAt)
        let attrs = try container.decode(ExtractedAttributes.self, forKey: .extractedAttributes)
        extractedCategory = attrs.category
        extractedColor = attrs.color
        extractedSize = attrs.size
        isSynced = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rawInput, forKey: .rawInput)
        try container.encode(capturedAt, forKey: .capturedAt) // UTC handled by JSONEncoder date strategy
        try container.encode(ExtractedAttributes(category: extractedCategory, color: extractedColor, size: extractedSize), forKey: .extractedAttributes)
    }
}
