//
//  AppIntent.swift
//  LauncherWidget
//
//  Created by Daniel Londoño Ospina on 21/09/26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Launcher" }
    static var description: IntentDescription {
        "Choose an installed app, App Shortcut, custom shortcut, or system action to launch from the widget."
    }

    @Parameter(title: "Action")
    var shortcut: SystemShortcut
}
