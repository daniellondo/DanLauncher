import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Launcher" }
    static var description: IntentDescription { "Choose an app or shortcut to launch from the widget." }

    @Parameter(title: "Action")
    var shortcut: SystemShortcut?
}
