# Claude Web 17 — iOS 17+ Starter

An **unofficial, personal** iOS 17+ SwiftUI application that opens the real `claude.ai` website in persistent WebKit storage. No API keys, session-cookie exports, or unsupported private endpoints. The browser renders the chat; native SwiftUI provides the surrounding navigation, status and diagnostics.

**Status:** source-code starter; not yet compiled/tested on an actual iOS device. Authentication through certain identity providers may be blocked in embedded browsers. The official Claude API is the supported solution if you later need a fully native message renderer.

## What's implemented

- Minimum deployment target iOS **17.0**; Swift 5.9, SwiftUI, WebKit.
- Website chat rendering and interaction through a persistent `WKWebView`.
- Native new chat, Projects, Artifacts, Customize, back/forward, reload.
- Persistent website cookie/data store via `WKWebsiteDataStore.default()`; the app does **not** read or export cookies.
- Support for popup-window sign-in attempts using a second WebView with WebKit-provided configuration.
- Native web session reset button (only this app's WebKit store, not Safari).
- Read-only JavaScript bridge diagnostics: page build ID, browser floor and feature-presence checks based on two October 23, 2026 Claude HTML captures.
- GitHub Actions builds an **unsigned IPA** on pushes to `main` or `master`, PRs, and manual dispatch; optional direct-download GitHub Releases are supported.

## Not yet implemented

- Fully native message transcript and editor; streaming bridge; native conversation list; voice assistant mode.
- Guaranteed OAuth sign-in (Google and other providers may block embedded WebViews).
- Signed, directly installable IPA or Apple App Store distribution.

## Build on GitHub (Windows-friendly)

1. Create a new repository and upload **the contents of this folder**, including the hidden `.github` directory. Keep `project.yml` and `.github/workflows/build-ios.yml` at the repository root.
2. Push to `main` or `master`, or select **Actions → Build iOS IPA → Run workflow**. A macOS runner will generate the project and compile an iPhone-device build.
3. On a successful run, download the Actions artifact to get `ClaudeWeb17-iOS17-<commit>-unsigned.ipa`. GitHub's Actions artifact download is wrapped in a ZIP.
4. To download the `.ipa` **directly** from GitHub Releases, select `publish_release` during a manual run, or push a `v*` tag.
5. The IPA is **unsigned**. Install using a compatible signing/sideloading method, and test authentication on your device.

**Detailed instructions:** [`docs/GITHUB_ACTIONS.md`](docs/GITHUB_ACTIONS.md).

## Build in Xcode

On macOS with Xcode 15+:

```bash
brew install xcodegen
xcodegen generate --spec project.yml
open ClaudeWeb17.xcodeproj
```

Select the app target, replace `PRODUCT_BUNDLE_IDENTIFIER` with your own unique identifier, configure Signing & Capabilities and build for a device or simulator.

## Project layout

```
ClaudeWeb17/
  project.yml
  ClaudeWeb17/Sources/
    ClaudeWeb17App.swift         SwiftUI entry point
    ClaudeBrowser.swift          WebKit session, navigation and popup handling
    ClaudeWebView.swift          UIViewRepresentable wrappers
    BrowserShellView.swift       Native controls and navigation
    BridgeSnapshot.swift         Diagnostic model
    DiagnosticsView.swift        Read-only page inspection
    SettingsView.swift           Reset app website data
  ClaudeWeb17/Resources/Assets.xcassets
  .github/workflows/build-ios.yml
  docs/CAPTURE_ANALYSIS.md
```

## Security and limits

The uploaded SingleFile HTML snapshots were **not included** in this repository because they contained personal conversation titles and account-facing content. Do not commit saved authenticated pages, cookies, HAR exports, tokens, or private account data. Session authentication remains under `claude.ai` inside WebKit. A login page can appear naturally on first launch; **login HTML is not required**.

Embedding an external consumer site is not an official Anthropic integration. Page layout and login flows may change. The diagnostics bridge only checks DOM element existence; no private API calls or automated chat submission are implemented here.
