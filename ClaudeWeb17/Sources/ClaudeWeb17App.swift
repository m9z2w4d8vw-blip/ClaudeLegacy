import SwiftUI

@main
struct ClaudeWeb17App: App {
    @StateObject private var browser = ClaudeBrowser()

    var body: some Scene {
        WindowGroup {
            BrowserShellView()
                .environmentObject(browser)
        }
    }
}
