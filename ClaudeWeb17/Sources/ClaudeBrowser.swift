import Combine
import Foundation
import UIKit
import WebKit

/// Holds one persistent WKWebView for the lifetime of the SwiftUI scene.
/// The website, not the app, owns login and authorization. We never copy tokens.
@MainActor
final class ClaudeBrowser: NSObject, ObservableObject {
    enum SessionState: Equatable {
        case unknown
        case chatReady
        case loginPage
    }

    @Published private(set) var isLoading = false
    @Published private(set) var canGoBack = false
    @Published private(set) var canGoForward = false
    @Published private(set) var pageTitle = "Claude"
    @Published private(set) var pageURL: URL?
    @Published private(set) var sessionState: SessionState = .unknown
    @Published var errorMessage: String?
    @Published var popUpWebView: WKWebView?

    let webView: WKWebView

    private var popupDelegate: PopupDelegate?

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.isInspectable = true // iOS 17; remove in production if preferred.
        open(.newChat)
    }

    enum Route {
        case newChat, projects, artifacts, customize

        var url: URL {
            let path: String
            switch self {
            case .newChat: path = "new"
            case .projects: path = "projects"
            case .artifacts: path = "artifacts"
            case .customize: path = "customize"
            }
            return URL(string: "https://claude.ai/\(path)")!
        }
    }

    func open(_ route: Route) {
        load(route.url)
    }

    func load(_ url: URL) {
        guard url.scheme == "https" else { return }
        errorMessage = nil
        sessionState = .unknown
        webView.load(URLRequest(url: url))
    }

    func refresh() { webView.reload() }
    func goBack() { if webView.canGoBack { webView.goBack() } }
    func goForward() { if webView.canGoForward { webView.goForward() } }

    /// Reads only feature-presence flags. No messages, account IDs, cookies, or tokens.
    func inspectFeatures(completion: @escaping (BridgeSnapshot?) -> Void) {
        let js = """
        (function() {
          const html = document.documentElement;
          const q = (s) => document.querySelector(s) !== null;
          return JSON.stringify({
            pageTitle: document.title || '',
            pagePath: location.pathname,
            browserFloor: html.getAttribute('data-browser-floor') || '',
            buildId: html.getAttribute('data-build-id') || '',
            hasChatEditor: q('[data-testid="chat-input"]'),
            hasSendButton: q('[data-testid="chat-input-send"]'),
            hasFileUpload: q('[data-testid="file-upload"]'),
            hasModelSelector: q('[data-testid="model-selector-dropdown"]'),
            hasSidebar: q('[data-testid="sidebar"]')
          });
        })();
        """
        webView.evaluateJavaScript(js) { value, error in
            guard error == nil, let raw = value as? String,
                  let data = raw.data(using: .utf8) else {
                completion(nil)
                return
            }
            completion(try? JSONDecoder().decode(BridgeSnapshot.self, from: data))
        }
    }

    func clearWebSession() async {
        // Clears this app's dedicated WebKit store, not Safari's website data.
        let store = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            store.removeData(ofTypes: types, modifiedSince: .distantPast) {
                continuation.resume()
            }
        }
        sessionState = .unknown
        load(Route.newChat.url)
    }

    private func updateUIState(for webView: WKWebView) {
        pageURL = webView.url
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        pageTitle = webView.title?.isEmpty == false ? (webView.title ?? "Claude") : "Claude"
    }

    private func detectSession() {
        let js = """
        (function() {
          if (document.querySelector('[data-testid="chat-input"]')) return 'chat';
          if (/\\/(login|signup|sign-in)(\\/|$)/.test(location.pathname)) return 'login';
          return 'unknown';
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let self else { return }
            switch result as? String {
            case "chat": self.sessionState = .chatReady
            case "login": self.sessionState = .loginPage
            default: self.sessionState = .unknown
            }
        }
    }
}

extension ClaudeBrowser: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        updateUIState(for: webView)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateUIState(for: webView)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        errorMessage = nil
        updateUIState(for: webView)
        detectSession()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        updateUIState(for: webView)
        errorMessage = error.localizedDescription
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        updateUIState(for: webView)
        errorMessage = error.localizedDescription
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        // Keep authentication redirects in WebKit. Open ordinary off-site links
        // externally only when user intentionally taps them.
        if navigationAction.navigationType == .linkActivated,
           let host = url.host?.lowercased(),
           host != "claude.ai", host != "www.claude.ai", 
           !host.hasSuffix(".claude.ai"),
           !host.contains("anthropic.com"),
           !host.contains("google.com"),
           !host.contains("apple.com"),
           !host.contains("microsoftonline.com") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

extension ClaudeBrowser: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }

        // Preserve opener semantics for sites that use window.open during login.
        // WKWebView passes a configuration with the same process/store here.
        let child = WKWebView(frame: .zero, configuration: configuration)
        let delegate = PopupDelegate { [weak self] in
            self?.popUpWebView = nil
            self?.popupDelegate = nil
        }
        child.navigationDelegate = delegate
        child.uiDelegate = delegate
        popupDelegate = delegate
        popUpWebView = child
        return child
    }
}

@MainActor
private final class PopupDelegate: NSObject, WKUIDelegate, WKNavigationDelegate {
    private let close: () -> Void

    init(close: @escaping () -> Void) { self.close = close }

    func webViewDidClose(_ webView: WKWebView) { close() }
}
