# DanLauncher — Agent Guide

## Mission
Build a native iOS launcher that organizes the user's installed apps into category widgets with an Apple-native experience. The end state is: discover apps -> classify them -> persist a category inventory -> render category widgets -> launch an app with the least manual configuration allowed by public iOS APIs.

## Current reality
- Native SwiftUI app + WidgetKit extension.
- Deployment target is iOS 27.
- Widget direct launching through AppIntents `SystemShortcut` + `RunSystemShortcutIntent` has been validated on a real iPhone.
- Family Controls automatic installed-app discovery is the intended research path, but the current Personal Development Team cannot provision the required Family Controls capabilities. Do not re-add those entitlements until signing supports them.
- Do not use private APIs.
- Preserve working launcher behavior while experimenting.

## Agent operating rules
1. Read `docs/PROJECT.md`, `docs/ARCHITECTURE.md`, and `docs/ROADMAP.md` before architectural changes.
2. Inspect current code before editing. Do not infer APIs or types from old commits.
3. For new/changed Apple APIs, verify current Apple documentation before implementation.
4. Keep experiments isolated and reversible. Never replace a device-validated path until its replacement works on-device.
5. Prefer native SwiftUI, WidgetKit, AppIntents, SF Symbols, semantic colors, Dynamic Type, accessibility, and system behaviors.
6. UI should feel like an Apple first-party utility: compact, quiet, functional, adaptive to light/dark mode.
7. Treat the Home Screen widget as the primary product surface; the host app is configuration/diagnostics.
8. Category and product-facing nomenclature is English.
9. Never claim automatic app discovery or arbitrary app launching works until validated on the physical iPhone.
10. Keep documentation synchronized with important findings and limitations.

## Skills
Repository-local agent skills live under `.agents/skills/`. Load the smallest relevant skill:
- `context-mode`: large-output/context-efficient repository work.
- `ctx-index` and `ctx-search`: index/search project context when the runtime provides Context Mode MCP tools.
- `mobile-ios-design`: SwiftUI/iOS UX and HIG work.
- `swiftui-design`: visual polish/review for SwiftUI.

These are vendored project instructions; tool availability depends on the agent runtime.

## Definition of done
A change is not complete merely because it compiles. For user-facing launcher work: build succeeds, existing launcher actions are preserved, UI is checked in relevant widget sizes, and device-dependent behavior is explicitly marked pending until Daniel validates it on his iPhone.
