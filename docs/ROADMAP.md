# Roadmap

## Phase 0 — Stable baseline
- [x] Native app and widget extension build.
- [x] Configurable SystemShortcut opens an app on-device.
- [x] Multiple app slots open independently on-device.
- [x] Category/title/background configuration prototype.
- [ ] Finish app-name/icon presentation polish.

## Phase 1 — Automatic inventory
Blocked on eligible Family Controls provisioning. When membership is active, follow [DEVELOPER-ACTIVATION.md](DEVELOPER-ACTIVATION.md); payment alone does not remove the runtime or launch-bridge blockers.
- [ ] Verify the enrolled team and preserve a working app/widget baseline.
- [ ] Enable Family Controls and Family Controls App and Website Usage from Xcode on the host's iOS target; verify the generated profile and signed entitlements.
- [ ] Add a minimal diagnostic inventory screen without replacing the launcher.
- [ ] Verify `approvedWithDataAccess`, installed-app count, labels, icons/tokens, and bundle identifiers on-device.
- [ ] Test denied/revoked authorization and scan errors; record actual SDK/device/install-method evidence.
- [ ] Record entitlement/region/distribution constraints.
- [ ] Run the Phase 4 public launch-bridge feasibility test before expanding automatic category UI; preserve manual launching if it fails.

## Phase 2 — Classification
- [ ] Create deterministic rules for known apps.
- [ ] Add normalized category model.
- [ ] Add Uncategorized fallback.
- [ ] Add user category override.
- [ ] Provision the same App Group on host/widget and verify a shared-container round trip.
- [ ] Persist a versioned catalog in the App Group; preserve overrides and distinguish complete scans from failed/partial scans.

## Phase 3 — Automatic category widgets
- [ ] Widget reads shared catalog.
- [ ] One widget instance selects one category.
- [ ] Grid adapts to widget family.
- [ ] Title/background/name visibility are configurable.
- [ ] Inventory changes trigger timeline reload requests after the snapshot is saved.
- [ ] Document actual synchronization triggers and retain user-driven Home Screen placement; do not promise an instant install observer.

## Phase 4 — Automatic launching
- [ ] Prove a public bridge from discovered app identity to a launch action.
- [ ] If unavailable, document the limitation and implement the lowest-friction one-time mapping fallback after explicit product acceptance.
- [ ] Keep SystemShortcut fallback until replacement passes device testing.

## Phase 5 — Home Screen quality
- [ ] Native icon/name rendering.
- [ ] Empty/loading/error states.
- [ ] Accessibility and Dynamic Type review.
- [ ] Light/dark/tinted widget review.
- [ ] Install/uninstall reconciliation.

## Distribution gate — only when distribution is requested
- [ ] Check the Family Controls distribution request and permitted provisioning methods.
- [ ] Verify App and Website Usage separately for the chosen delivery method and supported region/account combination.
- [ ] Record TestFlight/customer behavior independently of successful Xcode development testing.

Use the acceptance-record template in [DEVELOPER-ACTIVATION.md](DEVELOPER-ACTIVATION.md). No new device-dependent item is marked complete by this documentation update.
