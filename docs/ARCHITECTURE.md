# Architecture

## Targets
### DanLauncher
SwiftUI host application. Long-term responsibilities:
- authorization and diagnostics;
- installed-app inventory when public API/signing permits;
- classification and user overrides;
- persistence/shared state;
- requesting WidgetKit reloads when inventory changes.

### WidgetLauncherExtension
WidgetKit/AppIntents extension. Current responsibilities:
- widget configuration;
- category/title/background presentation;
- app slots;
- direct app actions through `RunSystemShortcutIntent`.

## Intended data flow
```
Public installed-app source
        |
        v
 Inventory / identity
        |
        v
 Classification engine ----> User overrides
        |
        v
 Shared persisted catalog
        |
        v
 Widget timeline provider
        |
        v
 Category widget grid
        |
        v
 Public launch mechanism
```

## Proven launch path
`SystemShortcut?` is selected in widget configuration and passed to `RunSystemShortcutIntent`. Multiple independent buttons in a widget have been validated on-device.

## Discovery research
The desired discovery path is Apple's Family Controls / FamilyActivityData installed-app APIs on iOS 27. This is capability- and authorization-dependent. The current Personal Team cannot provision the required entitlement, so discovery code must not be merged into the active path until signing is solved.

Even after discovery works, app identity/token availability does not automatically prove a public generic launch bridge. Treat discovery and launching as separate experiments.

## Persistence direction
When automatic inventory is enabled, use an App Group shared container so host app and widget extension read the same catalog. Persist stable identifiers, category, optional display metadata, user override, and last-seen state. Avoid storing opaque values unless Apple documents them as persistable/codable for this use.

## Refresh direction
Reconcile inventory when the host app becomes active and whenever another permitted trigger exists. On a detected catalog change, request a WidgetKit timeline reload. Widget refresh timing remains system-budgeted; never promise immediate background install detection unless demonstrated.

## Safety rails
- Public SDK only.
- No UIApplication/private workspace enumeration.
- No undocumented bundle-launch APIs.
- Do not remove the proven SystemShortcut path until a replacement is device-validated.
