import WidgetKit
import SwiftUI
import AppIntents
import Foundation
import UIKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, configuration: LauncherConfigurationIntent())
    }

    func snapshot(for configuration: LauncherConfigurationIntent, in context: Context) async -> SimpleEntry {
        await makeEntry(configuration, allowNetwork: !context.isPreview)
    }

    func timeline(for configuration: LauncherConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = await makeEntry(configuration, allowNetwork: true)
        // The system schedules this request; this is not an exact refresh timer.
        return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(6 * 3600)))
    }

    private func makeEntry(_ configuration: LauncherConfigurationIntent, allowNetwork: Bool) async -> SimpleEntry {
        let shortcuts = configuration.launcherShortcuts
        var presentations = shortcuts.enumerated().map { index, shortcut in
            guard let shortcut else { return LauncherSlotPresentation(name: "Add \(index + 1)") }
            let display = shortcut.displayRepresentation
            let title = String(localized: display.title)
            let subtitle = display.subtitle.map { String(localized: $0) }
            return LauncherSlotPresentation(
                name: LauncherPresentation.name(title: title, subtitle: subtitle, slot: index + 1),
                artworkData: SystemShortcutArtwork.pngData(from: display.image)
            )
        }
        if allowNetwork && configuration.useAppStoreIcons {
            let country = LauncherPresentation.storefrontCountry(Locale.current.region?.identifier)
            let requests = shortcuts.indices.filter {
                shortcuts[$0] != nil && presentations[$0].artworkData == nil
            }.map { ($0, presentations[$0].name) }
            // Resolve artwork BEFORE producing the timeline. AsyncImage/task in
            // the widget view cannot reliably finish before WidgetKit snapshots it.
            await withTaskGroup(of: (Int, Data?).self) { group in
                var pending = requests.makeIterator()
                for _ in 0..<4 {
                    guard let (index, name) = pending.next() else { break }
                    group.addTask { (index, await AppStoreArtwork.shared.image(for: name, country: country)) }
                }
                for await (index, data) in group {
                    presentations[index].artworkData = data
                    if let (nextIndex, name) = pending.next() {
                        group.addTask { (nextIndex, await AppStoreArtwork.shared.image(for: name, country: country)) }
                    }
                }
            }
        }
        return SimpleEntry(date: .now, configuration: configuration, presentations: presentations)
    }
}

// Preserve the native-image attempt introduced in commit 4044609. Mirror is
// best-effort compatibility, NOT a documented DisplayRepresentation image API.
// If the system stores an opaque reference instead, use initials or opt-in artwork.
private enum SystemShortcutArtwork {
    static func pngData(from representation: DisplayRepresentation.Image?) -> Data? {
        guard let representation,
              let image = extract(from: representation, depth: 0),
              let data = image.pngData(), data.count <= 1_500_000 else { return nil }
        return data
    }

    private static func extract(from value: Any, depth: Int) -> UIImage? {
        guard depth < 6 else { return nil }
        if let image = value as? UIImage { return image }
        if let data = value as? Data, data.count <= 1_500_000,
           let image = UIImage(data: data) { return image }
        if let url = value as? URL, url.isFileURL,
           let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? NSNumber, size.intValue <= 1_500_000,
           let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            return image
        }
        for child in Mirror(reflecting: value).children {
            if let image = extract(from: child.value, depth: depth + 1) { return image }
        }
        return nil
    }
}

extension LauncherConfigurationIntent {
    var launcherShortcuts: [SystemShortcut?] {
        [shortcut1, shortcut2, shortcut3, shortcut4, shortcut5, shortcut6, shortcut7, shortcut8]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: LauncherConfigurationIntent
    var presentations: [LauncherSlotPresentation] = []
}

struct WidgetLauncherEntryView: View {
    let entry: SimpleEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(widgetTitle)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            GeometryReader { geometry in
                let rowHeight = max(1, (geometry.size.height - 6) / 2)
                let iconSize = max(20, min(44, rowHeight - (entry.configuration.showAppNames ? 18 : 4)))
                let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<slotCount, id: \.self) { index in
                        launcherSlot(at: index, iconSize: iconSize)
                            .frame(maxWidth: .infinity)
                            .frame(height: rowHeight)
                    }
                }
            }
        }
        .foregroundStyle(contentColor)
        .containerBackground(for: .widget) { backgroundView }
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

    private var contentColor: Color {
        // A fixed white foreground disappears on a light background, and vice versa.
        guard renderingMode == .fullColor else { return .primary }
        switch entry.configuration.background {
        case .light, .green, .orange: return .black
        case .dark, .blue, .purple: return .white
        case .system, .clear: return .primary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch entry.configuration.background {
        case .system: Color(uiColor: .secondarySystemBackground)
        case .clear: Color.clear
        case .dark: Color.black
        case .light: Color.white
        case .blue: Color.blue
        case .green: Color.green
        case .purple: Color.purple
        case .orange: Color.orange
        }
    }

    private var columnCount: Int { family == .systemSmall ? 2 : 4 }
    private var slotCount: Int { family == .systemSmall ? 4 : 8 }

    private func presentation(at index: Int) -> LauncherSlotPresentation {
        guard entry.presentations.indices.contains(index) else {
            return LauncherSlotPresentation(name: "App \(index + 1)")
        }
        return entry.presentations[index]
    }

    @ViewBuilder
    private func launcherSlot(at index: Int, iconSize: CGFloat) -> some View {
        if let shortcut = entry.configuration.launcherShortcuts[index] {
            let metadata = presentation(at: index)
            // Preserve the native direct-launch action. Artwork is presentation only.
            Button(intent: RunSystemShortcutIntent(shortcut: shortcut)) {
                VStack(spacing: 3) {
                    appIcon(metadata, size: iconSize)
                    if entry.configuration.showAppNames {
                        Text(verbatim: metadata.name)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // Keep a meaningful VoiceOver name when the visual name is hidden.
            .accessibilityLabel(Text("Open \(metadata.name)"))
        } else {
            VStack(spacing: 3) {
                Image(systemName: "plus.app")
                    .font(.system(size: iconSize * 0.75))
                    .frame(width: iconSize, height: iconSize)
                if entry.configuration.showAppNames {
                    Text("\(index + 1)").font(.system(size: 10))
                }
            }
            .opacity(0.55)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Unconfigured slot \(index + 1)"))
            .accessibilityHint("Use Edit Widget to choose an app")
        }
    }

    @ViewBuilder
    private func appIcon(_ metadata: LauncherSlotPresentation, size: CGFloat) -> some View {
        if let data = metadata.artworkData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
                .widgetAccentedRenderingMode(.fullColor)
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
                .accessibilityHidden(true)
        } else {
            // An explicit fallback, NOT the real app icon. No blank white squares.
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(contentColor.opacity(0.15))
                Text(verbatim: LauncherPresentation.initials(for: metadata.name))
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
        }
    }
}

struct WidgetLauncher: Widget {
    let kind = "WidgetLauncher"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LauncherConfigurationIntent.self, provider: Provider()) { entry in
            WidgetLauncherEntryView(entry: entry)
        }
        .configurationDisplayName("Dan Launcher")
        .description("Choose a category title, background, app labels, and launcher actions.")
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
