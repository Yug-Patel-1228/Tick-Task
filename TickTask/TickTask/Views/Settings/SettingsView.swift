import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext) private var modelContext
    @AppStorage("appearance") private var appearanceRawValue = AppearanceOption.system.rawValue
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("defaultPriority") private var defaultPriorityRawValue = Priority.medium.rawValue
    @AppStorage("defaultCategory") private var defaultCategoryRawValue = Category.personal.rawValue
    @State private var isShowingDeleteConfirmation = false
    @State private var notificationPermissionMessage: String?

    @Query private var tasks: [Task]

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Appearance", selection: $appearanceRawValue) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.rawValue).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("AppearancePicker")
            }

            Section("Haptics") {
                Toggle("Enabled", isOn: $hapticsEnabled)
                    .accessibilityIdentifier("HapticsToggle")
            }

            Section("Defaults") {
                Picker("Default Priority", selection: $defaultPriorityRawValue) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Label(priority.rawValue, systemImage: AppSymbols.flag)
                            .tag(priority.rawValue)
                    }
                }
                .accessibilityIdentifier("DefaultPriorityPicker")

                Picker("Default Category", selection: $defaultCategoryRawValue) {
                    ForEach(Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.symbol)
                            .tag(category.rawValue)
                    }
                }
                .accessibilityIdentifier("DefaultCategoryPicker")
            }

            Section("Notifications") {
                Button {
                    Swift.Task {
                        let granted = await NotificationService.shared.requestPermission()
                        notificationPermissionMessage = granted ? "Notifications are enabled." : "Notifications are not enabled."
                        Haptics.selection()
                    }
                } label: {
                    Label("Request Permission", systemImage: AppSymbols.bell)
                }

                if let notificationPermissionMessage {
                    Text(notificationPermissionMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Section("Information") {
                LabeledContent("App Version", value: appVersion)

                LabeledContent("About") {
                    Text("A minimal local to-do app built for fast, focused task capture.")
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Data") {
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
                NotificationService.shared.cancelNotification(for: task)
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
