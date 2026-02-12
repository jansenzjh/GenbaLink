import SwiftUI
import SwiftData

@main
struct GenbaLinkClientApp: App {
    @StateObject private var llmService = LLMService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DemandSignal.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(llmService)
        }
        .modelContainer(sharedModelContainer)
    }
}
