import SwiftUI
#if os(iOS)
import FamilyControls
#endif

struct ContentView: View {
#if os(iOS)
    @StateObject private var inventory = AppInventory()
#endif

    var body: some View {
#if os(iOS)
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Automatic App Discovery")
                                .font(.headline)
                            Text(inventory.status)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if inventory.isLoading { ProgressView() }
                    }

                    Button("Authorize & Scan") {
                        Task { await inventory.authorizeAndScan() }
                    }
                    .buttonStyle(.borderedProminent)
                }

                ForEach(groupedCategories, id: \.0) { category, apps in
                    Section("\(category) · \(apps.count)") {
                        ForEach(apps) { app in
                            HStack(spacing: 12) {
                                if let token = app.token {
                                    Label(token)
                                        .labelStyle(.iconOnly)
                                        .frame(width: 34, height: 34)
                                } else {
                                    Image(systemName: "app")
                                        .frame(width: 34, height: 34)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    if let token = app.token {
                                        Label(token)
                                            .labelStyle(.titleOnly)
                                            .lineLimit(1)
                                    } else {
                                        Text(app.bundleIdentifier)
                                            .lineLimit(1)
                                    }
                                    Text(app.bundleIdentifier)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("DanLauncher")
            .refreshable {
                try? await inventory.scan()
            }
        }
#else
        Text("DanLauncher automatic discovery is available on iPhone.")
            .padding()
#endif
    }

#if os(iOS)
    private var groupedCategories: [(String, [DetectedApp])] {
        Dictionary(grouping: inventory.apps, by: \.category)
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
#endif
}

#Preview {
    ContentView()
}
