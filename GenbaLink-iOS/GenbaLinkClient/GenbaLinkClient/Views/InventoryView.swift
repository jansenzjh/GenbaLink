import SwiftUI

struct InventoryView: View {
    @ObservedObject var networkService = NetworkService.shared
    @State private var inventory: [ProductSku] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedItem: ProductSku?
    @State private var adjustmentAmount: String = "1"
    @State private var showingAdjustmentAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView("Loading inventory...")
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundStyle(.red)
                } else if inventory.isEmpty {
                    Text("No inventory found.")
                } else {
                    ForEach(inventory) { item in
                        Button(action: {
                            selectedItem = item
                            showingAdjustmentAlert = true
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("\(item.category) • \(item.color) • \(item.size)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(item.stockLevel) in stock")
                                        .foregroundStyle(item.stockLevel <= 5 ? .red : .primary)
                                        .bold(item.stockLevel <= 5)
                                    Text(String(format: "$%.2f", item.price))
                                        .font(.caption)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Global Inventory")
            .toolbar {
                Button(action: {
                    Task {
                        await refreshInventory()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await refreshInventory()
            }
            .alert("Adjust Stock", isPresented: $showingAdjustmentAlert) {
                TextField("Amount (e.g. 5 or -2)", text: $adjustmentAmount)
                    .keyboardType(.numbersAndPunctuation)
                Button("Cancel", role: .cancel) { 
                    adjustmentAmount = "1"
                }
                Button("Apply") {
                    if let amount = Int(adjustmentAmount), let sku = selectedItem {
                        Task {
                            await adjustStock(skuId: sku.id, change: amount)
                            await MainActor.run { adjustmentAmount = "1" }
                        }
                    }
                }
            } message: {
                if let sku = selectedItem {
                    Text("Adjust stock for \(sku.name) (\(sku.id))")
                }
            }
        }
    }
    
    private func refreshInventory() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        do {
            let fetchedItems = try await networkService.fetchInventory()
            await MainActor.run {
                self.inventory = fetchedItems
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func adjustStock(skuId: String, change: Int) async {
        do {
            try await networkService.adjustStock(skuId: skuId, change: change)
            await refreshInventory()
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to adjust stock: \(error.localizedDescription)"
            }
        }
    }
}
