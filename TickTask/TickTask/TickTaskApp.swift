import SwiftUI
import SwiftData

@main
struct TickTaskApp: App {

    @AppStorage("appearance") private var appearanceRawValue = AppearanceOption.system.rawValue

    private let sharedModelContainer: ModelContainer?
    private let startupErrorMessage: String?

    init() {
        do {
            sharedModelContainer = try Self.makeModelContainer()
            startupErrorMessage = nil
        } catch {
            sharedModelContainer = nil
            startupErrorMessage = error.localizedDescription
        }
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: TickTaskSchemaV3.self)
        
        let isUITestMode = ProcessInfo.processInfo.arguments.contains("UITestMode")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITestMode)

        return try ModelContainer(
            for: schema,
            migrationPlan: TickTaskMigrationPlan.self,
            configurations: [configuration]
        )
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let sharedModelContainer {
                    HomeView()
                        .modelContainer(sharedModelContainer)
                } else {
                    PersistenceUnavailableView(message: startupErrorMessage)
                }
            }
                .preferredColorScheme(appearance.colorScheme)
                .animation(.easeInOut(duration: 0.25), value: appearanceRawValue)
        }
    }

    private var appearance: AppearanceOption {
        AppearanceOption(rawValue: appearanceRawValue) ?? .system
    }
}

private struct PersistenceUnavailableView: View {
    let message: String?

    var body: some View {
        ContentUnavailableView {
            Label("Tasks Unavailable", systemImage: "externaldrive.trianglebadge.exclamationmark")
        } description: {
            Text("TickTask could not open the local task database. Your existing task data has not been deleted.")
        } actions: {
            if let message, !message.isEmpty {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .padding(.horizontal)
            }
        }
    }
}
