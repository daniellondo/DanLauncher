# Repository workflow — main only

Owner instruction recorded on 2026-09-22: all current project work belongs in `main`, and the repository must have only that working branch for review.

Status: **completed and remotely verified on 2026-09-22**. The remote branch listing contains only `main`.

## Current work

- Clone, review, and update `main`.
- Keep code, skills, AGENTS.md, SKILLS.md, and documentation synchronized in the same commits when appropriate.
- Do not create new feature or backup branches without a new instruction from Daniel.
- Preserve local work before switching checkouts. Fetch current remote state before updating; never force-push over another contributor.
- Keep changes small and reversible. Record commit IDs or make local backups for recovery instead of keeping extra remote branches.

## Consolidation record

PR #2 was merged into `main` with merge commit `926319b1d28f10efabe65841757cd9966551dc54`, preserving the current implementation and all skills/documentation through `2aac67eb41859f76c402f51f37b0194a27b74ed3`.

The superseded first prototype ends at `98e13dce48e54f832805aea326d432f17e515cf7`. Its history is retained as an additional parent of consolidation commit `c6575fb7040d8fee6ebc8f0e7f3e39b60c29e6fa`, without restoring its obsolete project files. This is an intentional history-only merge, not a claim that its old Xcode project should replace the current one.

Recovery points retained in the history of `main`:

| Historical purpose | Commit |
| --- | --- |
| Latest project, skills and Developer activation documentation before consolidation | `2aac67eb41859f76c402f51f37b0194a27b74ed3` |
| Earlier widget before app-label experiments | `ff432c528273bb13795dd63fda7845bab4eacdef` |
| Superseded first SystemShortcut prototype | `98e13dce48e54f832805aea326d432f17e515cf7` |

Inspect a historical file with `git show <commit>:<path>`; do not restore an entire old project over the current one. No application source, Xcode target, entitlement, or signing setting was changed by the consolidation follow-up.

## Completed branch cleanup

These obsolete remote branch references were deleted after verifying their commits were retained in `main`:

- `feature/native-launcher-v2`
- `backup/launcher-before-app-labels-2026-09-21`
- `feature/system-shortcut-launcher`

The connector had no direct branch-delete action. A temporary, repository-scoped GitHub Actions workflow performed the requested cleanup using the repository's job token. It verified the default branch, exact expected tips, absence of unexpected branches, branch protection, and ancestry before an atomic Git deletion with explicit expected-SHA leases. It never pushed to `main` or bypassed protection. Local Git fixture tests also verified that a changed tip rejects all deletions.

[Cleanup run 35720768743](https://github.com/daniellondo/DanLauncher/actions/runs/35720768743) completed successfully. A separate connector read of the remote branches then returned only `main`. The temporary workflow was removed in commit `b755d1878ff6dd231302eb5538f781bd5317018f`; no recurring branch-deletion automation remains in the current tree.

## Local checkouts

After saving local changes, update an existing checkout:

```sh
git fetch --prune origin
git switch main
git pull --ff-only origin main
```

Pruning removes obsolete remote-tracking refs, not local branches or local changes. If Git reports divergence or local modifications, stop and reconcile them. Do not use a hard reset or force push. Local feature branches can remain visible in Xcode until their local work is reviewed; they are not extra branches on GitHub.
