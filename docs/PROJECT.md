# DanLauncher

## Product vision
DanLauncher is a native iOS Home Screen launcher focused on automatic organization. The desired experience is similar in density and simplicity to Apple's Suggestions widget, but organized into explicit categories.

The target flow is:
1. Detect installed apps using public APIs where entitlement/signing permits.
2. Identify each app reliably.
3. Classify apps automatically.
4. Store a shared category inventory.
5. Let the user add one DanLauncher widget per category.
6. Render native-looking app icons/names.
7. Open the selected app directly.
8. Reconcile installs/uninstalls and refresh widgets with minimal user work.

## UX requirements
- Category names are English.
- One reusable widget configuration can represent different categories.
- Title and background should eventually be configurable.
- App-name visibility is a desired optional setting.
- Manual per-app setup is transitional, not the final UX.
- `Uncategorized` is the fallback for unknown apps.
- The UI should prioritize native iOS conventions over custom visual chrome.

## Current validated behavior
On the development iPhone, a configurable WidgetKit widget can accept multiple `SystemShortcut` values. A `Button(intent: RunSystemShortcutIntent(shortcut: ...))` opens the selected app. This is the current known-good launch mechanism.

## Current blocker
The project is currently signed with a Personal Development Team. Xcode did not offer Family Controls in Add Capability for that team, and manually adding Family Controls entitlements caused provisioning failures. Automatic installed-app discovery via Family Controls must therefore remain gated until an eligible signing team/profile is available.

## Non-goals
- Private iOS APIs.
- Jailbreak-only behavior.
- Pretending third-party apps have the same system privileges as Apple's Suggestions widget.
- Network icon lookup as a substitute for true installed-app identity unless explicitly used as a cosmetic fallback.

## Initial category taxonomy
Suggestions, Banking, Payments, Crypto, Trading, Smart Home, Work, AI, Security, Communication, Social, Travel, Transportation, Shopping, Food & Dining, Entertainment, Health & Fitness, Utilities, Uncategorized.

This taxonomy can evolve as automatic classification improves.
