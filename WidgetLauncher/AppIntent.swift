import WidgetKit
import AppIntents

struct LauncherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Launcher"
    static var description = IntentDescription("Choose up to eight apps or shortcuts to launch.")

    @Parameter(title: "Action 1") var shortcut1: SystemShortcut?
    @Parameter(title: "Action 2") var shortcut2: SystemShortcut?
    @Parameter(title: "Action 3") var shortcut3: SystemShortcut?
    @Parameter(title: "Action 4") var shortcut4: SystemShortcut?
    @Parameter(title: "Action 5") var shortcut5: SystemShortcut?
    @Parameter(title: "Action 6") var shortcut6: SystemShortcut?
    @Parameter(title: "Action 7") var shortcut7: SystemShortcut?
    @Parameter(title: "Action 8") var shortcut8: SystemShortcut?

    init() {}
}
