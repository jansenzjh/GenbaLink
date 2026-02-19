import Foundation

struct ProductSku: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let color: String
    let size: String
    let price: Double
    let stockLevel: Int
    
    var isLowStock: Bool {
        return stockLevel <= 5 // Hardcoded threshold for demo
    }
}
