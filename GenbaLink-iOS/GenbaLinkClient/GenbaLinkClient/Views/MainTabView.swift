import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CaptureView()
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
