import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                inventoryContent
            }
            .navigationTitle("Global Inventory")
            .toolbar {
                Button(action: {
                    Task {
                        await viewModel.refreshInventory()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task {
                await viewModel.refreshInventory()
            }
            .alert("Adjust Stock", isPresented: $viewModel.showingAdjustmentAlert) {
                stockAdjustmentAlertContent
            } message: {
                if let sku = viewModel.selectedItem {
                    Text("Adjust stock for \(sku.name) (\(sku.id))")
                }
            }
        }
    }
    
    @ViewBuilder
    private var inventoryContent: some View {
        if viewModel.isLoading {
            ProgressView("Loading inventory...")
        } else if let error = viewModel.errorMessage {
            Text("Error: \(error)")
                .foregroundStyle(.red)
        } else if viewModel.inventory.isEmpty {
            Text("No inventory found.")
        } else {
            ForEach(viewModel.inventory) { item in
                Button(action: {
                    viewModel.selectedItem = item
                    viewModel.showingAdjustmentAlert = true
                }) {
                    ProductRow(item: item)
                }
                .foregroundStyle(.primary)
            }
        }
    }
    
    @ViewBuilder
    private var stockAdjustmentAlertContent: some View {
        TextField("Amount (e.g. 5 or -2)", text: $viewModel.adjustmentAmount)
            .keyboardType(.numbersAndPunctuation)
        Button("Cancel", role: .cancel) { 
            viewModel.adjustmentAmount = "1"
        }
        Button("Apply") {
            if let amount = Int(viewModel.adjustmentAmount), let sku = viewModel.selectedItem {
                Task {
                    await viewModel.adjustStock(skuId: sku.id, change: amount)
                }
            }
        }
    }
}
