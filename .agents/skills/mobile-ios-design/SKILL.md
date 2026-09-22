---
name: mobile-ios-design
description: Design and review DanLauncher native iOS interfaces and widgets using SwiftUI, Apple platform conventions, accessibility, adaptive layouts, and system-native behavior. Use for any DanLauncher screen/widget UX, layout, navigation, typography, iconography, state, light/dark mode, Dynamic Type, or accessibility work.
---

# DanLauncher iOS Design

Build DanLauncher as a native Apple utility, not a web UI transplanted to iOS.

## Product-specific direction
- The Home Screen widget is the primary experience; the app is configuration and diagnostics.
- Use SwiftUI/WidgetKit primitives, SF Symbols, system typography, semantic colors, materials only when useful, and native controls.
- Prefer compact information density similar to first-party iOS widgets.
- Respect widget margins, rendering modes, tinted widgets, light/dark mode, Dynamic Type, VoiceOver, and minimum touch targets.
- Avoid decorative cards inside cards, excessive gradients, fake glass, tiny labels, or custom navigation when system UI works.
- Make empty/loading/error/permission states intentional.
- Category names and user-facing DanLauncher nomenclature are English.

## Review checklist
Check hierarchy, spacing, alignment, contrast, icon consistency, truncation, accessibility labels, widget-family adaptation, and whether configuration requires unnecessary manual work.

Read `docs/PROJECT.md` before changing the interaction model.
