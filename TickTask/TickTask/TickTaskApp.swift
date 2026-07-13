import SwiftUI
import SwiftData

@main
struct TickTaskApp: App {

    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

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
                .preferredColorScheme(isDarkModeEnabled ? .dark : nil)
        }
        .modelContainer(sharedModelContainer)
    }
}
