import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var browser: ClaudeBrowser
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var clearing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    LabeledContent("App", value: "Claude Web 17")
                    LabeledContent("Minimum iOS", value: "17.0")
                    Text("Unofficial personal WebKit client. Chat content and authentication are provided by claude.ai, not by this application.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Authentication") {
                    Text("The web view keeps its own persistent cookies. It does not extract session tokens or share Safari's cookie jar.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Clear app website data", role: .destructive) { confirmReset = true }
                        .disabled(clearing)
                }
                Section("Known limits") {
                    Text("A native chat list, native composer, streaming bridge, and native voice mode are not implemented in this starter. Those require additional integration and device testing.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .confirmationDialog("Clear this app's WebKit session?", isPresented: $confirmReset) {
                Button("Clear and reload", role: .destructive) {
                    clearing = true
                    Task {
                        await browser.clearWebSession()
                        clearing = false
                        dismiss()
                    }
                }
            } message: {
                Text("This removes website data stored by this app and may sign you out. Safari data is unaffected.")
            }
        }
    }
}
