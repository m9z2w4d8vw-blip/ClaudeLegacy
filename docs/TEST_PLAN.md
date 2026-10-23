# iOS 17 smoke test checklist

Run on an iOS 17.0+ simulator or iPhone. The source package was syntax-parsed in Linux but cannot be compiled/tested against UIKit/WebKit outside macOS Xcode.

1. **Fresh install:** Launch. The live `https://claude.ai/new` page loads inside the app; if unauthenticated, it should show Claude's real login flow.
2. **Login:** Test the actual login method. If Google OAuth rejects embedded browsers, record the visible error (not tokens) and do not assume this architecture can support that login provider.
3. **Persistence:** After login, force quit and reopen. The WebKit website data store should persist if Claude's own session remains valid.
4. **Navigation:** Check New Chat, Projects, Artifacts, Customize, backward, forward and reload.
5. **Chat:** Manually submit a message using the website composer; verify streaming and correct conversation history on the web page.
6. **File upload:** Try the website attachment picker (if supported in embedded WebKit); observe permission prompts.
7. **Diagnostics:** Check whether the current live website still exposes the saved-snapshot selectors for chat editor, send button, file uploader and model selector.
8. **Sign-out/reset:** Clear app website data via Settings. Verify the site shows an unauthenticated or fresh session. Safari sessions should be unaffected.
9. **Appearance:** Verify keyboard avoidance, safe areas, system text scaling, dark mode, OAuth popup presentation and app background/resume.
10. **Errors:** Test airplane mode, DNS failures, navigation cancellation, and restored connectivity.

Do not report a feature as functional until tested on a device. Never share saved authenticated HTML, cookies, HAR files or account credentials when filing bugs.
