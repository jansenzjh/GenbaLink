import SwiftUI
import SwiftData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isSyncing = false
    @Published var showingSyncAlert = false
    @Published var syncMessage = ""
    
    private let networkService = NetworkService.shared
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func syncData(signals: [DemandSignal]) {
        guard !signals.isEmpty else { return }
        
        isSyncing = true
        Task {
            do {
                try await networkService.syncBatch(signals: signals)
                
                // On success, clear local signals
                await MainActor.run {
                    if let modelContext = modelContext {
                        for signal in signals {
                            modelContext.delete(signal)
                        }
                        try? modelContext.save()
                    }
                    syncMessage = "Successfully synced and cleared local buffer."
                    showingSyncAlert = true
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    syncMessage = "Failed to sync: \(error.localizedDescription)"
                    showingSyncAlert = true
                    isSyncing = false
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet, signals: [DemandSignal]) {
        guard let modelContext = modelContext else { return }
        
        withAnimation {
            for index in offsets {
                modelContext.delete(signals[index])
            }
            try? modelContext.save()
        }
    }
}
