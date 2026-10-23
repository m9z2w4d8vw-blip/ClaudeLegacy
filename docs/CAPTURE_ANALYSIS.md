# User-supplied captures: structural analysis (sanitized)

Both inputs were SingleFile exports of the authenticated `https://claude.ai/new` route, saved October 23, 2026, at 14:51:01 and 14:51:13 Eastern.

Relevant, non-personal properties:

- Both report the same `data-build-id` (not copied here) and `data-browser-floor` including `safari:17,ios:17`.
- `data-mode="dark"` and page background `#191919` (hence native chrome defaults to dark).
- The prompt is a ProseMirror/Tiptap `contenteditable` element with `data-testid="chat-input"`.
- `data-testid="chat-input-send"`, `data-testid="chat-input-attach"`, and `data-testid="file-upload"` identify sending and attachment UI.
- `data-testid="model-selector-dropdown"`, `data-testid="sidebar"`, and `data-testid="sidebar-recents"` identify model control and navigation.
- User-facing navigation uses documented-by-observation paths `/new`, `/projects`, `/artifacts`, `/customize`, `/chat/<opaque-id>`.
- The two captures differ slightly in the prompt placeholder; this shows why a stable `data-testid` is preferable to placeholder text.

**Evidence boundary:** DOM selectors and paths are observations from saved, desktop-width snapshots. Mobile layout, authenticated state, successful message submission, streaming, sign-in popup behavior, and website compatibility in an actual iOS 17 WebView have **not** been verified by these files.

**Privacy:** Original captures contain real conversation titles and links. Only sanitized structural observations are retained in this repository. Don't commit the original HTML.
