# Apple Developer activation and automatic-inventory runbook

Status: **pending membership/profile verification and physical-device testing**.
Apple references checked: **2026-09-22**. Repository baseline inspected: `22c05a9b434558cec88537bc68930bd099fe49ab` on `feature/native-launcher-v2`.

Use this runbook when Daniel says his Apple Developer Program membership is active. It describes future work; adding this document does not enable capabilities, restore discovery code, or certify that automatic organization works.

Read [PROJECT.md](PROJECT.md), [ARCHITECTURE.md](ARCHITECTURE.md), [ROADMAP.md](ROADMAP.md), [AGENTS.md](../AGENTS.md), and [SKILLS.md](../SKILLS.md) first. Keep user-facing category names and controls in English.

## 1. Separate the gates

Do not treat a payment receipt as proof that every gate has passed:

| Gate | Required evidence |
| --- | --- |
| Membership | Active Apple Developer Program enrollment and the corresponding team accessible in Xcode. |
| Signing | The app's generated provisioning profile and signed executable permit the required entitlements. |
| Runtime data access | The physical device grants `approvedWithDataAccess` and the inventory request succeeds. |
| Launching | A public, device-tested way to launch a discovered app. Enumeration alone does not supply this. |
| Distribution | Permissions and regional eligibility verified for the actual delivery method, separately from Xcode development builds. |

Apple makes capabilities dependent on platform/membership and distinguishes development support from distribution approval. An eligible membership is a prerequisite for this investigation, **not a guarantee that the complete launcher design or its distribution will be approved**. [A1][A2][A6]

Project evidence: multiple widget buttons using `SystemShortcut` and `RunSystemShortcutIntent` were reported working by Daniel on his iPhone. The Personal Team rejected the experimental Family Controls signing configuration; that experiment was removed. Preserve the working launch path. Do not restore the entire old experiment or recreate the Xcode project.

## 2. Daniel: activate the team and establish a baseline

1. Confirm enrollment is active in the Apple Developer account, not merely submitted or paid. Complete any outstanding account verification or agreements.
2. In Xcode Settings, open the account-management pane (Accounts/Apple Accounts, depending on Xcode), sign in or refresh the account, and verify the enrolled team is available. Do not assume its Team ID must differ from the previous one; verify membership and profile eligibility.
3. Save local changes, record the current commit, and preserve a recovery branch before modifying signing. Continue from the latest reviewed project, not a stale experimental checkout. Keep the known-good app/widget installed unless a specific migration problem requires removal; deletion loses widget configuration.
4. In `DanLauncher.xcodeproj`, select each existing target's **Signing & Capabilities** tab. Use the enrolled team and **Automatically manage signing** for both targets:
   - `DanLauncher`: `com.daniellondospi.DanLauncher`
   - `WidgetLauncherExtension`: `com.daniellondospi.DanLauncher.WidgetLauncher`
5. Preserve these identifiers when the enrolled team can register/use them. If an identifier ownership conflict appears, resolve it explicitly before renaming anything. Do not delete targets, certificates, or the repository as a workaround.
6. Select the **DanLauncher** app scheme and the connected physical iPhone. Run with **Product > Run**; Build alone does not install the app. Confirm existing widget actions still open the intended apps before enabling discovery.

These target names and identifiers come from the inspected project. Xcode's capability/signing workflow is documented in [A2]; the exact account UI must be checked in the installed Xcode version.

**Gate:** both targets sign, the app installs, and the previously working launch actions remain usable. The agent must record the commit and actual SDK/device versions, not infer success from a screenshot of a template.

## 3. Daniel + agent: enable only the required capabilities

Start with the **DanLauncher app target**, for its **iOS** configuration:

1. Open **Signing & Capabilities > + Capability** and enable **Family Controls**.
2. Enable **Family Controls App and Website Usage**, the additional data-access capability.
3. Let Xcode update the entitlement file and signing resources. Inspect the generated app profile and signed app, not just the text of the entitlement file. The relevant keys are:

```text
com.apple.developer.family-controls
com.apple.developer.family-controls.app-and-website-usage
```

The second key is required to use non-tokenized activity data; plain Family Controls authorization is not sufficient. [A3][A4]

If capabilities are missing or signing fails, stop here. Check the selected iOS target, platform filters, current SDK support, enrolled team, account roles, App ID capability status, and provisioning refresh. A **No Matches** search result alone does not identify the cause. Do not force entitlements into an ineligible profile. Capture the precise error and contact Apple Developer Support when account provisioning remains blocked.

Do not add Screen Time monitor/report/shield targets just to enumerate apps. Do not add Family Controls to the widget extension speculatively. Add privileges to another target only when a documented API used by that target requires them; validate its profile independently. App Groups are introduced later for sharing the permitted catalog.

**Gate:** the installed host app is signed with both required entitlements. No entitlement/profile files, certificates, private keys, or account credentials should be committed as diagnostic evidence.

## 4. Agent: restore a minimal authorization/inventory probe

Implement an isolated host-app diagnostic screen, not a replacement widget. Recheck API availability in the installed SDK before coding. Keep UI state updates on the appropriate actor and import the frameworks needed by the chosen observation mechanism. Do not copy old code solely because it once existed in Git.

The probe must:

- Explain why app inventory is requested and offer an explicit **Authorize & Scan** action.
- Request individual authorization using `AuthorizationCenter.shared.requestAuthorization(for: .individual)`, then inspect the actual status. This is an API sequence to implement, not code already restored by this documentation update. [A5]
- Fetch `try await FamilyActivityData.shared.installedApplications` only after data access is approved. Apple documents an asynchronous, throwing array of applications carrying `bundleIdentifier` and `token`. [A4][A7]
- Display authorization status, last successful scan, total returned records, records with usable identifiers, and any typed error. Do not silently discard missing identifiers and then claim all apps were found.
- Show a small sample of names/icons using documented token-based presentation where available; validate that separately from text extraction. Do not use reflection/private APIs to resolve identity.

Treat status explicitly:

| Status/result | Required behavior |
| --- | --- |
| `notDetermined` | Explain access and wait for a user-initiated request. |
| `denied` or cancellation | Keep the manual launcher; do not repeatedly prompt. |
| `approved` | Explain that management authorization exists but raw inventory access has not been demonstrated. |
| `approvedWithDataAccess` | Attempt the inventory request and handle its actual result. |
| Error, restriction, or unsupported environment | Show the reason; preserve the working launcher. Do not report an empty device. |

Apple says only one app at a time can hold this data-access status, so explain possible displacement of another app's authorization before requesting it. Development testing is documented for all regions with an Apple-provided provisioning profile; customer access requires both an EU device location and an EU Apple Account region. Do not suggest account/region spoofing, or assume TestFlight behaves like an Xcode install. [A4]

**Gate:** on Daniel's physical iPhone, permission and a successful scan are observed, representative returned identifiers match known installed apps, and failures remain distinguishable from a legitimately empty result. Record this as a new result, not as an already-completed feature.

## 5. Agent: test the launch bridge before expanding the product

Discovery and launching are independent gates. `SystemShortcut` represents a user-configured action; the documented `RunSystemShortcutIntent` initializer consumes that action. The referenced APIs do not establish a constructor from an arbitrary bundle ID or Family Controls token. [A8]

Run a separate, minimal experiment using a discovered app. It must identify a **documented public launch mechanism** and prove the intended app opens on-device. Do not manufacture `SystemShortcut` objects, use private workspace selectors, guess bundle-launch URLs, or infer executability from the availability of an icon.

If no generic public bridge is available, keep the working user-selected SystemShortcut widgets. Present the limitation and design the lowest-friction explicit mapping fallback with Daniel; mark it as partial automation, not as install-and-forget completion. Do not delay reporting this blocker while building many category screens.

## 6. Agent: classification and shared storage, after inventory is proven

The following are planned DanLauncher implementation requirements, not additional capabilities granted by membership:

1. Use stable bundle identifiers as identity. Prefer exact rules and explicit user overrides over broad substring matching. Keep `Uncategorized` for unknowns. Test overlapping concepts such as crypto wallets versus payment wallets and work messaging versus social apps.
2. Keep English categories from the product taxonomy. Persist rule version, original/display identity where permitted, category, override, and scan timestamps. Do not infer that a category label in the current widget already filters a shared inventory.
3. Enable **App Groups** on the host and widget with the same registered group. Proposed iOS group ID: `group.com.daniellondospi.DanLauncher` — this is a proposal, not an existing registration. Record the real ID selected by Xcode and use it consistently. [A9]
4. First prove both processes can read a harmless test snapshot. Then persist the permitted catalog atomically with a schema version. Ordinary `UserDefaults.standard` in the host is not a shared catalog. Test any documented token serialization and cross-process presentation rather than assuming it works.
5. Diff only successful, complete snapshots. A failed or partial scan must not delete every app. Retain user overrides when an app disappears; handle reinstalls deliberately.
6. Keep inventory local by default. Do not upload raw app lists or tokens to GitHub, analytics, or a language model. On loss of authorization, stop scanning and suppress protected inventory in the widget; define local-data removal separately from transient scan failures.

**Gate:** classification tests pass, overrides survive rescans, and the widget reads the same versioned catalog without network access.

## 7. Agent + Daniel: category widgets and honest refresh behavior

Replace manual slots only after the relevant inventory, storage, and launch gates pass. Use a reusable category-configured widget: Daniel adds it to Home and chooses **Banking**, **Travel**, **Smart Home**, etc. Preserve title/background configuration and track optional app-name visibility as a separate improvement. Plan pagination or an overflow affordance; do not silently omit apps that exceed a widget's capacity. Keep the existing widget kind/parameter identities unless a reviewed migration is necessary.

On host-app activation and manual refresh, reconcile inventory after checking authorization. Write the new snapshot first, then request `WidgetCenter.shared.reloadTimelines(ofKind: "WidgetLauncher")` if the content changed. Verify the actual kind in source before implementation. WidgetKit schedules refreshes; a reload request is not an immediate-update guarantee. [A10][A11]

Test installing and removing a disposable test app, then reopening DanLauncher. Separately investigate any documented background trigger. Neither the cited inventory property nor membership establishes a continuously running install observer. Report **updates after synchronization** until an additional mechanism is proven. No background timing guarantee or system-wide tap interception is part of this runbook.

Home Screen placement remains a user action. The scope is automatic contents inside category widgets, not programmatically moving SpringBoard icons, creating native folders, or silently adding widgets to Home.

## 8. Distribution is a separate decision

For an initial personal test, use the eligible Xcode development build on the registered device. Do not equate that success with eligibility for a long-term customer installation outside the EU. [A4]

Before TestFlight/App Store or another distribution method:

- Have the Account Holder request the **Family Controls distribution entitlement** through Apple's process. Declare the launcher use case accurately. Apple reviews the request; approval and turnaround are not guaranteed. Check the allowed provisioning methods after approval. Screen Time API extensions, if later added, have their own requirements. [A6]
- Independently verify **App and Website Usage** entitlement inclusion and actual data-access authorization for the selected delivery method. Base Family Controls approval is not proof of raw-data access or a waiver of regional restrictions. [A3][A4]
- Revalidate regional eligibility and SDK behavior at release time, provide denial/unavailable fallbacks, and document privacy handling. Do not claim the Colombia/Panama customer use case is solved by paying for membership.

## 9. Acceptance record and recovery

Create a short dated result in `docs/` after each gate. Use synthetic fixtures or redact personal inventory; do not commit the device UDID or provisioning files.

```text
Commit / branch:
Date / tester:
Xcode + SDK / device OS:
Install method (development, TestFlight, etc.):
Enrolled team/profile verified (yes/no):
Required signed entitlements verified (yes/no):
Authorization status / error code:
Returned / identifiable app counts:
Launch mechanism and sample result:
Shared catalog / widget result:
Install-uninstall reconciliation result:
Known gaps / next gate:
```

Completion checklist — leave unchecked until observed:

- [ ] Enrolled team and known-good launcher baseline verified.
- [ ] Both required host-app entitlements provisioned and signed.
- [ ] Data-access authorization and real inventory probe pass on-device.
- [ ] Public launch bridge proved, or manual mapping explicitly accepted as fallback.
- [ ] Classification/override tests and shared-container round trip pass.
- [ ] Category widgets show the intended catalog and preserve launch behavior.
- [ ] Revocation, scan failure, empty category, and install/uninstall tests pass.
- [ ] Distribution/region constraints recorded separately if distribution is requested.

If a gate fails, preserve its exact evidence and revert only the experimental changes on the work branch. Do not restore an old `.pbxproj`, delete working targets, erase widget settings, or revert unrelated name/icon fixes. Report signing, Swift compilation, runtime authorization, and UX failures as different problems. An agent must never mark physical-device steps as passed solely from Linux checks, documentation, or a successful Build.

## Apple references

[A1] [Supported capabilities (iOS)](https://developer.apple.com/help/account/reference/supported-capabilities-ios/)

[A2] [Capabilities overview](https://developer.apple.com/help/account/capabilities/capabilities-overview) and [Xcode capabilities](https://developer.apple.com/documentation/xcode/capabilities)

[A3] [Family Controls App and Website Usage entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.family-controls.app-and-website-usage)

[A4] [AuthorizationStatus.approvedWithDataAccess](https://developer.apple.com/documentation/FamilyControls/AuthorizationStatus/approvedWithDataAccess)

[A5] [requestAuthorization(for:)](https://developer.apple.com/documentation/familycontrols/authorizationcenter/requestauthorization(for:))

[A6] [Requesting the Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)

[A7] [installedApplications](https://developer.apple.com/documentation/familycontrols/familyactivitydata/installedapplications)

[A8] [RunSystemShortcutIntent.init(shortcut:)](https://developer.apple.com/documentation/appintents/runsystemshortcutintent/init(shortcut:))

[A9] [WidgetKit strategy: shared group container](https://developer.apple.com/documentation/widgetkit/developing-a-widgetkit-strategy)

[A10] [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)

[A11] [What's new in widgets: reloads and their limits](https://developer.apple.com/videos/play/wwdc2025/278/)
