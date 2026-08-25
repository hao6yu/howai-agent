# Changelog

## 2.0.5+50 — 2026-08-25

### Fixed

- Prevented early taps or vertical scrolling from freezing the conversation
  drawer while its opening spring is still moving.
- Prevented streaming responses from pulling readers back to the latest message
  after they intentionally scroll upward.
- Removed an incorrect reverse-list offset correction that could make older
  message pagination jump.

### Improved

- Made long conversation histories render lazily, including archived rows, for
  smoother drawer opening and scrolling.
- Debounced local message-content search and reduced redundant conversation
  provider rebuilds.
- Isolated live response updates to the chat list, added smooth bottom
  following and a latest-message control, and polished loading, selection, and
  typing transitions with reduced-motion support.
- Added regression coverage for mid-animation drawer interaction and
  thousand-conversation drawer histories.

## 2.0.3+48 — 2026-08-08

### Fixed

- Prevented photo-first conversations from returning to the new-chat screen
  during background synchronization.
- Prevented stale remote snapshots from deleting conversations uploaded while
  synchronization is in flight.
- Kept streamed chat requests active until completion and routed photo analysis
  through the complete-response path.

### Improved

- Reduced memory pressure from full-resolution pending-photo thumbnails.
- Added localized provisional titles for photo-only conversations.
- Made Edge Function release checks deterministic and Android release signing
  fail closed.
- Added focused regression coverage and a `2.0.3` release runbook.
