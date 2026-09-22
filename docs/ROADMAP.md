# Roadmap

## Phase 0 — Stable baseline
- [x] Native app and widget extension build.
- [x] Configurable SystemShortcut opens an app on-device.
- [x] Multiple app slots open independently on-device.
- [x] Category/title/background configuration prototype.
- [ ] Finish app-name/icon presentation polish.

## Phase 1 — Automatic inventory
Blocked on eligible Family Controls provisioning.
- [ ] Enable Family Controls from Xcode Signing & Capabilities with an eligible team.
- [ ] Add a diagnostic inventory screen.
- [ ] Verify installed-app count, labels, icons/tokens, and bundle identifiers on-device.
- [ ] Record entitlement/region/distribution constraints.

## Phase 2 — Classification
- [ ] Create deterministic rules for known apps.
- [ ] Add normalized category model.
- [ ] Add Uncategorized fallback.
- [ ] Add user category override.
- [ ] Persist catalog in an App Group.

## Phase 3 — Automatic category widgets
- [ ] Widget reads shared catalog.
- [ ] One widget instance selects one category.
- [ ] Grid adapts to widget family.
- [ ] Title/background/name visibility are configurable.
- [ ] Inventory changes trigger timeline reload requests.

## Phase 4 — Automatic launching
- [ ] Prove a public bridge from discovered app identity to a launch action.
- [ ] If unavailable, document the limitation and implement the lowest-friction one-time mapping fallback.
- [ ] Keep SystemShortcut fallback until replacement passes device testing.

## Phase 5 — Home Screen quality
- [ ] Native icon/name rendering.
- [ ] Empty/loading/error states.
- [ ] Accessibility and Dynamic Type review.
- [ ] Light/dark/tinted widget review.
- [ ] Install/uninstall reconciliation.
