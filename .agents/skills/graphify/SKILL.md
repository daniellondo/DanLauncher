---
name: graphify
description: Build and use a navigable knowledge graph of the DanLauncher repository for broad architecture discovery, dependency exploration, impact analysis, and agent onboarding. Use when a task spans unfamiliar parts of the codebase or benefits from GraphRAG-style relationships; do not replace direct source/test verification for final conclusions.
---

# Graphify

Use the upstream Graphify workflow from `graphify-labs/graphify` when Graphify is installed in the active agent environment.

Upstream installation reference:

```sh
npx skills add https://github.com/graphify-labs/graphify --skill graphify
```

Graphify turns a folder into an interactive knowledge graph, GraphRAG-ready JSON, and a plain-language graph report.

## DanLauncher rules

- Graph the repository root when broad architecture understanding is needed.
- Use Graphify for discovery: components, relationships, clusters, dependencies, and likely impact areas.
- Prefer an existing fresh graph over regenerating it unnecessarily.
- Regenerate after substantial architecture changes.
- Exclude generated/build artifacts and secrets.
- Treat graph output as navigation evidence, not source-of-truth proof.
- Verify material implementation conclusions against the current Swift source, project settings, tests/builds, and `docs/`.
- Never let stale graph data override device-validated behavior documented in `AGENTS.md`.
- If Graphify is unavailable, continue with Context Mode/index/search or direct repository inspection rather than blocking the task.

Read `AGENTS.md` and `docs/ARCHITECTURE.md` before using graph findings to propose architectural changes.
