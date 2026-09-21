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
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(shortcuts.prefix(slotCount).enumerated()), id: \.offset) { index, shortcut in
                launcherSlot(shortcut, number: index + 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shortcuts: [SystemShortcut?] {
        [
            entry.configuration.shortcut1,
            entry.configuration.shortcut2,
            entry.configuration.shortcut3,
            entry.configuration.shortcut4,
            entry.configuration.shortcut5,
            entry.configuration.shortcut6,
            entry.configuration.shortcut7,
            entry.configuration.shortcut8
        ]
    }

    private var columnCount: Int {
        family == .systemSmall ? 2 : 4
    }

    private var slotCount: Int {
        switch family {
        case .systemSmall: 4
        case .systemMedium: 8
        default: 8
        }
    }

    @ViewBuilder
    private func launcherSlot(_ shortcut: SystemShortcut?, number: Int) -> some View {
        if let shortcut {
            Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                slotLabel(number: number, configured: true)
            }
            .buttonStyle(.plain)
        } else {
            slotLabel(number: number, configured: false)
        }
    }

    private func slotLabel(number: Int, configured: Bool) -> some View {
        VStack(spacing: 3) {
            Image(systemName: configured ? "app.fill" : "plus.app")
                .font(.title2)
            Text(configured ? "Abrir" : "\(number)")
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
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
        .description("Open several apps or shortcuts directly from the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WidgetLauncher()
} timeline: {
    SimpleEntry(date: .now, configuration: LauncherConfigurationIntent())
}

#Preview(as: .systemMedium) {
    WidgetLauncher()
} timeline: {
    SimpleEntry(date: .now, configuration: LauncherConfigurationIntent())
}
