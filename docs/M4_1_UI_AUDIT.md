# M4.1 interface audit

Status: Active implementation checklist  
Date: 2026-07-15

This audit keeps the redesign systematic. A surface is complete only when its
layout, typography, controls, empty/loading/error states, and both color modes
use the shared semantic system. Functional behavior is intentionally preserved.

## Visual rules

- Content-first white/charcoal canvas with neutral grouped surfaces.
- Accent color communicates an action or link, not decoration.
- Success, warning, and danger colors communicate real status only.
- No gradients, floating shadows, or nested cards unless hierarchy truly needs
  them.
- Navigation bars use the shared back and new-conversation controls.
- Buttons describe the action; destructive actions remain explicit.
- Touch targets remain at least 44 points even when the visual icon is compact.
- Light, dark, large text, keyboard, loading, empty, error, and locked states
  are part of each screen review.

## Primary product surfaces

| Surface | Current result | Follow-up |
| --- | --- | --- |
| Chat header | Shared menu/new-conversation controls and quiet semantic header | Verify long titles and large text |
| Conversation drawer | Compact search/new-chat row; Automations and Knowledge Hub share one 99-point group | Verify very long localized labels |
| Empty chat | Content-first prompt with compact composer | Verify smallest supported device |
| Conversation | Wider assistant content, quiet user bubble, visible report/action row | Golden tests for citations and streaming |
| Composer | One compact row; focused expansion; voice controls yield to Send | Physical keyboard and accessibility pass |
| `+` actions sheet | Neutral grouped actions in both themes | Audit every tool's destination screen |
| Action approvals | Content-sized confirmation surface | Golden tests for each action verb |
| Automations workspace | Renamed navigation and title; semantic list/card system | M4.5 templates and run history |
| Knowledge Hub | Flat onboarding, compact examples, semantic locked state | Redesign populated-memory edit/filter states |

## Account and settings surfaces

| Surface | Current result | Follow-up |
| --- | --- | --- |
| Settings | Compact grouped rows, neutral icons, semantic toggles and badges | Localized overflow test |
| Profile | Smaller avatar, text Save action, semantic input, flat AI insights | Free-user lock state and editing golden |
| Text Size | Neutral live chat preview and semantic slider | Max-scale clipping test |
| Voice Settings | Neutral grouped system/premium voice sections | Voice loading/error and long voice-name test |
| Usage | Compact account status and flat quota rows | Free limit/progress and reset-state golden |
| Subscription | Compact Pro status, grouped details/features, no promotional green hero | Redesign free purchase plan and store error states |
| AI Personality | Functional, but still uses old nested-card styling | Next secondary-screen slice |
| Instructions | Shared navigation; information hierarchy still needs review | Next secondary-screen slice |
| About | Functional; decorative legacy treatment remains | Next secondary-screen slice |
| Authentication | Functional and theme-aware; provider/loading/error states need visual consolidation | Next secondary-screen slice |

## Tool, media, and transient surfaces

| Surface | Audit decision |
| --- | --- |
| Upgrade/report/confirmation dialogs | Consolidate on semantic dialog and bottom-sheet patterns |
| Image generation/gallery/editing | Remove legacy gradients and normalize selection/tool bars |
| Translation | Use the same input/result spacing and citation/action treatment as chat |
| Places and map results | Highest remaining complexity; split the oversized widget before visual cleanup |
| PDF/file/document results | Normalize metadata, progress, result actions, and errors |
| Voice call | Align connection states and controls with the compact composer language |
| Snackbars/toasts | Reserve for transient system errors; successful agent actions stay conversational |

## Verification gate

Before M4.1 closes:

1. Run the full Flutter test suite and static analysis with no new errors.
2. Capture light/dark phone screenshots for every primary route.
3. Exercise large text, keyboard-open, loading, empty, error, locked, and Pro
   states where applicable.
4. Verify OAuth, chat streaming, voice playback/call, action approval, push
   deep links, and notification registration on physical iOS.
5. Run the platform-relevant subset on Android before store rollout.
