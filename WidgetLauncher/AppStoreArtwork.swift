import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Optional presentation-only Apple catalogue access. No account or launch token is sent.
/// Disabled until the user enables "App Store Icons" on that widget.
actor AppStoreArtwork {
    static let shared = AppStoreArtwork()

    private struct CacheRecord: Codable {
        let requestKey: String
        let retryAfter: Date
        let imageData: Data?
    }

    private let session: URLSession
    private let cacheDirectory: URL?
    private var inFlight: [String: Task<Data?, Never>] = [:]
    private var recentRequests: [Date] = []

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 4
        configuration.timeoutIntervalForResource = 5
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.httpShouldSetCookies = false
        session = URLSession(configuration: configuration)
        cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("DanLauncherArtwork-v1", isDirectory: true)
        if let cacheDirectory {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    func image(for name: String, country: String) async -> Data? {
        guard let query = LauncherPresentation.artworkQuery(for: name) else { return nil }
        let key = country + ":" + LauncherPresentation.normalized(query)
        if let task = inFlight[key] { return await task.value }
        let task = Task { await load(query: query, country: country, key: key) }
        inFlight[key] = task
        let result = await task.value
        inFlight[key] = nil
        return result
    }

    private func load(query: String, country: String, key: String) async -> Data? {
        let file = cacheDirectory?.appendingPathComponent(LauncherPresentation.cacheFilename(for: key))
        let cached = readCache(file, key: key)
        if let cached, cached.retryAfter > .now { return cached.imageData }

        // A widget edit/reload must not repeatedly hammer the catalogue API.
        recentRequests.removeAll { Date().timeIntervalSince($0) >= 60 }
        guard recentRequests.count < 16 else { return cached?.imageData }
        recentRequests.append(.now)

        do {
            let url = try catalogueURL(query: query, country: country)
            let json = try await download(url, artwork: false)
            let results = try JSONDecoder().decode(StoreArtworkResponse.self, from: json).results
            guard let match = LauncherPresentation.matchingResult(results, query: query),
                  let artworkURL = match.artworkUrl100 ?? match.artworkUrl512,
                  LauncherPresentation.isAppleArtworkURL(artworkURL) else {
                // No unique match: keep initials, not a random app's icon.
                saveCache(file, key: key, data: nil, delay: 6 * 3600)
                return nil
            }
            let image = try await download(artworkURL, artwork: true)
            saveCache(file, key: key, data: image, delay: 7 * 24 * 3600)
            return image
        } catch {
            // Offline, timeout, decode error: keep a previous icon when available.
            saveCache(file, key: key, data: cached?.imageData, delay: 10 * 60)
            return cached?.imageData
        }
    }

    private func catalogueURL(query: String, country: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        let id = LauncherPresentation.pinnedStoreID(for: query)
        components.path = id == nil ? "/search" : "/lookup"
        components.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "entity", value: "software")
        ]
        if let id {
            components.queryItems?.append(URLQueryItem(name: "id", value: String(id)))
        } else {
            components.queryItems?.append(URLQueryItem(name: "term", value: query))
            components.queryItems?.append(URLQueryItem(name: "limit", value: "20"))
        }
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    private func download(_ url: URL, artwork: Bool) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode),
              !data.isEmpty, data.count <= 1_500_000,
              let finalURL = response.url else { throw URLError(.badServerResponse) }
        if artwork {
            guard LauncherPresentation.isAppleArtworkURL(finalURL),
                  response.mimeType?.hasPrefix("image/") == true else {
                throw URLError(.cannotDecodeContentData)
            }
        } else {
            guard finalURL.scheme == "https", finalURL.host == "itunes.apple.com" else {
                throw URLError(.badServerResponse)
            }
        }
        return data
    }

    private func readCache(_ file: URL?, key: String) -> CacheRecord? {
        guard let file, let data = try? Data(contentsOf: file),
              let record = try? JSONDecoder().decode(CacheRecord.self, from: data),
              record.requestKey == key else { return nil }
        return record
    }

    private func saveCache(_ file: URL?, key: String, data: Data?, delay: TimeInterval) {
        guard let file,
              let encoded = try? JSONEncoder().encode(CacheRecord(
                requestKey: key, retryAfter: Date().addingTimeInterval(delay), imageData: data
              )) else { return }
        try? encoded.write(to: file, options: .atomic)
    }
}
