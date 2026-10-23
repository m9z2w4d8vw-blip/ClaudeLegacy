import SwiftUI

struct DiagnosticsView: View {
    @EnvironmentObject private var browser: ClaudeBrowser
    @Environment(\.dismiss) private var dismiss
    @State private var snapshot: BridgeSnapshot?
    @State private var didRun = false

    var body: some View {
        NavigationStack {
            List {
                Section("Current page") {
                    labeled("URL", browser.pageURL?.absoluteString ?? "Unknown")
                    labeled("Title", browser.pageTitle)
                    labeled("Session", sessionLabel)
                }
                Section("DOM feature detection") {
                    if let snapshot {
                        feature("Chat editor", snapshot.hasChatEditor)
                        feature("Send button", snapshot.hasSendButton)
                        feature("File uploader", snapshot.hasFileUpload)
                        feature("Model selector", snapshot.hasModelSelector)
                        feature("Sidebar", snapshot.hasSidebar)
                        labeled("Build ID", snapshot.buildId)
                        labeled("Website browser floor", snapshot.browserFloor)
                    } else {
                        Text(didRun ? "Inspection failed; check whether this page permits JavaScript." : "Run inspection to check whether current website elements match the supplied captures.")
                            .foregroundStyle(.secondary)
                    }
                    Button("Inspect current page") { inspect() }
                }
                Section {
                    Text("Diagnostics checks only whether interface elements exist. It does not read chat text or export authentication cookies. This is not proof that native chat streaming is implemented.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .onAppear { inspect() }
        }
    }

    private var sessionLabel: String {
        switch browser.sessionState {
        case .chatReady: return "Chat UI detected"
        case .loginPage: return "Login screen detected"
        case .unknown: return "Unverified"
        }
    }

    private func inspect() {
        didRun = true
        browser.inspectFeatures { snapshot = $0 }
    }

    private func feature(_ label: String, _ available: Bool) -> some View {
        HStack {
            Text(label)
            Spacer()
            Image(systemName: available ? "checkmark.circle.fill" : "minus.circle")
                .foregroundStyle(available ? Color.green : Color.secondary)
        }
    }

    private func labeled(_ key: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key).font(.caption).foregroundStyle(.secondary)
            Text(value.isEmpty ? "Not available" : value)
                .font(.footnote)
                .textSelection(.enabled)
        }
    }
}
