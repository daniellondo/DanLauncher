import Foundation

/// Display-only metadata. It never determines what a launcher button executes.
struct LauncherSlotPresentation: Sendable {
    let name: String
    var artworkData: Data? = nil
}

struct StoreArtworkResult: Decodable, Sendable {
    let trackId: Int
    let trackName: String
    let artworkUrl100: URL?
    let artworkUrl512: URL?
}

struct StoreArtworkResponse: Decodable, Sendable {
    let results: [StoreArtworkResult]
}

enum LauncherPresentation {
    static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive],
                     locale: Locale(identifier: "en_US_POSIX"))
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    static func isGeneric(_ text: String) -> Bool {
        let key = normalized(text).trimmingCharacters(in: CharacterSet(charactersIn: ".\u{2026}"))
        return ["", "open", "open app", "abrir", "abrir app", "abrir aplicacion"].contains(key)
    }

    static func name(title: String, subtitle: String?, slot: Int) -> String {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let subtitle = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        // The system may describe an Open App action in its subtitle.
        if isGeneric(title) { return isGeneric(subtitle) ? "App \(slot)" : subtitle }
        return title
    }

    static func artworkQuery(for name: String) -> String? {
        var value = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isGeneric(value) else { return nil }
        // Only remove explicit Open App action prefixes, not arbitrary words.
        for prefix in ["open ", "abrir "] {
            if value.lowercased().hasPrefix(prefix) {
                value = String(value.dropFirst(prefix.count))
                break
            }
        }
        guard !isGeneric(value), value.utf8.count <= 160,
              !value.lowercased().hasPrefix("app ") else { return nil }
        return value
    }

    static func initials(for name: String) -> String {
        let value = artworkQuery(for: name) ?? name
        let words = value.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        if words.count > 1 {
            return words.prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
        }
        return String((words.first.map(String.init) ?? "?").prefix(2)).uppercased()
    }

    // Verified App Store identities, not URL schemes or executable identifiers.
    // Other names require a unique, exact catalogue match; never use the first hit.
    static func pinnedStoreID(for name: String) -> Int? {
        switch normalized(name) {
        case "whatsapp", "whatsapp messenger": return 310633997
        case "chatgpt": return 6448311069
        default: return nil
        }
    }

    static func matchingResult(_ results: [StoreArtworkResult], query: String) -> StoreArtworkResult? {
        let matches: [StoreArtworkResult]
        if let id = pinnedStoreID(for: query) {
            matches = results.filter { $0.trackId == id }
        } else {
            matches = results.filter { normalized($0.trackName) == normalized(query) }
        }
        guard Set(matches.map(\.trackId)).count == 1 else { return nil }
        return matches.first
    }

    static func isAppleArtworkURL(_ url: URL) -> Bool {
        guard url.scheme == "https", let host = url.host?.lowercased(),
              url.user == nil, url.password == nil else { return false }
        return host == "mzstatic.com" || host.hasSuffix(".mzstatic.com")
    }

    static func storefrontCountry(_ identifier: String?) -> String {
        let candidate = (identifier ?? "").uppercased()
        guard candidate.utf8.count == 2,
              candidate.utf8.allSatisfy({ (65...90).contains($0) }) else { return "US" }
        return candidate
    }

    static func cacheFilename(for key: String) -> String {
        // Stable across processes. Each cache record also validates the full key.
        var hash: UInt64 = 14695981039346656037
        for byte in key.utf8 { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
        return String(hash, radix: 16) + ".json"
    }
}
