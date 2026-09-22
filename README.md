# DanLauncher

DanLauncher is a native iOS launcher experiment for organizing Home Screen apps into category-based widgets.

The product goal is an Apple-native flow where installed apps are discovered, classified, and surfaced automatically in widgets such as Banking, Travel, Smart Home, AI, and Utilities. The project uses SwiftUI, WidgetKit, and AppIntents and targets iOS 27.

## Status
The current device-validated launcher uses `SystemShortcut` with `RunSystemShortcutIntent`. Automatic installed-app discovery is planned through public Family Controls APIs, but is currently blocked because the active Personal Development Team cannot provision the required capability.

See:
- `AGENTS.md` for agent instructions.
- `docs/PROJECT.md` for product requirements and known limitations.
- `docs/ARCHITECTURE.md` for technical direction.
- `docs/ROADMAP.md` for implementation phases.
- [Apple Developer activation runbook](docs/DEVELOPER-ACTIVATION.md) for the exact steps after membership becomes active, capability/profile checks, device tests, and distribution limits.
- `.agents/skills/` for repository-local agent skills.

## After Apple Developer enrollment
Follow [docs/DEVELOPER-ACTIVATION.md](docs/DEVELOPER-ACTIVATION.md) before restoring automatic discovery. Membership, signing, runtime authorization, and a public launch bridge are separate gates. This is a future implementation checklist, not a claim that purchasing membership completes Home Screen automation.

## Principles
Public iOS APIs only. Preserve device-validated behavior. Verify new Apple APIs before relying on them. Keep the Home Screen widget as the primary experience and the host app as configuration/diagnostics.
