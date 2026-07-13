import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    @State private var isShowingDeleteConfirmation = false

    @Query private var tasks: [Task]

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("App Version", value: appVersion)

                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
            }

            Section("About") {
                Text("TickTask is a minimal local to-do app built for fast, focused task capture.")
                    .foregroundStyle(AppColors.textSecondary)
            }

            Section {
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete All Tasks", systemImage: AppSymbols.delete)
                }
                .disabled(tasks.isEmpty)
            }
        }
        .navigationTitle("Settings")
        .alert("Delete All Tasks?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete All", role: .destructive) {
                deleteAllTasks()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every task stored on this device.")
        }
    }

    private func deleteAllTasks() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            for task in tasks {
                modelContext.delete(task)
            }
        }
        Haptics.warning()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
