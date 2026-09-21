import WidgetKit
import SwiftUI
import AppIntents
import UIKit

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
        VStack(alignment: .leading, spacing: 7) {
            Text(widgetTitle)
                .font(.headline)
                .lineLimit(1)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(shortcuts.prefix(slotCount).enumerated()), id: \.offset) { index, shortcut in
                    launcherSlot(shortcut, number: index + 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(for: .widget) {
            backgroundView
        }
    }

    private var widgetTitle: String {
        let trimmed = entry.configuration.customTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? categoryTitle : trimmed
    }

    private var categoryTitle: String {
        switch entry.configuration.category {
        case .suggestions: "Suggestions"
        case .banking: "Banking"
        case .payments: "Payments"
        case .crypto: "Crypto"
        case .trading: "Trading"
        case .smartHome: "Smart Home"
        case .work: "Work"
        case .ai: "AI"
        case .security: "Security"
        case .communication: "Communication"
        case .social: "Social"
        case .travel: "Travel"
        case .transportation: "Transportation"
        case .shopping: "Shopping"
        case .food: "Food & Dining"
        case .entertainment: "Entertainment"
        case .healthFitness: "Health & Fitness"
        case .utilities: "Utilities"
        case .uncategorized: "Uncategorized"
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch entry.configuration.background {
        case .system:
            Color(.secondarySystemBackground)
        case .clear:
            Color.clear
        case .dark:
            Color.black
        case .light:
            Color.white
        case .blue:
            Color.blue
        case .green:
            Color.green
        case .purple:
            Color.purple
        case .orange:
            Color.orange
        }
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
        family == .systemSmall ? 4 : 8
    }

    @ViewBuilder
    private func launcherSlot(_ shortcut: SystemShortcut?, number: Int) -> some View {
        if let shortcut {
            Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                configuredSlot(shortcut)
            }
            .buttonStyle(.plain)
        } else {
            VStack(spacing: 3) {
                Image(systemName: "plus.app")
                    .font(.title2)
                Text("\(number)")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
    }

    private func configuredSlot(_ shortcut: SystemShortcut) -> some View {
        VStack(spacing: 4) {
            shortcutIcon(shortcut)
            Text(shortcut.displayRepresentation.title)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func shortcutIcon(_ shortcut: SystemShortcut) -> some View {
        if let representation = shortcut.displayRepresentation.image,
           let uiImage = systemShortcutUIImage(from: representation) {
            Image(uiImage: uiImage)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            let title = String(localized: shortcut.displayRepresentation.title)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.gradient)
                Text(shortcutInitials(title))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 34, height: 34)
        }
    }

    private func shortcutInitials(_ title: String) -> String {
        let words = title.split(whereSeparator: { $0.isWhitespace })
        guard let first = words.first else { return "•" }
        if words.count > 1, let a = first.first, let b = words[1].first {
            return "\(a)\(b)".uppercased()
        }
        return String(first.prefix(2)).uppercased()
    }

    private func systemShortcutUIImage(from image: DisplayRepresentation.Image) -> UIImage? {
        extractUIImage(from: image, depth: 0)
    }

    private func extractUIImage(from value: Any, depth: Int) -> UIImage? {
        guard depth < 6 else { return nil }

        if let uiImage = value as? UIImage {
            return uiImage
        }
        if let data = value as? Data, let uiImage = UIImage(data: data) {
            return uiImage
        }
        if let url = value as? URL, url.isFileURL,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return uiImage
        }

        let mirror = Mirror(reflecting: value)
        for child in mirror.children {
            if let image = extractUIImage(from: child.value, depth: depth + 1) {
                return image
            }
        }
        return nil
    }
}

struct WidgetLauncher: Widget {
    let kind = "WidgetLauncher"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LauncherConfigurationIntent.self, provider: Provider()) { entry in
            WidgetLauncherEntryView(entry: entry)
        }
        .configurationDisplayName("Dan Launcher")
        .description("Choose a category, title, background, and launcher actions.")
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
