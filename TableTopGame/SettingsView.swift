import SwiftUI

/// C10: Settings sheet – sound toggle, AI delay slider. Persists via SettingsManager.
struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Audio") {
                    Toggle("Sound", isOn: $settings.soundEnabled)
                        .accessibilityIdentifier("soundToggle")
                }
                Section("AI") {
                    VStack(alignment: .leading) {
                        Text("AI delay: \(String(format: "%.1f", settings.aiDelaySeconds))s")
                            .font(.subheadline)
                        Slider(value: $settings.aiDelaySeconds, in: 0.5...3.0, step: 0.1)
                            .accessibilityIdentifier("aiDelaySlider")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
