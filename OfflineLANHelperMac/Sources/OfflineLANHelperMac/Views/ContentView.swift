import SwiftUI
import AppKit

private let privacyText = """
Privacy Policy

Offline LAN Games Helper is designed to work locally on your device.

Data Collection
- This app does not collect, sell, share, or upload personal data.

Network Information
- The app may read your hostname, local/private IPv4 addresses, and network interface names.
- This information is shown only inside the app so you can set up LAN/offline multiplayer.

Local Configuration
- The app may save selected game paths, custom games, selected server paths, and exported guides.
- These files stay on your device.

Internet Access
- Normal LAN helper features should not require internet access.
- If Server Tools opens official download pages or uses official tools such as SteamCMD, those tools may connect to official services.

No DRM or Account Bypass
- This app does not bypass DRM, launchers, authentication, game ownership checks, anti-cheat, or online services.

Third-Party Services
- This project is not affiliated with Steam, Valve, Paradox, Epic Games, Rockstar, Riot Games, Mojang, Microsoft, Apple, or any game publisher.

Contact
- For privacy questions, contact The0Cosmo via GitHub.
"""

struct ContentView: View {
    @StateObject private var network = NetworkService()
    @StateObject private var configStore = ConfigStore()

    @State private var builtInGames = GameCatalog.loadBuiltInGames()
    @State private var selectedGameID: String?
    @State private var selectedIP = ""
    @State private var searchText = ""
    @State private var logLines: [String] = []
    @State private var showingCustomGameSheet = false

    private var allGames: [Game] {
        let custom = configStore.config.customGames.filter { $0.platforms.contains("macOS") }
        return (builtInGames + custom).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredGames: [Game] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allGames
        }
        return allGames.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var selectedGame: Game? {
        if let selectedGameID, let game = allGames.first(where: { $0.id == selectedGameID }) {
            return game
        }
        return filteredGames.first
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HStack(spacing: 0) {
                sidebar
                Divider()
                mainPanel
            }
            Divider()
            actions
            Divider()
            logPanel
        }
        .onAppear {
            selectedGameID = selectedGame?.id
            selectedIP = network.primaryIP
            log("App started.")
        }
        .onChange(of: searchText) { _ in
            if let first = filteredGames.first, !filteredGames.contains(where: { $0.id == selectedGameID }) {
                selectedGameID = first.id
            }
        }
        .sheet(isPresented: $showingCustomGameSheet) {
            CustomGameSheet { game in
                configStore.addCustomGame(game)
                selectedGameID = game.id
                log("Custom game saved: \(game.name)")
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Offline LAN Games Helper - macOS")
                    .font(.title2.bold())
                Text("This app does not emulate servers or bypass online services. Online-only and Windows-only games are intentionally excluded.")
                    .foregroundColor(.orange)
                Text("LAN IP detection, tutorials, game path selection, and guide export work locally without Python or developer tools.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Hostname: \(network.hostname)")
                Text("Primary LAN IPv4: \(network.primaryIP.isEmpty ? "not detected" : network.primaryIP)")
                if network.addresses.count > 1 {
                    Text("Multiple LAN/VPN adapters detected.")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(12)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Search")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Search games", text: $searchText)
                .textFieldStyle(.roundedBorder)
            List(selection: $selectedGameID) {
                ForEach(filteredGames) { game in
                    Text(game.custom ? "\(game.name) (custom)" : game.name)
                        .tag(Optional(game.id))
                }
            }
            Button("Add Custom Game") {
                showingCustomGameSheet = true
                log("Clicked: Add Custom Game")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 280)
        .padding(12)
    }

    private var mainPanel: some View {
        Group {
            if let game = selectedGame {
                TabView {
                    TextDocumentView(text: tutorialText(for: game))
                        .tabItem { Text("Tutorial") }
                    NetworkTab(network: network, selectedIP: $selectedIP, copy: copySelectedIP)
                        .tabItem { Text("Network / IP") }
                    TextDocumentView(text: firewallText)
                        .tabItem { Text("Firewall / Permissions") }
                    TextDocumentView(text: gamePathText(for: game))
                        .tabItem { Text("Game Path") }
                    ServerToolsView(
                        game: game,
                        selectedServerPath: configStore.serverPath(for: game),
                        steamcmdPath: configStore.config.steamcmdPath,
                        onOpenServerFolder: { openServerFolder(for: game) },
                        onSelectServerFile: { selectServerFile(for: game) },
                        onLaunchServer: { launchServer(for: game) },
                        onSelectSteamCMD: selectSteamCMD,
                        onInstallWithSteamCMD: { installWithSteamCMD(for: game) },
                        onOpenOfficialDownload: { openOfficialDownload(for: game) },
                        onExportServerGuide: { exportServerGuide(for: game) }
                    )
                    .tabItem { Text("Server Tools") }
                    TextDocumentView(text: troubleshootingText(for: game))
                        .tabItem { Text("Troubleshooting") }
                    TextDocumentView(text: privacyText)
                        .tabItem { Text("Privacy") }
                }
                .padding(8)
            } else {
                Text("No game selected.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var actions: some View {
        HStack {
            Button("Refresh IP") {
                network.refresh()
                selectedIP = network.primaryIP
                log("Network/IP refreshed.")
            }
            Button("Copy Host IP", action: copySelectedIP)
            Button("Detect Game Path") {
                guard let game = selectedGame else { return }
                detectGamePath(for: game)
            }
            Button("Manual Select Game") {
                guard let game = selectedGame else { return }
                selectGamePath(for: game)
            }
            Button("Launch Game") {
                guard let game = selectedGame else { return }
                launchGame(game)
            }
            Button("Open macOS System Settings", action: openSystemSettings)
            Button("Export Tutorial") {
                guard let game = selectedGame else { return }
                exportTutorial(for: game)
            }
        }
        .padding(10)
    }

    private var logPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Log / Status")
                    .font(.headline)
                Spacer()
                Button("Clear Log") {
                    logLines.removeAll()
                }
            }
            ScrollView {
                Text(logLines.joined(separator: "\n"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(height: 110)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(10)
    }

    private var firewallText: String {
        """
        macOS Firewall / Permissions

        On macOS, you may need to allow incoming connections for the game or server app in System Settings. This helper does not silently change firewall settings.

        Normal helper features work offline and do not require Python, Homebrew, pip, PyInstaller, Xcode, or terminal commands.

        Use the Open macOS System Settings button to open System Settings safely. If the exact firewall pane is not available on your macOS version, open System Settings and search for Firewall.
        """
    }

    private func tutorialText(for game: Game) -> String {
        """
        Game: \(game.name)
        Platforms: \(game.platforms.joined(separator: ", "))
        LAN/offline status: \(game.lanStatus)

        Host steps:
        \(formatList(game.hostTutorial))

        Client steps:
        \(formatList(game.clientTutorial))

        Ports:
        \(formatPorts(game.ports))

        Version/mod notes:
        \(formatList(game.offlineNotes))

        Launch notes:
        \(formatList(game.launchNotes))

        Safety:
        - This app does not transform online-only games into LAN games.
        - This app does not bypass DRM, launchers, authentication, licenses, ownership checks, or anti-cheat.
        - This app does not modify game files.
        """
    }

    private func gamePathText(for game: Game) -> String {
        let selected = configStore.path(for: game) ?? detectGamePathWithoutSaving(for: game) ?? "not detected"
        return """
        Game: \(game.name)
        Detected/selected app or executable: \(selected)

        Common macOS paths searched:
        \(formatList(game.commonPathsMacos))

        Steam folders searched:
        \(formatList(game.steamFolders))

        Manual paths are saved locally in Application Support.
        """
    }

    private func troubleshootingText(for game: Game) -> String {
        """
        Game: \(game.name)

        Troubleshooting:
        \(formatList(game.troubleshooting))

        General checklist:
        - Verify host and clients are on the same LAN or VPN LAN.
        - Verify clients can ping the host.
        - Allow incoming connections for the game/server in macOS Firewall.
        - Verify matching game version, mods, DLC, and required content.
        - Do not use this app for online-only or matchmaking-only games.
        """
    }

    private func detectGamePath(for game: Game) {
        guard let path = detectGamePathWithoutSaving(for: game) else {
            log("No app/executable detected for \(game.name). Use Manual Select Game.")
            return
        }
        configStore.setPath(path, for: game)
        log("Detected path for \(game.name): \(path)")
    }

    private func detectGamePathWithoutSaving(for game: Game) -> String? {
        let candidates = game.commonPathsMacos + steamCandidates(for: game)
        for raw in candidates {
            let expanded = (raw as NSString).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expanded) {
                return expanded
            }
        }
        return nil
    }

    private func steamCandidates(for game: Game) -> [String] {
        let steamRoots = [
            "~/Library/Application Support/Steam/steamapps/common",
            "~/Library/Application Support/Steam/steamapps/common/"
        ]
        return game.steamFolders.flatMap { folder in
            steamRoots.map { root in "\(root)/\(folder)" }
        }
    }

    private func selectGamePath(for game: Game) {
        let panel = NSOpenPanel()
        panel.title = "Select app or executable for \(game.name)"
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Manual game selection canceled.")
            return
        }
        configStore.setPath(url.path, for: game)
        log("Saved game path for \(game.name): \(url.path)")
    }

    private func launchGame(_ game: Game) {
        guard let path = configStore.path(for: game) ?? detectGamePathWithoutSaving(for: game) else {
            log("No app/executable path detected for \(game.name).")
            return
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        log("Launched \(game.name) normally: \(path)")
    }

    private func copySelectedIP() {
        let ip = selectedIP.isEmpty ? network.primaryIP : selectedIP
        guard !ip.isEmpty else {
            log("No private LAN IPv4 address was detected.")
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ip, forType: .string)
        log("Copied host IP: \(ip)")
    }

    private func openSystemSettings() {
        let targets = [
            "x-apple.systempreferences:com.apple.Network-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.security?Firewall"
        ]
        for target in targets {
            if let url = URL(string: target), NSWorkspace.shared.open(url) {
                log("Opened macOS System Settings.")
                return
            }
        }
        log("Open System Settings manually and search for Firewall.")
    }

    private func openServerFolder(for game: Game) {
        if ["none", "in_game_host"].contains(game.serverSupport) {
            log("No supported dedicated server is available for \(game.name). Host from inside the game if supported.")
            return
        }
        let folder = serverFolder(for: game)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        NSWorkspace.shared.open(folder)
        log("Opened server folder: \(folder.path)")
    }

    private func selectServerFile(for game: Game) {
        if ["none", "in_game_host"].contains(game.serverSupport) {
            log("No supported dedicated server is available for \(game.name). Host from inside the game if supported.")
            return
        }
        let panel = NSOpenPanel()
        panel.title = "Select official server file for \(game.name)"
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Server file selection canceled.")
            return
        }
        configStore.setServerPath(url.path, for: game)
        log("Saved server file for \(game.name): \(url.path)")
    }

    private func launchServer(for game: Game) {
        if ["none", "in_game_host"].contains(game.serverSupport) {
            log("No supported dedicated server is available for \(game.name). Host from inside the game if supported.")
            return
        }
        guard let path = configStore.serverPath(for: game), FileManager.default.fileExists(atPath: path) else {
            log("Select an official local server file first.")
            return
        }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
        log("Launched server file normally: \(path)")
    }

    private func selectSteamCMD() {
        let panel = NSOpenPanel()
        panel.title = "Select steamcmd.sh or SteamCMD executable"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("SteamCMD selection canceled.")
            return
        }
        configStore.setSteamCMDPath(url.path)
        log("Saved SteamCMD path: \(url.path)")
    }

    private func installWithSteamCMD(for game: Game) {
        guard !game.steamcmdAppID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            log("This game entry does not include a verified official SteamCMD app ID.")
            return
        }
        guard !configStore.config.steamcmdPath.isEmpty else {
            log("Select SteamCMD first.")
            return
        }
        let panel = NSOpenPanel()
        panel.title = "Choose install folder for \(game.name) server"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let installURL = panel.url else {
            log("SteamCMD install canceled.")
            return
        }
        configStore.setServerInstallDirectory(installURL.path, for: game)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: configStore.config.steamcmdPath)
        process.arguments = [
            "+force_install_dir", installURL.path,
            "+login", "anonymous",
            "+app_update", game.steamcmdAppID,
            "validate",
            "+quit"
        ]
        do {
            try process.run()
            log("SteamCMD started for official app ID \(game.steamcmdAppID).")
        } catch {
            log("SteamCMD failed: \(error.localizedDescription)")
        }
    }

    private func openOfficialDownload(for game: Game) {
        guard let url = URL(string: game.officialDownloadURL), !game.officialDownloadURL.isEmpty else {
            log("No official download page is configured for \(game.name).")
            return
        }
        NSWorkspace.shared.open(url)
        log("Opened official download page: \(game.officialDownloadURL)")
    }

    private func exportTutorial(for game: Game) {
        writeMarkdown(defaultName: "\(safeFilename(game.name))_LAN_Tutorial.md", text: exportText(for: game))
    }

    private func exportServerGuide(for game: Game) {
        writeMarkdown(defaultName: "\(safeFilename(game.name))_Server_Guide.md", text: serverExportText(for: game))
    }

    private func writeMarkdown(defaultName: String, text: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = defaultName
        panel.allowedFileTypes = ["md"]
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Export canceled.")
            return
        }
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            log("Exported guide: \(url.path)")
        } catch {
            log("Export failed: \(error.localizedDescription)")
        }
    }

    private func exportText(for game: Game) -> String {
        """
        # \(game.name) - Offline/LAN Tutorial

        Host IP: \(selectedIP.isEmpty ? network.primaryIP : selectedIP)
        LAN/offline status: \(game.lanStatus)

        ## Host Steps
        \(formatList(game.hostTutorial))

        ## Client Steps
        \(formatList(game.clientTutorial))

        ## Ports
        \(formatPorts(game.ports))

        ## Server Tools
        \(serverExportText(for: game))

        ## Troubleshooting
        \(formatList(game.troubleshooting))

        ## Safety
        - No DRM bypass, launcher bypass, authentication bypass, anti-cheat bypass, online-service bypass, or file modification.
        """
    }

    private func serverExportText(for game: Game) -> String {
        """
        # \(game.name) - Server Tools Guide

        Server support: \(game.serverSupport)

        ## Server Notes
        \(formatList(game.serverNotes))

        ## Required Files / Tools
        \(formatList(game.serverFiles))

        ## Install / Download Steps
        \(formatList(game.serverInstallSteps))

        ## Server Ports
        \(formatPorts(game.serverPorts))

        ## Config Files
        \(formatList(game.serverConfigFiles))

        ## Safety
        - Use only official tools, official download pages, verified official SteamCMD app IDs, or user-selected local files.
        - This helper does not emulate online services or bypass authentication.
        """
    }

    private func serverFolder(for game: Game) -> URL {
        let supportRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return supportRoot
            .appendingPathComponent("Offline LAN Games Helper", isDirectory: true)
            .appendingPathComponent("servers", isDirectory: true)
            .appendingPathComponent(safeFilename(game.name), isDirectory: true)
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logLines.append("[\(timestamp)] \(message)")
        if logLines.count > 250 {
            logLines.removeFirst(logLines.count - 250)
        }
    }
}

struct TextDocumentView: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding(8)
        }
    }
}

struct NetworkTab: View {
    @ObservedObject var network: NetworkService
    @Binding var selectedIP: String
    let copy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hostname: \(network.hostname)")
            Text("Primary LAN IPv4: \(network.primaryIP.isEmpty ? "not detected" : network.primaryIP)")
            if network.addresses.count > 1 {
                Text("Warning: multiple LAN/VPN adapters detected. Use the IP on the same network as other players.")
                    .foregroundColor(.orange)
            }
            Picker("Selected IP", selection: $selectedIP) {
                ForEach(network.addresses) { address in
                    Text("\(address.ip) - \(address.interface)").tag(address.ip)
                }
            }
            .frame(maxWidth: 520)
            Button("Copy Selected IP", action: copy)
            Text("All detected private IPv4 addresses:")
                .font(.headline)
            List(network.addresses) { address in
                Text("\(address.ip) - \(address.interface)")
            }
        }
        .padding(12)
    }
}

struct ServerToolsView: View {
    let game: Game
    let selectedServerPath: String?
    let steamcmdPath: String
    let onOpenServerFolder: () -> Void
    let onSelectServerFile: () -> Void
    let onLaunchServer: () -> Void
    let onSelectSteamCMD: () -> Void
    let onInstallWithSteamCMD: () -> Void
    let onOpenOfficialDownload: () -> Void
    let onExportServerGuide: () -> Void

    private var dedicatedUnavailable: Bool {
        ["none", "in_game_host"].contains(game.serverSupport)
    }

    private var supportText: String {
        if game.serverSupport == "none" {
            return "No supported dedicated server is available for this game. Host from inside the game if supported."
        }
        if game.serverSupport == "in_game_host" {
            return "Host from inside the game."
        }
        return game.serverSupport
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                Text("""
                Game: \(game.name)
                Server support: \(supportText)
                Selected server file: \(selectedServerPath ?? "not selected")
                SteamCMD path: \(steamcmdPath.isEmpty ? "not selected" : steamcmdPath)
                SteamCMD app ID: \(game.steamcmdAppID.isEmpty ? "none" : game.steamcmdAppID)
                Official download page: \(game.officialDownloadURL.isEmpty ? "none" : game.officialDownloadURL)

                Optional external tools:
                - LAN IP detection, tutorials, game path selection, and exporting guides work offline inside this app.
                - SteamCMD, official dedicated server files, and official download pages are optional and only needed for games that support those official server tools.
                - This app does not bundle or install unofficial server files.

                Server notes:
                \(formatList(game.serverNotes))

                Required files/tools:
                \(formatList(game.serverFiles))

                Install/download instructions:
                \(formatList(game.serverInstallSteps))

                Launch command notes:
                - \(game.serverLaunchCommandMacos.isEmpty ? "Launch the selected official server file normally." : game.serverLaunchCommandMacos)

                Server ports:
                \(formatPorts(game.serverPorts))

                Config files:
                \(formatList(game.serverConfigFiles))
                """)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding(8)
            }
            HStack {
                Button("Open Server Folder", action: onOpenServerFolder)
                    .disabled(dedicatedUnavailable)
                Button("Select Server File", action: onSelectServerFile)
                    .disabled(dedicatedUnavailable)
                Button("Launch Server", action: onLaunchServer)
                    .disabled(dedicatedUnavailable)
                Button("Select SteamCMD", action: onSelectSteamCMD)
                Button("Install with SteamCMD", action: onInstallWithSteamCMD)
                    .disabled(game.steamcmdAppID.isEmpty || steamcmdPath.isEmpty)
                Button("Open Official Download Page", action: onOpenOfficialDownload)
                    .disabled(game.officialDownloadURL.isEmpty)
                Button("Export Server Guide", action: onExportServerGuide)
            }
        }
        .padding(8)
    }
}

struct CustomGameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var gamePath = ""
    @State private var ports = ""
    @State private var serverSupport = ServerSupport.manualFiles.rawValue
    @State private var serverPath = ""
    @State private var hostTutorial = ""
    @State private var clientTutorial = ""
    @State private var notes = ""

    let onSave: (Game) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add Custom Game")
                .font(.title2.bold())
            Text("Use this only for legitimate macOS games with real offline/LAN support.")
                .foregroundStyle(.secondary)
            TextField("Game name", text: $name)
            HStack {
                TextField("App/executable path", text: $gamePath)
                Button("Browse") { selectPath(into: $gamePath) }
            }
            TextField("Ports, for example TCP:7777, UDP:2456-2458", text: $ports)
            Picker("Server support", selection: $serverSupport) {
                ForEach(ServerSupport.allCases) { support in
                    Text(support.rawValue).tag(support.rawValue)
                }
            }
            HStack {
                TextField("Server file path", text: $serverPath)
                Button("Browse") { selectPath(into: $serverPath) }
            }
            Text("Host tutorial")
            TextEditor(text: $hostTutorial)
                .frame(height: 80)
            Text("Client tutorial")
            TextEditor(text: $clientTutorial)
                .frame(height: 80)
            Text("Notes")
            TextEditor(text: $notes)
                .frame(height: 80)
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save Custom Game") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(16)
        .frame(width: 720, height: 680)
    }

    private func selectPath(into binding: Binding<String>) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.treatsFilePackagesAsDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            binding.wrappedValue = url.path
        }
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteLines = splitLines(notes)
        let game = Game(
            name: cleanName,
            platforms: ["macOS"],
            lanStatus: "Custom user entry. Verify real offline/LAN support before use.",
            commonPathsMacos: gamePath.isEmpty ? [] : [gamePath],
            ports: parsePorts(ports),
            hostTutorial: splitLines(hostTutorial).isEmpty ? ["Add host instructions."] : splitLines(hostTutorial),
            clientTutorial: splitLines(clientTutorial).isEmpty ? ["Add client instructions."] : splitLines(clientTutorial),
            offlineNotes: noteLines.isEmpty ? ["Custom user entry. Use only legitimate games with real offline/LAN support."] : noteLines,
            troubleshooting: ["Verify host and clients are on the same LAN/VPN.", "Allow incoming connections in macOS Firewall if needed."],
            launchNotes: ["Custom game. This helper launches the selected path normally."],
            serverSupport: serverSupport,
            serverNotes: noteLines,
            serverFiles: serverPath.isEmpty ? [] : [URL(fileURLWithPath: serverPath).lastPathComponent],
            serverCommonPathsMacos: serverPath.isEmpty ? [] : [serverPath],
            serverInstallSteps: ["Use official or user-selected local server files only."],
            serverPorts: parsePorts(ports),
            custom: true
        )
        onSave(game)
        dismiss()
    }
}

private func formatList(_ items: [String]) -> String {
    items.isEmpty ? "- none" : items.map { "- \($0)" }.joined(separator: "\n")
}

private func formatPorts(_ ports: [Port]) -> String {
    ports.isEmpty ? "- none listed or varies by configuration" : ports.map { "- \($0.proto.uppercased()) \($0.range)" }.joined(separator: "\n")
}

private func splitLines(_ text: String) -> [String] {
    text.components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

private func parsePorts(_ text: String) -> [Port] {
    text.split(separator: ",").compactMap { chunk in
        let parts = chunk.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else {
            return nil
        }
        let proto = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let range = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard ["TCP", "UDP"].contains(proto), !range.isEmpty else {
            return nil
        }
        return Port(proto: proto, range: range)
    }
}

private func safeFilename(_ value: String) -> String {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
    let scalars = value.unicodeScalars.map { scalar -> Character in
        allowed.contains(scalar) ? Character(scalar) : "_"
    }
    let collapsed = String(scalars).replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
    return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_")).isEmpty ? "game" : collapsed
}
