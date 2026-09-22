# App names and artwork

Current review/development branch: **`main`**. This document records the earlier app-presentation patch. Its widget-view wiring was subsequently reverted while resolving build/signing issues; inspect current source before treating these presentation features as enabled. The consolidation does not re-enable them.

## Update and use

On `main`, pull and run the `DanLauncher` app scheme on the iPhone. Do not recreate targets, change signing, or delete the app for a documentation-only update. When the presentation patch is restored and validated, edit the existing widget:

- **Show App Names** defaults to **On**. Turn it off for icon-only cells. VoiceOver still announces each configured action.
- **App Store Icons** defaults to **Off**. Enable it to allow this widget to send selected display names (or known App Store IDs) to Apple's catalogue and download matching artwork when a native image is unavailable. Initial catalogue requests need internet. No shortcut tokens or shortcut contents are sent.
- **Title**, **Background**, **Category**, and the existing **App 1...8** selections retain their parameter identifiers. The small widget still displays four slots; medium displays eight.

## What the historical patch implements

The provider resolves the selected SystemShortcut's public display title and optional subtitle using `String(localized:)`. If iOS exposes only a generic action title and no useful subtitle, the fallback is `App N`, not a fabricated application name. Custom shortcuts keep their action names. This does not enumerate or inspect installed apps.

The native-image reflection attempt from concurrent commit `40446098f31b1ce2ac82894fea3649c5a9f17c36` is preserved and given priority in that patch. It uses bounded Swift Mirror inspection of the system's display representation for an existing UIImage, image Data, or a readable local image file. This relies on implementation details, not a documented image conversion API, so an SDK change or an opaque representation can make it fail. It is not guaranteed access to the installed icon.

When that attempt fails, optional catalogue artwork is a cosmetic, best-effort lookup, not an extraction of the locally installed icon. WhatsApp and ChatGPT use verified Store IDs; other names require a unique exact normalized match in the returned results. Partial matches, ambiguous results, errors, and missing artwork use visible initials. Even an exact catalogue name is not proof that it is the same locally installed app; a custom shortcut may have a misleading name. The artwork lookup never changes the executable action.

Images are loaded before the timeline is delivered, not via AsyncImage in the widget view. Successful images are cached locally for seven days; misses for six hours; transient failures for ten minutes while retaining existing cached artwork. Requests are coalesced and limited per running extension process. The six-hour timeline policy is a request to WidgetKit, not a guaranteed schedule. A first download may delay the initial refresh. Cached artwork may differ from a custom/tinted installed icon.

Image rendering explicitly uses original/full color. Text contrast follows the selected background in full-color mode and defers to iOS in accented mode. Clearing the background remains subject to iOS's widget presentation; it is not wallpaper extraction.

The direct launch call remains `RunSystemShortcutIntent(shortcut: shortcut)`. No wrapper intent, URL scheme, private API, Family Controls entitlement, App Group, new target, or signing change was added. Category remains a label/configuration choice: automatic category population or install monitoring is **not implemented** by this patch.

## Validation

Run `sh Tests/run-launcher-presentation-tests.sh` from the repository. The script uses a temporary executable and does not add an Xcode test target.

Performed before this patch was committed: 50 Foundation-only assertions covering display-name fallbacks, generic labels, Store identity matching, ambiguity, URL restrictions, country shape, cache keys, and a JSON fixture; Foundation helper typechecking; Swift syntax parsing. Those checks passed with Swift 6.2.1 in Swift 5 language mode on Linux. No real Apple network response, native-image reflection, SwiftUI/AppIntents SDK compilation, widget metadata extraction, device layout, or iPhone launching was validated in that environment.

Device acceptance: build/run in Xcode 27; confirm existing app selections still open their original apps; test names on/off; enable App Store Icons for WhatsApp and ChatGPT with connectivity; test initials on an unknown/custom action; test cached icons offline; test light/dark/blue backgrounds and tinted Home Screen; test small/medium sizes. If iOS returns a generic title, report the title/subtitle behavior rather than guessing a Bundle ID.

Historical recovery point: commit `ff432c528273bb13795dd63fda7845bab4eacdef`, now retained in the history of `main`; an extra backup branch is not required. The original patch was reconciled on top of the newer native-image commit `40446098f31b1ce2ac82894fea3649c5a9f17c36`, not over the older recovery point. No changes to `.pbxproj` were required; the existing file-system-synchronized WidgetLauncher folder includes the helper files.

## References

- Apple SystemShortcut: https://developer.apple.com/documentation/appintents/systemshortcut
- Apple DisplayRepresentation: https://developer.apple.com/documentation/appintents/displayrepresentation
- Apple iTunes Search API: https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html
- Apple ID lookups: https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/LookupExamples.html
- Apple full-color artwork: https://developer.apple.com/documentation/widgetkit/widgetaccentedrenderingmode/fullcolor
- WhatsApp Store ID: https://apps.apple.com/us/app/whatsapp-messenger/id310633997
- ChatGPT official download reference: https://help.openai.com/en/articles/7908378-where-can-i-download-the-openai-chatgpt-ios-app-on-the-apple-app-store
