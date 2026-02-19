import SwiftUI
import Combine

@MainActor
class InventoryViewModel: ObservableObject {
    @Published var inventory: [ProductSku] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedItem: ProductSku?
    @Published var adjustmentAmount: String = "1"
    @Published var showingAdjustmentAlert = false
    
    private let networkService = NetworkService.shared
    
    func refreshInventory() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedItems = try await networkService.fetchInventory()
            inventory = fetchedItems
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func adjustStock(skuId: String, change: Int) async {
        do {
            try await networkService.adjustStock(skuId: skuId, change: change)
            await refreshInventory()
            adjustmentAmount = "1"
        } catch {
            errorMessage = "Failed to adjust stock: \(error.localizedDescription)"
        }
    }
}
