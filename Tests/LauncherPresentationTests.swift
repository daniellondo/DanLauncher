import Foundation

// Standalone Foundation-only tests; intentionally outside both Xcode target folders.
// Run with: sh Tests/run-launcher-presentation-tests.sh
@main
struct LauncherPresentationTests {
    static func main() throws {
        var count = 0
        func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
            precondition(condition(), message)
            count += 1
        }
        func result(_ id: Int, _ name: String) -> StoreArtworkResult {
            StoreArtworkResult(trackId: id, trackName: name, artworkUrl100: nil, artworkUrl512: nil)
        }

        expect(LauncherPresentation.name(title: "WhatsApp", subtitle: nil, slot: 1) == "WhatsApp", "System title")
        expect(LauncherPresentation.name(title: "  Teams \n", subtitle: nil, slot: 2) == "Teams", "Trim title")
        expect(LauncherPresentation.name(title: "Open App", subtitle: "WhatsApp", slot: 1) == "WhatsApp", "Use useful subtitle")
        expect(LauncherPresentation.name(title: "Open App\u{2026}", subtitle: "ChatGPT", slot: 2) == "ChatGPT", "Ellipsis")
        expect(LauncherPresentation.name(title: "", subtitle: nil, slot: 3) == "App 3", "Empty title")
        expect(LauncherPresentation.name(title: "Open", subtitle: nil, slot: 4) == "App 4", "Do not show generic Open")
        expect(LauncherPresentation.name(title: "Open App", subtitle: "", slot: 5) == "App 5", "Unknown identity")
        expect(LauncherPresentation.name(title: "Prende la luz", subtitle: "Home", slot: 1) == "Prende la luz", "Preserve custom action")
        expect(LauncherPresentation.name(title: "Abrir aplicaci\u{00f3}n", subtitle: "Nu", slot: 1) == "Nu", "Spanish generic action")

        for generic in ["", "  ", "Open", "Open App", "Open App...", "Open App\u{2026}", "Abrir app", "App 1"] {
            expect(LauncherPresentation.artworkQuery(for: generic) == nil, "Do not search generic labels: \(generic)")
        }
        expect(LauncherPresentation.artworkQuery(for: "Open WhatsApp") == "WhatsApp", "Explicit open prefix")
        expect(LauncherPresentation.artworkQuery(for: "Abrir ChatGPT") == "ChatGPT", "Spanish open prefix")
        expect(LauncherPresentation.artworkQuery(for: "OpenTable") == "OpenTable", "Not an action prefix")
        expect(LauncherPresentation.artworkQuery(for: String(repeating: "x", count: 161)) == nil, "Bound query size")

        expect(LauncherPresentation.initials(for: "WhatsApp") == "WH", "Single-word initials")
        expect(LauncherPresentation.initials(for: "Google Maps") == "GM", "Multiword initials")
        expect(LauncherPresentation.initials(for: "Open WhatsApp") == "WH", "No generic Open initials")
        expect(LauncherPresentation.initials(for: "") == "?", "Empty fallback")
        expect(LauncherPresentation.initials(for: "X") == "X", "One-character app")

        let whatsapp = result(310633997, "WhatsApp Messenger")
        let business = result(1386412985, "WhatsApp Business")
        expect(LauncherPresentation.matchingResult([business, whatsapp], query: "WhatsApp")?.trackId == 310633997, "Pinned identity, not first hit")
        expect(LauncherPresentation.matchingResult([business], query: "WhatsApp") == nil, "Never substitute Business")
        expect(LauncherPresentation.matchingResult([result(1, "ChatGPT")], query: "ChatGPT") == nil, "Reject fake ChatGPT identity")
        expect(LauncherPresentation.matchingResult([result(6448311069, "ChatGPT")], query: "ChatGPT")?.trackId == 6448311069, "Official ChatGPT identity")
        expect(LauncherPresentation.matchingResult([result(1, "Atlas"), result(2, "Atlas Wallet")], query: "Atlas")?.trackId == 1, "Exact match")
        expect(LauncherPresentation.matchingResult([result(1, "Atlas Wallet")], query: "Atlas") == nil, "No partial match")
        expect(LauncherPresentation.matchingResult([result(1, "Atlas"), result(2, "Atlas")], query: "Atlas") == nil, "Ambiguous exact name")
        expect(LauncherPresentation.matchingResult([result(1, "Atlas"), result(1, "Atlas")], query: "Atlas")?.trackId == 1, "Same Store ID is not ambiguous")
        expect(LauncherPresentation.matchingResult([], query: "Atlas") == nil, "Empty catalogue")
        expect(LauncherPresentation.matchingResult([result(1, "  Atlas   Maps ")], query: "atlas maps")?.trackId == 1, "Whitespace and case")

        expect(LauncherPresentation.isAppleArtworkURL(URL(string: "https://is1-ssl.mzstatic.com/image.png")!), "Apple CDN")
        for url in ["http://is1-ssl.mzstatic.com/a", "https://mzstatic.com.evil.example/a", "https://evilmzstatic.com/a", "https://mzstatic.com@evil.example/a", "https://user:pass@is1-ssl.mzstatic.com/a", "file:///tmp/icon.png"] {
            expect(!LauncherPresentation.isAppleArtworkURL(URL(string: url)!), "Reject untrusted artwork URL: \(url)")
        }
        expect(LauncherPresentation.storefrontCountry("co") == "CO", "Two-letter country")
        expect(LauncherPresentation.storefrontCountry("419") == "US", "Region group fallback")
        expect(LauncherPresentation.storefrontCountry(nil) == "US", "Unknown locale")
        expect(LauncherPresentation.storefrontCountry("C0") == "US", "Reject invalid country shape")
        expect(LauncherPresentation.cacheFilename(for: "CO:whatsapp") == LauncherPresentation.cacheFilename(for: "CO:whatsapp"), "Stable cache key")
        expect(LauncherPresentation.cacheFilename(for: "CO:whatsapp") != LauncherPresentation.cacheFilename(for: "US:whatsapp"), "Country-specific cache")
        let json = Data(#"{"results":[{"trackId":310633997,"trackName":"WhatsApp Messenger","artworkUrl100":"https://is1-ssl.mzstatic.com/test.png"}]}"#.utf8)
        let decoded = try JSONDecoder().decode(StoreArtworkResponse.self, from: json)
        expect(decoded.results.count == 1 && decoded.results.first?.trackId == 310633997, "Decode catalogue fixture")
        print("PASS: \(count) presentation/matching assertions. No Apple SDK or network exercised.")
    }
}
