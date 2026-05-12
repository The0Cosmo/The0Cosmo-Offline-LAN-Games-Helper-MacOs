import SwiftUI
import Foundation
import Network

struct Game: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let platforms: [String]?
    let lan_status: String?
    let ports: [PortInfo]?
    let host_tutorial: [String]?
    let client_tutorial: [String]?
    let offline_notes: [String]?
    let troubleshooting: [String]?
    let server_support: String?
    let server_notes: [String]?

    var supportsMac: Bool {
        guard let platforms else { return true }
        return platforms.contains { $0.lowercased().contains("mac") || $0.lowercased().contains("darwin") }
    }

    var defaultPort: String {
        guard let first = ports?.first else { return "" }
        return first.range ?? first.port ?? ""
    }
}

struct PortInfo: Codable, Hashable {
    let protocolName: String?
    let range: String?
    let port: String?

    enum CodingKeys: String, CodingKey {
        case protocolName = "protocol"
        case range
        case port
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case kiwi = "Kiwi"
    case ocean = "Ocean"
    case graphite = "Graphite"
    case grape = "Grape"
    var id: String { rawValue }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var selectedGame: Game?
    @Published var search = ""
    @Published var showInstalledOnly = false
    @Published var infoText = "Select a game to load its LAN/offline details."
    @Published var isLoadingDetails = false
    @Published var hostIP = "Detect from System Settings / Wi‑Fi"
    @Published var textScale: Double = 1.0
    @Published var theme: AppTheme = .kiwi
    @Published var language = "English"
    @Published var hiddenTools: Set<String> = []
    private var detailsCache: [String: String] = [:]

    var filteredGames: [Game] {
        var list = games.filter { $0.supportsMac }
        if !search.trimmingCharacters(in: .whitespaces).isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
        // Installed detection is intentionally manual/local in this starter macOS version.
        return list
    }

    init() {
        loadGames()
    }

    func loadGames() {
        guard let url = Bundle.module.url(forResource: "games", withExtension: "json") else {
            games = fallbackGames()
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            games = try decoder.decode([Game].self, from: data).filter { $0.supportsMac }
            if games.isEmpty { games = fallbackGames() }
        } catch {
            games = fallbackGames()
        }
    }

    func select(_ game: Game) {
        selectedGame = game
        if let cached = detailsCache[game.name] {
            infoText = cached
            return
        }
        isLoadingDetails = true
        infoText = "Loading \(game.name) details…"
        Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            let built = buildDetails(for: game)
            await MainActor.run {
                self.detailsCache[game.name] = built
                self.infoText = built
                self.isLoadingDetails = false
            }
        }
    }

    func buildDetails(for game: Game) -> String {
        func list(_ items: [String]?) -> String {
            guard let items, !items.isEmpty else { return "- No extra notes." }
            return items.map { "- \($0)" }.joined(separator: "\n")
        }
        let port = game.defaultPort.isEmpty ? "not listed" : game.defaultPort
        return """
        Game: \(game.name)
        LAN/offline status: \(game.lan_status ?? "Supported where the game supports LAN/private hosting")
        Join address: \(hostIP)\(port == "not listed" ? "" : ":\(port)")

        Host steps
        \(list(game.host_tutorial))

        Join steps
        \(list(game.client_tutorial))

        Server support
        - \(game.server_support ?? "in-game host or none listed")
        \(list(game.server_notes))

        Notes
        \(list(game.offline_notes))

        Troubleshooting
        \(list(game.troubleshooting))

        Safety
        - This helper does not bypass DRM, launchers, authentication, anti-cheat, or online services.
        - Use only legitimate installed games and official server tools.
        """
    }

    func copyInvite(mode: String) {
        guard let game = selectedGame else { return }
        let port = game.defaultPort
        let join = port.isEmpty ? hostIP : "\(hostIP):\(port)"
        let text: String
        switch mode {
        case "IP": text = hostIP
        case "IP:Port": text = join
        default:
            text = """
            Game: \(game.name)
            Join: \(join)
            Note: Same LAN/VPN and same game/mod version required.
            """
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func fallbackGames() -> [Game] {
        [
            Game(name: "Minecraft Java Edition", platforms: ["macOS"], lan_status: "LAN / Direct Connect", ports: [PortInfo(protocolName: "TCP", range: "25565", port: nil)], host_tutorial: ["Open to LAN or run an official server."], client_tutorial: ["Multiplayer → Direct Connect → HOST_IP:25565"], offline_notes: ["Use the same version and mods."], troubleshooting: ["Allow incoming connections in macOS Firewall."], server_support: "official/manual", server_notes: nil),
            Game(name: "Terraria", platforms: ["macOS"], lan_status: "Host & Play", ports: [PortInfo(protocolName: "TCP", range: "7777", port: nil)], host_tutorial: ["Use Host & Play."], client_tutorial: ["Join via IP."], offline_notes: nil, troubleshooting: nil, server_support: "in-game host", server_notes: nil),
            Game(name: "Stardew Valley", platforms: ["macOS"], lan_status: "Co-op", ports: nil, host_tutorial: ["Host from Co-op."], client_tutorial: ["Join the same LAN/VPN."], offline_notes: nil, troubleshooting: nil, server_support: "in-game host", server_notes: nil),
            Game(name: "Valheim", platforms: ["macOS"], lan_status: "Private server/direct IP", ports: [PortInfo(protocolName: "UDP", range: "2456", port: nil)], host_tutorial: ["Host from game or official server tools where supported."], client_tutorial: ["Join via IP."], offline_notes: nil, troubleshooting: nil, server_support: "official/manual", server_notes: nil)
        ]
    }
}

struct ThemeColors {
    let bg: Color
    let card: Color
    let text: Color
    let muted: Color
    let accent: Color

    static func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .dark: return .init(bg: Color(red: 0.07, green: 0.09, blue: 0.15), card: Color(red: 0.12, green: 0.16, blue: 0.22), text: .white, muted: .gray, accent: .green)
        case .ocean: return .init(bg: Color(red: 0.93, green: 0.99, blue: 1.0), card: .white, text: Color(red: 0.03, green: 0.20, blue: 0.27), muted: Color(red: 0.08, green: 0.37, blue: 0.46), accent: .cyan)
        case .graphite: return .init(bg: Color(red: 0.06, green: 0.09, blue: 0.16), card: Color(red: 0.12, green: 0.16, blue: 0.24), text: .white, muted: Color(red: 0.80, green: 0.84, blue: 0.89), accent: .blue)
        case .grape: return .init(bg: Color(red: 0.98, green: 0.96, blue: 1.0), card: .white, text: Color(red: 0.18, green: 0.06, blue: 0.40), muted: Color(red: 0.42, green: 0.13, blue: 0.66), accent: .purple)
        case .kiwi: return .init(bg: Color(red: 0.95, green: 0.98, blue: 0.91), card: .white, text: Color(red: 0.10, green: 0.18, blue: 0.02), muted: Color(red: 0.25, green: 0.38, blue: 0.07), accent: .green)
        case .light: return .init(bg: Color(red: 0.97, green: 0.98, blue: 0.96), card: .white, text: Color(red: 0.12, green: 0.16, blue: 0.20), muted: .secondary, accent: .green)
        }
    }
}

struct ContentView: View {
    @StateObject private var model = AppModel()
    @State private var showSettings = false
    @State private var inviteMode = "Short"

    var colors: ThemeColors { ThemeColors.colors(for: model.theme) }

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Offline LAN Games Helper")
                    .font(.title2.bold())
                    .foregroundStyle(colors.text)
                Text("Created by KiwiLiu")
                    .font(.caption)
                    .foregroundStyle(colors.muted)
                TextField("Search games", text: $model.search)
                    .textFieldStyle(.roundedBorder)
                List(model.filteredGames, selection: $model.selectedGame) { game in
                    Button(game.name) { model.select(game) }
                        .buttonStyle(.plain)
                }
                Button("Settings") { showSettings = true }
                    .keyboardShortcut(",")
            }
            .padding()
            .background(colors.bg)
        } detail: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.selectedGame?.name ?? "Home")
                            .font(.system(size: 24 * model.textScale, weight: .bold))
                            .foregroundStyle(colors.text)
                        Text("Host IP: \(model.hostIP)")
                            .foregroundStyle(colors.muted)
                    }
                    Spacer()
                    Button("A-") { model.textScale = max(0.85, model.textScale - 0.1) }
                    Button("A+") { model.textScale = min(1.6, model.textScale + 0.1) }
                    Button("Copy Invite") { model.copyInvite(mode: inviteMode) }
                }
                if model.isLoadingDetails {
                    ProgressView("Loading game info…")
                        .progressViewStyle(.linear)
                }
                ScrollView {
                    Text(model.infoText)
                        .font(.system(size: 14 * model.textScale))
                        .foregroundStyle(colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding()
                        .background(colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
            .background(colors.bg)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(model: model)
                .frame(minWidth: 520, minHeight: 520)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var model: AppModel
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $model.theme) {
                    ForEach(AppTheme.allCases) { theme in Text(theme.rawValue).tag(theme) }
                }
                Slider(value: $model.textScale, in: 0.85...1.6) { Text("Text size") }
            }
            Section("Language") {
                Picker("Language", selection: $model.language) {
                    Text("English").tag("English")
                    Text("Italiano").tag("Italiano")
                }
            }
            Section("Tool Manager") {
                Text("Hide optional tools from the main interface. This does not uninstall external programs or delete games.")
                Toggle("Server Tools hidden", isOn: Binding(get: { model.hiddenTools.contains("server_tools") }, set: { value in if value { model.hiddenTools.insert("server_tools") } else { model.hiddenTools.remove("server_tools") } }))
                Toggle("Controller Tools hidden", isOn: Binding(get: { model.hiddenTools.contains("controller_tools") }, set: { value in if value { model.hiddenTools.insert("controller_tools") } else { model.hiddenTools.remove("controller_tools") } }))
            }
            Section("Privacy") {
                Text("Settings and game detection cache stay on this Mac. The app does not upload invite text or telemetry.")
            }
            Section("Support") {
                Link("PayPal", destination: URL(string: "https://paypal.me/The0Cosmo")!)
                Link("GitHub Sponsors", destination: URL(string: "https://github.com/sponsors/The0Cosmo")!)
            }
        }
        .padding()
    }
}

@main
struct OfflineLANHelperMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
