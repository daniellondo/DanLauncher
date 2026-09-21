import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: .now, configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        Timeline(entries: [SimpleEntry(date: .now, configuration: configuration)], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct LauncherWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Group {
            if let shortcut = entry.configuration.shortcut {
                Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                    launcherLabel
                }
                .buttonStyle(.plain)
            } else {
                launcherLabel
            }
        }
    }

    private var launcherLabel: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 36))
            Text(entry.configuration.shortcut == nil ? "Configurar" : "Abrir")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LauncherWidget: Widget {
    let kind = "LauncherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LauncherWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Dan Launcher")
        .description("Open an app or system shortcut directly from the Home Screen.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    LauncherWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
}
