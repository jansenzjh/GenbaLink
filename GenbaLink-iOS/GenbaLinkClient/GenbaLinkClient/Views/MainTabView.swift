import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var llmService: LLMService
    
    var body: some View {
        TabView {
            CaptureView(llmService: llmService)
                .tabItem {
                    Label("Capture", systemImage: "pencil.and.scribble")
                }
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.doc.horizontal")
                }
            
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "shippingbox")
                }
        }
    }
}
