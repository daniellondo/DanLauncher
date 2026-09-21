import WidgetKit
import AppIntents

enum LauncherCategory: String, AppEnum {
    case suggestions
    case banking
    case payments
    case crypto
    case trading
    case smartHome
    case work
    case ai
    case security
    case communication
    case social
    case travel
    case transportation
    case shopping
    case food
    case entertainment
    case healthFitness
    case utilities
    case uncategorized

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")

    static var caseDisplayRepresentations: [LauncherCategory: DisplayRepresentation] = [
        .suggestions: "Suggestions",
        .banking: "Banking",
        .payments: "Payments",
        .crypto: "Crypto",
        .trading: "Trading",
        .smartHome: "Smart Home",
        .work: "Work",
        .ai: "AI",
        .security: "Security",
        .communication: "Communication",
        .social: "Social",
        .travel: "Travel",
        .transportation: "Transportation",
        .shopping: "Shopping",
        .food: "Food & Dining",
        .entertainment: "Entertainment",
        .healthFitness: "Health & Fitness",
        .utilities: "Utilities",
        .uncategorized: "Uncategorized"
    ]
}

enum LauncherBackground: String, AppEnum {
    case system
    case clear
    case dark
    case light
    case blue
    case green
    case purple
    case orange

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Background")

    static var caseDisplayRepresentations: [LauncherBackground: DisplayRepresentation] = [
        .system: "System",
        .clear: "Transparent",
        .dark: "Dark",
        .light: "Light",
        .blue: "Blue",
        .green: "Green",
        .purple: "Purple",
        .orange: "Orange"
    ]
}

struct LauncherConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Dan Launcher"
    static var description = IntentDescription("Configure a category launcher.")

    @Parameter(title: "Category", default: .suggestions)
    var category: LauncherCategory

    @Parameter(title: "Title")
    var customTitle: String?

    @Parameter(title: "Background", default: .system)
    var background: LauncherBackground

    // Temporary launch actions. These preserve the proven direct-launch path
    // while automatic installed-app discovery is implemented separately.
    @Parameter(title: "App 1") var shortcut1: SystemShortcut?
    @Parameter(title: "App 2") var shortcut2: SystemShortcut?
    @Parameter(title: "App 3") var shortcut3: SystemShortcut?
    @Parameter(title: "App 4") var shortcut4: SystemShortcut?
    @Parameter(title: "App 5") var shortcut5: SystemShortcut?
    @Parameter(title: "App 6") var shortcut6: SystemShortcut?
    @Parameter(title: "App 7") var shortcut7: SystemShortcut?
    @Parameter(title: "App 8") var shortcut8: SystemShortcut?

    init() {}
}
