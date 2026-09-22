---
name: swiftui-design
description: Polish or critique DanLauncher SwiftUI and WidgetKit presentation so it feels intentionally designed rather than generic. Use when creating a new visual surface, improving icon grids, category widgets, configuration screens, or reviewing UI quality before device validation.
---

# SwiftUI Design Quality

Use a restrained, native visual language.

1. Establish a clear hierarchy before decoration.
2. Align to a small spacing rhythm and consistent icon geometry.
3. Prefer semantic system colors and typography.
4. Make the app grid visually scannable; icon identity is more important than ornamental containers.
5. Keep labels optional where the product allows, but preserve accessibility names.
6. Test small/medium widget constraints and text truncation.
7. Verify light, dark, and tinted rendering.
8. Remove visual elements that do not improve recognition or interaction.

Before shipping UI changes, compare the result against the product goal in `docs/PROJECT.md` and the agent rules in `AGENTS.md`.
