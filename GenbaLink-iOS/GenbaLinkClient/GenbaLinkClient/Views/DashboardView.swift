import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DemandSignal.capturedAt, order: .reverse) private var signals: [DemandSignal]
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                overviewSection
                recentSignalsSection
            }
            .navigationTitle("Manager Dashboard")
            .alert("Sync Status", isPresented: $viewModel.showingSyncAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.syncMessage)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }
    
    private var overviewSection: some View {
        Section(header: Text("Overview")) {
            HStack {
                Text("Total Signals Captured")
                Spacer()
                Text("\(signals.count)")
                    .bold()
            }
            
            Button(action: {
                viewModel.syncData(signals: signals)
            }) {
                if viewModel.isSyncing {
                    ProgressView()
                } else {
                    Text("Sync to Corporate (Cloud)")
                }
            }
            .disabled(signals.isEmpty || viewModel.isSyncing)
        }
    }
    
    private var recentSignalsSection: some View {
        Section(header: Text("Recent Signals")) {
            ForEach(signals) { signal in
                SignalRow(signal: signal)
            }
            .onDelete { offsets in
                viewModel.deleteItems(offsets: offsets, signals: signals)
            }
        }
    }
}
