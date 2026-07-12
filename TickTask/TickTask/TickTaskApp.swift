import SwiftUI
import SwiftData

@main
struct TickTaskApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self
        ])

        let configuration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
