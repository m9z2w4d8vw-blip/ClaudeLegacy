import SwiftUI
import WebKit

struct BrowserShellView: View {
    @EnvironmentObject private var browser: ClaudeBrowser
    @State private var showingSettings = false
    @State private var showingDiagnostics = false
    @State private var showingNavigation = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            if browser.isLoading {
                ProgressView().progressViewStyle(.linear).tint(Color.claudeAccent)
            }
            ClaudeWebView()
                .overlay(alignment: .top) {
                    if let message = browser.errorMessage {
                        errorBanner(message)
                    }
                }
            bottomBar
        }
        .background(Color.claudeCanvas)
        .foregroundStyle(Color.claudeInk)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNavigation) {
            navigationSheet
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingDiagnostics) {
            DiagnosticsView()
        }
        .sheet(item: popupBinding) { popup in
            NavigationStack {
                PopupWebView(webView: popup.webView)
                    .navigationTitle("Sign in")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Close") { browser.popUpWebView = nil }
                        }
                    }
            }
        }
    }

    private var popupBinding: Binding<PopupIdentifiable?> {
        Binding<PopupIdentifiable?>(
            get: { browser.popUpWebView.map { PopupIdentifiable(webView: $0) } },
            set: { if $0 == nil { browser.popUpWebView = nil } }
        )
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { showingNavigation = true } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("Navigation")

            VStack(alignment: .leading, spacing: 2) {
                Text("Claude Web")
                    .font(.system(.headline, design: .rounded))
                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { browser.open(.newChat) } label: {
                Image(systemName: "square.and.pencil")
                    .frame(width: 38, height: 40)
            }
            .accessibilityLabel("New conversation")

            Button { showingSettings = true } label: {
                Image(systemName: "gearshape")
                    .frame(width: 38, height: 40)
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.claudeCanvas)
    }

    private var statusLabel: String {
        if browser.isLoading { return "Loading claude.ai…" }
        switch browser.sessionState {
        case .chatReady: return "Chat interface detected"
        case .loginPage: return "Sign in on the website"
        case .unknown: return "claude.ai"
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button { browser.goBack() } label: {
                Image(systemName: "chevron.left").frame(maxWidth: .infinity)
            }
            .disabled(!browser.canGoBack)
            .accessibilityLabel("Back")

            Button { browser.goForward() } label: {
                Image(systemName: "chevron.right").frame(maxWidth: .infinity)
            }
            .disabled(!browser.canGoForward)
            .accessibilityLabel("Forward")

            Text(browser.pageURL?.host ?? "claude.ai")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button { browser.refresh() } label: {
                Image(systemName: "arrow.clockwise").frame(maxWidth: .infinity)
            }
            .accessibilityLabel("Reload page")

            Button { showingDiagnostics = true } label: {
                Image(systemName: "stethoscope").frame(maxWidth: .infinity)
            }
            .accessibilityLabel("Diagnostics")
        }
        .font(.system(size: 17, weight: .medium))
        .padding(.horizontal, 8)
        .padding(.top, 11)
        .padding(.bottom, 7)
        .background(Color.claudeCanvas)
    }

    private var navigationSheet: some View {
        NavigationStack {
            List {
                Section("Claude website") {
                    routeRow("New chat", icon: "square.and.pencil", route: .newChat)
                    routeRow("Projects", icon: "folder", route: .projects)
                    routeRow("Artifacts", icon: "square.stack", route: .artifacts)
                    routeRow("Customize", icon: "slider.horizontal.3", route: .customize)
                }
                Section {
                    Text("Conversation history remains in Claude’s own website UI. A native conversation browser is not yet implemented.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showingNavigation = false }
                }
            }
        }
    }

    private func routeRow(_ title: String, icon: String, route: ClaudeBrowser.Route) -> some View {
        Button {
            browser.open(route)
            showingNavigation = false
        } label: {
            Label(title, systemImage: icon)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle")
            Text(message).font(.footnote).lineLimit(3)
            Spacer()
            Button { browser.errorMessage = nil } label: {
                Image(systemName: "xmark")
            }
        }
        .padding(12)
        .background(.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

private struct PopupIdentifiable: Identifiable {
    let webView: WKWebView
    var id: ObjectIdentifier { ObjectIdentifier(webView) }
}

private extension Color {
    static let claudeCanvas = Color(red: 0.098, green: 0.098, blue: 0.098)
    static let claudeInk = Color(red: 0.94, green: 0.94, blue: 0.93)
    static let claudeAccent = Color(red: 0.85, green: 0.47, blue: 0.34)
}
