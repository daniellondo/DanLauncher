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
- `.agents/skills/` for repository-local agent skills.

## Principles
Public iOS APIs only. Preserve device-validated behavior. Verify new Apple APIs before relying on them. Keep the Home Screen widget as the primary experience and the host app as configuration/diagnostics.
