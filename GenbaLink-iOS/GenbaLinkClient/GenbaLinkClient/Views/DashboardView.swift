import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DemandSignal.capturedAt, order: .reverse) private var signals: [DemandSignal]
    @ObservedObject var networkService = NetworkService.shared
    
    @State private var isSyncing = false
    @State private var showingSyncAlert = false
    @State private var syncMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Overview")) {
                    HStack {
                        Text("Total Signals Captured")
                        Spacer()
                        Text("\(signals.count)")
                            .bold()
                    }
                    
                    Button(action: syncData) {
                        if isSyncing {
                            ProgressView()
                        } else {
                            Text("Sync to Corporate (Cloud)")
                        }
                    }
                    .disabled(signals.isEmpty || isSyncing)
                }
                
                Section(header: Text("Recent Signals")) {
                    ForEach(signals) { signal in
                        VStack(alignment: .leading) {
                            Text(signal.rawInput)
                                .font(.headline)
                            HStack {
                                Text(signal.extractedCategory)
                                Text("•")
                                Text(signal.extractedColor)
                                Text("•")
                                Text(signal.extractedSize)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Manager Dashboard")
            .alert("Sync Status", isPresented: $showingSyncAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(syncMessage)
            }
        }
    }
    
    private func syncData() {
        isSyncing = true
        Task {
            do {
                try await networkService.syncBatch(signals: signals)
                
                // On success, maybe clear local signals or mark as synced?
                // For MVP, we'll just clear them to show "moved to cloud"
                await MainActor.run {
                    for signal in signals {
                        modelContext.delete(signal)
                    }
                    try? modelContext.save()
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
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(signals[index])
            }
            try? modelContext.save()
        }
    }
}
