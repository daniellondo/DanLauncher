---
name: context-mode
description: Keep repository and tool output context-efficient during DanLauncher development. Use for commands or workflows that can emit large build logs, diffs, searches, test output, repository listings, external CLI output, or documentation scans; prefer Context Mode tools when the active agent runtime provides them.
---

# Context Mode

Default large-output operations to Context Mode when its tools are available.

- Use `ctx_execute` or `ctx_execute_file` for builds, tests, logs, diffs, listings, searches, fetches, and external CLIs.
- Use ordinary shell only for guaranteed-small mutations/navigation such as mkdir, mv, cp, rm, touch, git add/commit/push/checkout/branch.
- Do not fail the task merely because Context Mode tools are unavailable; use the runtime's normal tools and summarize large output.
- Preserve the important evidence: errors, warnings that affect the task, changed files, test counts, and relevant API results.

For repository indexing/search, load the sibling `ctx-index` or `ctx-search` skill.
