# Repository workflow — main only

Owner instruction recorded on 2026-09-22: all current project work belongs in `main`, and the repository should have only that working branch for review.

## Current work

- Clone, review, and update `main`.
- Keep code, skills, AGENTS.md, SKILLS.md, and documentation synchronized in the same commits when appropriate.
- Do not create new feature or backup branches without a new instruction from Daniel.
- Preserve local work before switching checkouts. Fetch current remote state before updating; never force-push over another contributor.
- Keep changes small and reversible. Record commit IDs or make local backups for recovery instead of keeping extra remote branches.

## Consolidation record

PR #2 was merged into `main` with merge commit `926319b1d28f10efabe65841757cd9966551dc54`, preserving the current implementation and all skills/documentation through `2aac67eb41859f76c402f51f37b0194a27b74ed3`.

The superseded first prototype ends at `98e13dce48e54f832805aea326d432f17e515cf7`. Its history is retained as an additional parent of the consolidation follow-up, without restoring its obsolete project files. This is an intentional history-only merge, not a claim that its old Xcode project should replace the current one.

Recovery points retained in the history of `main`:

| Historical purpose | Commit |
| --- | --- |
| Latest project, skills and Developer activation documentation before consolidation | `2aac67eb41859f76c402f51f37b0194a27b74ed3` |
| Earlier widget before app-label experiments | `ff432c528273bb13795dd63fda7845bab4eacdef` |
| Superseded first SystemShortcut prototype | `98e13dce48e54f832805aea326d432f17e515cf7` |

Inspect a historical file with `git show <commit>:<path>`; do not restore an entire old project over the current one. No application source, Xcode target, entitlement, or signing setting is changed by the consolidation follow-up.

## Removing obsolete branch references

The following branch names are obsolete after their commits are retained in `main`:

- `feature/native-launcher-v2`
- `backup/launcher-before-app-labels-2026-09-21`
- `feature/system-shortcut-launcher`

Deleting a branch reference is a separate operation from merging its commits. Verify the current tip of each branch is an ancestor of `main` before deleting it. If a branch received new commits, preserve and review those first. Do not claim the one-branch requirement is complete until a fresh remote branch listing contains only `main`.

The connected GitHub actions used for this consolidation support merges and ref updates but not deleting branch refs. If no additional authorized Git transport is available, Daniel must remove the obsolete branch references through GitHub's Branches page or an authenticated local Git checkout. Never substitute deleting repository files for deleting Git branch refs.

## Local checkouts

After remote cleanup, `git fetch --prune origin` removes obsolete remote-tracking refs. It does not delete local branches or local changes. Switch to `main` and use `git pull --ff-only origin main`; retain any unpushed local work until reviewed.
