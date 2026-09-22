# DanLauncher Skills

This repository includes project-local agent skills. Any coding agent, AI assistant, or contributor working from a clone should read this file together with `AGENTS.md` before changing the project.

## Required skill usage

Use the repository-local skills under `.agents/skills/` whenever the task matches them:

| Skill | Use it for |
| --- | --- |
| `context-mode` | Builds, tests, logs, diffs, searches, repository inspection, or any operation that can produce large output. Prefer Context Mode tools when the agent runtime provides them. |
| `ctx-index` | Indexing the DanLauncher repository for broad architectural/codebase understanding when Context Mode indexing is available. |
| `ctx-search` | Searching indexed DanLauncher context efficiently instead of repeatedly loading large files. |
| `mobile-ios-design` | Any iOS UX/UI, widget layout, accessibility, Dynamic Type, navigation, native controls, light/dark mode, or Apple-platform design work. |
| `swiftui-design` | SwiftUI/WidgetKit visual implementation and polish, especially app grids, category widgets, configuration screens, and rendering modes. |

## Agent startup sequence

Before implementing a non-trivial change:

1. Read `AGENTS.md`.
2. Read `docs/PROJECT.md`.
3. Read `docs/ARCHITECTURE.md` for architecture/API changes.
4. Read `docs/ROADMAP.md` to understand current phase and blockers.
5. Load the smallest relevant skill(s) from `.agents/skills/`.
6. Inspect the current implementation before editing.
7. Verify current Apple documentation before relying on new or changed Apple APIs.

## Important

These skills are repository instructions, not a guarantee that every agent runtime exposes the same tools. If a skill references a tool such as Context Mode and that tool is unavailable, follow the intent of the skill using the runtime's available tools rather than blocking the task.

Do not bypass the constraints documented in `AGENTS.md`: public iOS APIs only, preserve device-validated behavior, and do not claim device-dependent behavior works until it has been tested on Daniel's iPhone.
