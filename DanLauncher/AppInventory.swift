#if os(iOS)
import Foundation
import FamilyControls
import ManagedSettings

struct DetectedApp: Identifiable, Hashable {
    let id: String
    let bundleIdentifier: String
    let category: String
    let token: ApplicationToken?
}

@MainActor
final class AppInventory: ObservableObject {
    @Published var apps: [DetectedApp] = []
    @Published var status = "Ready"
    @Published var isLoading = false

    func authorizeAndScan() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            status = "Authorization: \(AuthorizationCenter.shared.authorizationStatus.description)"
            try await scan()
        } catch {
            status = "Authorization failed: \(error.localizedDescription)"
        }
    }

    func scan() async throws {
        guard AuthorizationCenter.shared.authorizationStatus == .approvedWithDataAccess else {
            status = "Data access is not approved. Status: \(AuthorizationCenter.shared.authorizationStatus.description)"
            return
        }

        let installed = try await FamilyActivityData.shared.installedApplications
        apps = installed.compactMap { application in
            guard let bundle = application.bundleIdentifier, !bundle.isEmpty else { return nil }
            return DetectedApp(id: bundle, bundleIdentifier: bundle,
                               category: AppClassifier.category(for: bundle),
                               token: application.token)
        }
        .sorted {
            $0.category == $1.category
                ? $0.bundleIdentifier < $1.bundleIdentifier
                : $0.category < $1.category
        }
        status = "Detected \(apps.count) installed apps"
        persistSnapshot()
    }

    private func persistSnapshot() {
        let snapshot = apps.map { ["bundleIdentifier": $0.bundleIdentifier, "category": $0.category] }
        guard let data = try? JSONSerialization.data(withJSONObject: snapshot, options: [.prettyPrinted, .sortedKeys]) else { return }
        UserDefaults.standard.set(data, forKey: "DanLauncherInstalledAppsSnapshot")
        UserDefaults.standard.set(Date(), forKey: "DanLauncherInstalledAppsSnapshotDate")
    }
}

enum AppClassifier {
    static func category(for bundle: String) -> String {
        let id = bundle.lowercased()
        let rules: [(String, [String])] = [
            ("Banking", ["bancolombia", "bbva", "davivienda", "nequi", "lulo", "nubank", "avvillas", "finandina", "banistmo", "bgeneral"]),
            ("Payments", ["paypal", "mercadopago", "wallet", "tricount", "ontop"]),
            ("Crypto", ["kraken", "ledger", "phantom", "rabby", "jupiter"]),
            ("Trading", ["interactivebrokers", "ibkr", "metatrader", "tradingview", "icmarkets", "trii"]),
            ("Smart Home", ["smartlife", "tuya", "xiaomi", "mihome", "v380", "yoosee", "lotuslantern"]),
            ("AI", ["openai", "chatgpt", "anthropic", "claude"]),
            ("Work", ["slack", "teams", "microsoft.teams", "jira", "linkedin"]),
            ("Security", ["1password", "authenticator", "okta", "companyportal"]),
            ("Communication", ["whatsapp", "telegram", "messenger", "truecaller"]),
            ("Social", ["instagram", "facebook", "tiktok", "twitter"]),
            ("Travel", ["avianca", "copa", "wingo", "aeromexico", "booking", "airbnb"]),
            ("Transportation", ["uber", "didi", "indrive", "waze", "googlemaps", "moovit"]),
            ("Shopping", ["mercadolibre", "aliexpress", "temu"]),
            ("Food & Dining", ["rappi", "pedidosya", "opentable"]),
            ("Entertainment", ["youtube", "spotify", "crunchyroll", "clarovideo", "steam", "nintendo"]),
            ("Health & Fitness", ["health", "fitness", "pillow", "habitify"]),
            ("Utilities", ["calculator", "clock", "compass", "measure", "weather", "safari", "chrome", "shortcuts", "scriptable"])
        ]
        for (category, fragments) in rules where fragments.contains(where: id.contains) { return category }
        return "Uncategorized"
    }
}
#endif
