---
name: brainstorming
description: Explore product, UX, architecture, and implementation options for DanLauncher before committing to a solution. Use for ambiguous features, new flows, technical blockers, competing approaches, or major design decisions where divergent ideas and explicit tradeoffs should be considered before coding.
---

# Brainstorming

Explore before implementing when the problem has meaningful uncertainty.

1. Restate the concrete goal and constraints from `docs/PROJECT.md` and `AGENTS.md`.
2. Separate facts already validated on-device from assumptions and open questions.
3. Generate multiple materially different approaches; do not produce cosmetic variants of the same idea.
4. Compare approaches on native iOS feasibility, public-API compliance, user friction, maintainability, widget UX, entitlement/signing requirements, and testability.
5. Identify the smallest experiment that can invalidate the riskiest assumption.
6. Recommend an implementation direction only after tradeoffs are visible.
7. Record important architectural decisions or newly discovered limitations in project documentation.

For DanLauncher, preserve validated `SystemShortcut` launching while brainstorming automatic discovery/launch alternatives. Never propose private APIs as a production solution.
