---
name: ctx-index
description: Index the DanLauncher repository for efficient semantic project lookup. Use when an agent needs broad understanding of the codebase, architecture, documentation, or a feature spanning many files and Context Mode indexing tools are available.
---

# Context Mode Index

Prefer `ctx_index` when available.

Index from the repository root with source `project:DanLauncher`, conservative depth/file limits, and path-based input so file bytes do not flood context. Re-index after substantial architecture/documentation changes. If the tool is unavailable, inspect only the smallest relevant file set.
