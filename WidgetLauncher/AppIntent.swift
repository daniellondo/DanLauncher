import WidgetKit
import AppIntents

struct LauncherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Launcher"
    static var description = IntentDescription("Choose an app or shortcut to launch.")

    @Parameter(title: "Action")
    var shortcut: SystemShortcut?

    init() {}
}
