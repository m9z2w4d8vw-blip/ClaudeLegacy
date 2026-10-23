# Architecture notes

## Phase 1 (implemented)

SwiftUI -> embedded WKWebView -> live claude.ai. The chat view is rendered by Claude's website. One `ClaudeBrowser` instance is owned by the app scene so web view and navigation state survive SwiftUI render cycles. A persistent `WKWebsiteDataStore.default()` stores the app's web session; it is not Safari's store.

Live login is driven by the real site. Popups receive WebKit-supplied `WKWebViewConfiguration` so auth flows may use opener semantics. Some identity providers disallow embedded web views regardless; the app cannot guarantee sign-in works.

The limited read-only JS inspection checks DOM feature *existence*, not chat text or cookies. Website changes may invalidate the selectors.

## Phase 2 (not yet implemented)

Native conversation UI requires a documented API or a suitably authorized bridge. No arbitrary `fetch()` calls to discovered private endpoints, no session-token export or replay, and no DOM-driven automated message submission are implemented. With Anthropic's official API, a fully native transcript and streaming composer can be built; regular consumer subscriptions do not automatically cover API billing.

## Trust boundaries

- The site owns credentials, login, sessions, inference and web UI.
- The app owns navigation controls, error display, session reset and diagnostics.
- Embedded content should never be treated as a trusted source of native app instructions.
- The original uploaded SingleFile exports remain outside source control.
