import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, configuration: LauncherConfigurationIntent())
    }

    func snapshot(for configuration: LauncherConfigurationIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: .now, configuration: configuration)
    }

    func timeline(for configuration: LauncherConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        Timeline(entries: [SimpleEntry(date: .now, configuration: configuration)], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: LauncherConfigurationIntent
}

struct WidgetLauncherEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        Group {
            if let shortcut = entry.configuration.shortcut {
                Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                    label(configured: true)
                }
                .buttonStyle(.plain)
            } else {
                label(configured: false)
            }
        }
    }

    private func label(configured: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 36))
            Text(configured ? "Abrir" : "Configurar")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WidgetLauncher: Widget {
    let kind = "WidgetLauncher"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LauncherConfigurationIntent.self, provider: Provider()) { entry in
            WidgetLauncherEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Dan Launcher")
        .description("Open an app or shortcut from the Home Screen.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WidgetLauncher()
} timeline: {
    SimpleEntry(date: .now, configuration: LauncherConfigurationIntent())
}
