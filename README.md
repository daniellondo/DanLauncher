# DanLauncher

DanLauncher is a native iOS launcher experiment for organizing Home Screen apps into category-based widgets.

The product goal is an Apple-native flow where installed apps are discovered, classified, and surfaced automatically in widgets such as Banking, Travel, Smart Home, AI, and Utilities. The project uses SwiftUI, WidgetKit, and AppIntents and targets iOS 27.

## Review and development branch
**Use `main`.** The code, repository-local skills, agent instructions, and project documentation are consolidated in the default branch. There is no separate feature branch to check out for the current project. Future work stays on `main` unless Daniel explicitly requests a different workflow.

For a new checkout:

```sh
git clone --branch main https://github.com/daniellondo/DanLauncher.git
cd DanLauncher
```

For an existing checkout, save local changes first, then:

```sh
git fetch --prune origin
git switch main
git pull --ff-only origin main
```

If Git reports local changes or divergent history, stop and reconcile them; do not use a hard reset or force push. See [repository workflow and historical recovery points](docs/REPOSITORY-WORKFLOW.md).

## Status
The current device-validated launcher uses `SystemShortcut` with `RunSystemShortcutIntent`. Automatic installed-app discovery is planned through public Family Controls APIs, but is currently blocked because the active Personal Development Team cannot provision the required capability.

See:
- `AGENTS.md` for agent instructions.
- `SKILLS.md` for which repository-local skills to use and when.
- `docs/PROJECT.md` for product requirements and known limitations.
- `docs/ARCHITECTURE.md` for technical direction.
- `docs/ROADMAP.md` for implementation phases.
- [Apple Developer activation runbook](docs/DEVELOPER-ACTIVATION.md) for the exact steps after membership becomes active, capability/profile checks, device tests, and distribution limits.
- `.agents/skills/` for repository-local agent skills.

## After Apple Developer enrollment
Follow [docs/DEVELOPER-ACTIVATION.md](docs/DEVELOPER-ACTIVATION.md) before restoring automatic discovery. Membership, signing, runtime authorization, and a public launch bridge are separate gates. This is a future implementation checklist, not a claim that purchasing membership completes Home Screen automation.

## Principles
Public iOS APIs only. Preserve device-validated behavior. Verify new Apple APIs before relying on them. Keep the Home Screen widget as the primary experience and the host app as configuration/diagnostics.
