import SwiftUI
import AppKit
import Network
import GameController

private let paypalDonationURL = "https://paypal.me/The0Cosmo"
private let githubSponsorsURL = "https://github.com/sponsors/The0Cosmo"
private let macRepositoryURL = "https://github.com/The0Cosmo/The0Cosmo-Offline-LAN-Games-Helper-MacOs"
private let appVersion = "1.2.0"
private let donationOfflineMessage = "Donation links require an internet connection. You can copy the link and open it later."
private let localizedText: [String: [String: String]] = [
    "en": [
        "app_title": "Offline LAN Games Helper - macOS",
        "safety_warning": "This app does not emulate servers or bypass online services. Online-only and Windows-only games are intentionally excluded.",
        "offline_local": "LAN IP detection, tutorials, game path selection, and guide export work locally without Python or developer tools.",
        "offline_mode": "Offline Mode: hide or block optional internet/download actions",
        "search": "Search",
        "search_games": "Search games",
        "add_custom_game": "Add Custom Game",
        "refresh_ip": "Refresh IP",
        "copy_ip": "Copy Host IP",
        "detect_path": "Detect Game Path",
        "manual_select_game": "Manual Select Game",
        "launch_game": "Launch Game",
        "firewall_help": "Open macOS System Settings",
        "export_tutorial": "Export Tutorial",
        "log_status": "Log / Status",
        "clear_log": "Clear Log",
        "tutorial": "Tutorial",
        "network": "Network / IP",
        "firewall_permissions": "Firewall / Permissions",
        "game_path": "Game Path",
        "server_tools": "Server Tools",
        "lan_test": "LAN Test",
        "invite": "Invite",
        "backups": "Backups",
        "mods": "Mods",
        "controller_helper": "Controller Helper",
        "troubleshooting": "Troubleshooting",
        "settings": "Settings",
        "support": "Support",
        "privacy": "Privacy",
        "language": "Language",
        "theme": "Theme",
        "light": "Light",
        "dark": "Dark",
        "system": "System default",
        "default_behavior": "Default Behavior",
        "show_safety_warnings": "Show safety warnings",
        "remember_last_game": "Remember last selected game",
        "paths": "Paths",
        "default_export_folder": "Default export folder",
        "default_backup_folder": "Default backup folder",
        "prism_launcher_path": "Prism Launcher path",
        "privacy_local": "This app works locally and does not collect or upload personal data.",
        "support_project": "Support the Project",
        "donate": "Donate with PayPal",
        "sponsor": "Sponsor on GitHub",
        "copy_donation": "Copy Donation Link",
        "open_privacy": "Open Privacy Policy",
        "open_repo": "Open GitHub Repository",
        "about": "About",
        "author": "Author: The0Cosmo",
        "license": "Personal, non-commercial use only. See LICENSE for full terms."
    ],
    "it": [
        "app_title": "Offline LAN Games Helper - macOS",
        "safety_warning": "Questa app non emula server e non aggira servizi online. I giochi solo online o solo Windows sono esclusi.",
        "offline_local": "IP LAN, tutorial, selezione percorso gioco ed export guide funzionano localmente senza Python o strumenti sviluppatore.",
        "offline_mode": "Modalita offline: nasconde o blocca azioni internet/download opzionali",
        "search": "Cerca",
        "search_games": "Cerca giochi",
        "add_custom_game": "Aggiungi gioco personalizzato",
        "refresh_ip": "Aggiorna IP",
        "copy_ip": "Copia IP host",
        "detect_path": "Rileva percorso gioco",
        "manual_select_game": "Seleziona gioco manualmente",
        "launch_game": "Avvia gioco",
        "firewall_help": "Apri Impostazioni di macOS",
        "export_tutorial": "Esporta tutorial",
        "log_status": "Log / Stato",
        "clear_log": "Pulisci log",
        "tutorial": "Tutorial",
        "network": "Rete / IP",
        "firewall_permissions": "Firewall / Permessi",
        "game_path": "Percorso gioco",
        "server_tools": "Strumenti server",
        "lan_test": "Test LAN",
        "invite": "Invito",
        "backups": "Backup",
        "mods": "Mod",
        "controller_helper": "Aiuto controller",
        "troubleshooting": "Risoluzione problemi",
        "settings": "Impostazioni",
        "support": "Supporto",
        "privacy": "Privacy",
        "language": "Lingua",
        "theme": "Tema",
        "light": "Chiaro",
        "dark": "Scuro",
        "system": "Predefinito di sistema",
        "default_behavior": "Comportamento predefinito",
        "show_safety_warnings": "Mostra avvisi di sicurezza",
        "remember_last_game": "Ricorda ultimo gioco selezionato",
        "paths": "Percorsi",
        "default_export_folder": "Cartella export predefinita",
        "default_backup_folder": "Cartella backup predefinita",
        "prism_launcher_path": "Percorso Prism Launcher",
        "privacy_local": "Questa app funziona localmente e non raccoglie o carica dati personali.",
        "support_project": "Supporta il progetto",
        "donate": "Dona con PayPal",
        "sponsor": "Sponsorizza su GitHub",
        "copy_donation": "Copia link donazione",
        "open_privacy": "Apri informativa privacy",
        "open_repo": "Apri repository GitHub",
        "about": "Informazioni",
        "author": "Autore: The0Cosmo",
        "license": "Solo uso personale e non commerciale. Vedi LICENSE per i termini completi."
    ]
]
private let macControllerChecklist = """
macOS Controller Checklist:
1. Connect the controller with USB or Bluetooth.
2. Open Bluetooth Settings and confirm the controller is paired if using Bluetooth.
3. Open Game Controller Settings if your macOS version provides it.
4. Open the game and check its in-game controller settings.
5. If the game is on Steam, try Steam Input for PlayStation, Xbox, or Nintendo controller mapping.
6. If one controller affects multiple local game instances, test separate game profiles or use keyboard/mouse for one player and one controller for another.
"""
private let steamInputChecklist = """
Steam Input Setup Checklist:
1. Open Steam.
2. Add the game or launcher as a Non-Steam Game if needed.
3. Open Controller Settings.
4. Enable the controller type you use.
5. Test the controller in Steam.
6. Launch the game through Steam if required.
"""
private let minecraftPrismControllerNote = """
Minecraft Java controller mods may not isolate input per window on macOS. If one controller affects multiple instances, use keyboard/mouse for one player and one controller for another, or test separate game profiles.

- Do not use Controlify and MidnightControls together.
- Use only one controller mod at a time.
- For Prism Launcher, keep separate instances and configs per player if testing controller mods.
"""

private let privacyText = """
Privacy Policy

Offline LAN Games Helper is designed to work locally on your device.

Data Collection
- This app does not collect, sell, share, or upload personal data.

Network Information
- The app may read your hostname, local/private IPv4 addresses, and network interface names.
- This information is shown only inside the app so you can set up LAN/offline multiplayer.
- LAN tests only use IP addresses entered or selected by you. The app does not scan random IP ranges or the internet.

Local Configuration
- The app may save selected game paths, custom games, selected server paths, controller profile notes, and exported guides.
- These files stay on your device.

Settings and Language
- The app may save local preferences such as selected language, theme, selected paths, and offline mode.
- These settings stay on your device and are not uploaded.

Internet Access
- Normal LAN helper features should not require internet access.
- If Server Tools opens official download pages or uses official tools such as SteamCMD, those tools may connect to official services.
- Official download pages, SteamCMD, update checks if added later, and donation links use the internet only after you click the relevant button.
- This app has no telemetry, analytics, or background uploads.

Donations
- The app may include optional donation links such as PayPal.Me or GitHub Sponsors.
- The app does not process payments, collect payment information, or contact donation services automatically.
- Donation links open in your default web browser only when you click them.

macOS Controller Helper
- The macOS version may use local macOS controller APIs to show connected controller names and basic local status.
- This information stays on your device.
- The app does not upload controller data, process lists, or personal data.
- The app does not install drivers, hook input, or modify games.

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

    @AppStorage("language") private var language = "en"
    @AppStorage("theme") private var themePreference = "system"
    @AppStorage("defaultOfflineMode") private var defaultOfflineMode = false
    @AppStorage("showSafetyWarnings") private var showSafetyWarnings = true
    @AppStorage("rememberLastSelectedGame") private var rememberLastSelectedGame = true
    @AppStorage("lastSelectedGameID") private var lastSelectedGameID = ""
    @AppStorage("prismLauncherPath") private var prismLauncherPath = ""
    @AppStorage("defaultExportFolder") private var defaultExportFolder = ""
    @AppStorage("defaultBackupFolder") private var defaultBackupFolder = ""

    @State private var builtInGames = GameCatalog.loadBuiltInGames()
    @State private var selectedGameID: String?
    @State private var selectedIP = ""
    @State private var searchText = ""
    @State private var logLines: [String] = []
    @State private var showingCustomGameSheet = false
    @State private var offlineMode = false
    @State private var lanTestIP = ""
    @State private var lanTestPort = ""
    @State private var lanTestResult = "LAN tests use only one IP address entered or selected by you."
    @State private var saveFolderPath = ""
    @State private var modFolderPath = ""
    @State private var serverProcesses: [String: Process] = [:]
    @State private var controllerInfos: [MacControllerInfo] = []
    @State private var controllerProfileGame = ""
    @State private var controllerProfileName = ""
    @State private var controllerProfileConnection = ""
    @State private var controllerProfileNotes = ""
    @State private var controllerProfileRecommendation = "Use native game controller support first. If needed, test Steam Input."

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

    private var preferredScheme: ColorScheme? {
        switch themePreference {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    private func t(_ key: String) -> String {
        localizedText[language]?[key] ?? localizedText["en"]?[key] ?? key
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
            offlineMode = defaultOfflineMode
            if rememberLastSelectedGame, allGames.contains(where: { $0.id == lastSelectedGameID }) {
                selectedGameID = lastSelectedGameID
            } else {
                selectedGameID = selectedGame?.id
            }
            selectedIP = network.primaryIP
            lanTestIP = network.primaryIP
            if let game = selectedGame {
                lanTestPort = defaultTCPPort(for: game)
                saveFolderPath = configStore.saveFolder(for: game) ?? ""
                modFolderPath = configStore.modFolder(for: game) ?? ""
                controllerProfileGame = game.name
            }
            refreshControllers()
            log("App started.")
        }
        .onChange(of: searchText) { _ in
            if let first = filteredGames.first, !filteredGames.contains(where: { $0.id == selectedGameID }) {
                selectedGameID = first.id
            }
        }
        .onChange(of: selectedGameID) { _ in
            if let game = selectedGame {
                if rememberLastSelectedGame {
                    lastSelectedGameID = game.id
                }
                lanTestPort = defaultTCPPort(for: game)
                saveFolderPath = configStore.saveFolder(for: game) ?? ""
                modFolderPath = configStore.modFolder(for: game) ?? ""
                controllerProfileGame = game.name
                log("Selected game: \(game.name)")
            }
        }
        .sheet(isPresented: $showingCustomGameSheet) {
            CustomGameSheet { game in
                configStore.addCustomGame(game)
                selectedGameID = game.id
                log("Custom game saved: \(game.name)")
            }
        }
        .preferredColorScheme(preferredScheme)
    }

    private var header: some View {
        HStack(alignment: .top) {
            KiwiLogoView()
                .frame(width: 58, height: 58)
                .accessibilityLabel("Kiwi LAN logo")
            VStack(alignment: .leading, spacing: 4) {
                Text(t("app_title"))
                    .font(.title2.bold())
                Text("v\(appVersion)  |  The0Cosmo")
                    .foregroundStyle(.secondary)
                if showSafetyWarnings {
                    Text(t("safety_warning"))
                        .foregroundColor(.orange)
                }
                Text(t("offline_local"))
                    .foregroundStyle(.secondary)
                Toggle(t("offline_mode"), isOn: $offlineMode)
                    .toggleStyle(.checkbox)
                    .onChange(of: offlineMode) { value in
                        log("Offline Mode \(value ? "enabled" : "disabled"). Optional internet/download actions are \(value ? "blocked" : "available") when explicitly clicked.")
                    }
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
            Text(t("search"))
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(t("search_games"), text: $searchText)
                .textFieldStyle(.roundedBorder)
            List(selection: $selectedGameID) {
                ForEach(filteredGames) { game in
                    Text(game.custom ? "\(game.name) (custom)" : game.name)
                        .tag(Optional(game.id))
                }
            }
            Button(t("add_custom_game")) {
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
                        .tabItem { Text(t("tutorial")) }
                    NetworkTab(network: network, selectedIP: $selectedIP, copy: copySelectedIP)
                        .tabItem { Text(t("network")) }
                    LanTestView(
                        game: game,
                        targetIP: $lanTestIP,
                        tcpPort: $lanTestPort,
                        result: lanTestResult,
                        onUseSelectedIP: {
                            lanTestIP = selectedIP.isEmpty ? network.primaryIP : selectedIP
                            log("LAN test target IP set to \(lanTestIP).")
                        },
                        onUseDefaultPort: {
                            lanTestPort = defaultTCPPort(for: game)
                            log("LAN test TCP port set to \(lanTestPort.isEmpty ? "not available" : lanTestPort).")
                        },
                        onPing: { pingTest() },
                        onTCPTest: { tcpPortTest() }
                    )
                    .tabItem { Text(t("lan_test")) }
                    TextDocumentView(text: firewallText)
                        .tabItem { Text(t("firewall_permissions")) }
                    TextDocumentView(text: gamePathText(for: game))
                        .tabItem { Text(t("game_path")) }
                    ServerToolsView(
                        game: game,
                        selectedServerPath: configStore.serverPath(for: game),
                        steamcmdPath: configStore.config.steamcmdPath,
                        offlineMode: offlineMode,
                        serverStatus: serverStatusText(for: game),
                        onOpenServerFolder: { openServerFolder(for: game) },
                        onSelectServerFile: { selectServerFile(for: game) },
                        onLaunchServer: { launchServer(for: game) },
                        onStartServer: { startManagedServer(for: game) },
                        onStopServer: { stopManagedServer(for: game) },
                        onOpenServerLog: { openServerLog(for: game) },
                        onSelectSteamCMD: selectSteamCMD,
                        onInstallWithSteamCMD: { installWithSteamCMD(for: game) },
                        onOpenOfficialDownload: { openOfficialDownload(for: game) },
                        onExportServerGuide: { exportServerGuide(for: game) }
                    )
                    .tabItem { Text(t("server_tools")) }
                    InviteView(inviteText: inviteText(for: game), onCopy: { copyInvite(for: game) }, onExport: { exportInvite(for: game) })
                        .tabItem { Text(t("invite")) }
                    BackupView(saveFolderPath: $saveFolderPath, onSelectFolder: { selectSaveFolder(for: game) }, onCreateBackup: { createSaveBackup(for: game) }, onRestoreBackup: { restoreSaveBackup(for: game) })
                        .tabItem { Text(t("backups")) }
                    ModsView(modFolderPath: $modFolderPath, onSelectFolder: { selectModFolder(for: game) }, onExportModList: { exportModList(for: game) })
                        .tabItem { Text(t("mods")) }
                    ControllerHelperView(
                        controllers: controllerInfos,
                        profiles: configStore.config.controllerProfiles,
                        game: $controllerProfileGame,
                        controllerName: $controllerProfileName,
                        connectionType: $controllerProfileConnection,
                        notes: $controllerProfileNotes,
                        recommendation: $controllerProfileRecommendation,
                        onRefresh: refreshControllers,
                        onOpenBluetooth: { openSystemSettingsURL("x-apple.systempreferences:com.apple.BluetoothSettings", fallback: "Open System Settings and choose Bluetooth.") },
                        onOpenGameController: { openSystemSettingsURL("x-apple.systempreferences:com.apple.Game-Controller-Settings.extension", fallback: "Open System Settings and search for Game Controllers. This pane may not exist on older macOS versions.") },
                        onOpenPrivacy: { openSystemSettingsURL("x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension", fallback: "Open System Settings and choose Privacy & Security.") },
                        onOpenSteamHelp: openSteamControllerHelp,
                        onOpenSteam: openSteamApp,
                        onCopyChecklist: { copyText(macControllerChecklist, label: "macOS controller checklist") },
                        onCopySteamChecklist: { copyText(steamInputChecklist, label: "Steam Input checklist") },
                        onSaveProfile: saveControllerProfile
                    )
                    .tabItem { Text(t("controller_helper")) }
                    TextDocumentView(text: troubleshootingText(for: game))
                        .tabItem { Text(t("troubleshooting")) }
                    SettingsView(
                        language: $language,
                        themePreference: $themePreference,
                        defaultOfflineMode: $defaultOfflineMode,
                        showSafetyWarnings: $showSafetyWarnings,
                        rememberLastSelectedGame: $rememberLastSelectedGame,
                        prismLauncherPath: $prismLauncherPath,
                        defaultExportFolder: $defaultExportFolder,
                        defaultBackupFolder: $defaultBackupFolder,
                        copyDonationLink: copyDonationLink,
                        openPayPalDonation: openPayPalDonation,
                        openGitHubSponsors: openGitHubSponsors,
                        openPrivacyPolicy: openPrivacyPolicy,
                        openRepository: openMacRepository,
                        choosePrismPath: {
                            if let path = choosePath(title: "Select Prism Launcher", files: true, directories: true) {
                                prismLauncherPath = path
                                log("Saved Prism Launcher path: \(path)")
                            }
                        },
                        chooseExportFolder: {
                            if let path = choosePath(title: "Select default export folder", files: false, directories: true) {
                                defaultExportFolder = path
                                log("Saved default export folder: \(path)")
                            }
                        },
                        chooseBackupFolder: {
                            if let path = choosePath(title: "Select default backup folder", files: false, directories: true) {
                                defaultBackupFolder = path
                                log("Saved default backup folder: \(path)")
                            }
                        }
                    )
                    .tabItem { Text(t("settings")) }
                    SupportView(
                        offlineMode: offlineMode,
                        onPayPal: openPayPalDonation,
                        onSponsors: openGitHubSponsors,
                        onCopy: copyDonationLink
                    )
                    .tabItem { Text(t("support")) }
                    TextDocumentView(text: privacyText)
                        .tabItem { Text(t("privacy")) }
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
            Button(t("refresh_ip")) {
                network.refresh()
                selectedIP = network.primaryIP
                log("Network/IP refreshed.")
            }
            Button(t("copy_ip"), action: copySelectedIP)
            Button(t("detect_path")) {
                guard let game = selectedGame else { return }
                detectGamePath(for: game)
            }
            Button(t("manual_select_game")) {
                guard let game = selectedGame else { return }
                selectGamePath(for: game)
            }
            Button(t("launch_game")) {
                guard let game = selectedGame else { return }
                launchGame(game)
            }
            Button(t("firewall_help"), action: openSystemSettings)
            Button(t("export_tutorial")) {
                guard let game = selectedGame else { return }
                exportTutorial(for: game)
            }
        }
        .padding(10)
    }

    private var logPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t("log_status"))
                    .font(.headline)
                Spacer()
                Button(t("clear_log")) {
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

    private func copyText(_ text: String, label: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        log("Copied \(label).")
    }

    private func refreshControllers() {
        controllerInfos = GCController.controllers().map { controller in
            MacControllerInfo(
                name: controller.vendorName ?? controller.productCategory,
                connectionType: "macOS managed connection",
                extendedGamepadAvailable: controller.extendedGamepad != nil,
                microGamepadAvailable: controller.microGamepad != nil
            )
        }
        if let first = controllerInfos.first {
            if controllerProfileName.isEmpty {
                controllerProfileName = first.name
            }
            if controllerProfileConnection.isEmpty {
                controllerProfileConnection = first.connectionType
            }
            log("Controller refresh complete: \(controllerInfos.count) controller(s) detected.")
        } else {
            log("No controller detected by macOS GameController framework.")
        }
    }

    private func openSystemSettingsURL(_ value: String, fallback: String) {
        guard let url = URL(string: value), NSWorkspace.shared.open(url) else {
            log(fallback)
            return
        }
        log("Opened macOS System Settings.")
    }

    private func openSteamApp() {
        let candidates = [
            "/Applications/Steam.app",
            ("~/Applications/Steam.app" as NSString).expandingTildeInPath
        ]
        for path in candidates where FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.open(URL(fileURLWithPath: path))
            log("Opened Steam app: \(path)")
            return
        }
        if let url = URL(string: "steam://open/settings/controller"), NSWorkspace.shared.open(url) {
            log("Opened Steam using the steam:// URL scheme.")
        } else {
            log("Steam app was not found. Open Steam manually if installed.")
        }
    }

    private func openSteamControllerHelp() {
        if let url = URL(string: "https://help.steampowered.com/en/"), NSWorkspace.shared.open(url) {
            log("Opened Steam Support in the browser. Search for Steam Input or Controller Settings if needed.")
        } else {
            log("Open Steam Support manually and search for Steam Input or Controller Settings.")
        }
    }

    private func saveControllerProfile() {
        let cleanGame = controllerProfileGame.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = controllerProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanGame.isEmpty, !cleanName.isEmpty else {
            log("Controller profile requires a game and controller name.")
            return
        }
        let profile = ControllerProfile(
            game: cleanGame,
            controllerName: cleanName,
            connectionType: controllerProfileConnection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown" : controllerProfileConnection.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: controllerProfileNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            recommendedInputSetup: controllerProfileRecommendation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Use native game controller support first." : controllerProfileRecommendation.trimmingCharacters(in: .whitespacesAndNewlines),
            updated: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        )
        configStore.saveControllerProfile(profile)
        log("Saved controller profile for \(profile.game) / \(profile.controllerName).")
    }

    private func pingTest() {
        do {
            let target = try validateSingleIPv4(lanTestIP)
            lanTestResult = "Pinging \(target)..."
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/sbin/ping")
            process.arguments = ["-c", "1", "-W", "1500", target]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            process.terminationHandler = { finished in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async {
                    let status = finished.terminationStatus == 0 ? "reachable" : "not reachable"
                    lanTestResult = "Ping result for \(target): \(status)\n\n\(output)"
                    log("Ping \(target): \(status).")
                }
            }
            try process.run()
        } catch {
            lanTestResult = "Ping failed: \(error.localizedDescription)"
            log("Ping failed: \(error.localizedDescription)")
        }
    }

    private func tcpPortTest() {
        do {
            let target = try validateSingleIPv4(lanTestIP)
            guard let portValue = UInt16(lanTestPort.trimmingCharacters(in: .whitespacesAndNewlines)), let port = NWEndpoint.Port(rawValue: portValue) else {
                lanTestResult = "Enter a TCP port from 1 to 65535."
                log("TCP test blocked: invalid port.")
                return
            }
            lanTestResult = "Testing TCP \(target):\(portValue)..."
            let connection = NWConnection(host: NWEndpoint.Host(target), port: port, using: .tcp)
            let queue = DispatchQueue(label: "offline-lan-helper-tcp-test")
            var finished = false
            func finish(_ message: String) {
                if finished { return }
                finished = true
                connection.cancel()
                DispatchQueue.main.async {
                    lanTestResult = message
                    log(message.replacingOccurrences(of: "\n", with: " "))
                }
            }
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    finish("TCP \(target):\(portValue) is reachable.")
                case .failed(let error):
                    finish("TCP \(target):\(portValue) is not reachable.\n\n\(error.localizedDescription)")
                default:
                    break
                }
            }
            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + 3) {
                finish("TCP \(target):\(portValue) is not reachable.\n\nConnection timed out.")
            }
        } catch {
            lanTestResult = "TCP test failed: \(error.localizedDescription)"
            log("TCP test failed: \(error.localizedDescription)")
        }
    }

    private func inviteText(for game: Game) -> String {
        let ip = selectedIP.isEmpty ? (network.primaryIP.isEmpty ? "HOST_LAN_IP" : network.primaryIP) : selectedIP
        let port = firstPortRange(game.ports) ?? firstPortRange(game.serverPorts) ?? "varies by game/server"
        let steps = game.clientTutorial.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        return """
        Offline LAN invite for \(game.name)

        Host IP: \(ip)
        Port(s): \(port)

        Join steps:
        \(steps.isEmpty ? "Use the game's LAN/local network join option." : steps)

        Notes:
        - Join the same LAN or VPN LAN as the host.
        - Use the same game version and matching mods/content.
        - This invite is for legitimate local/offline play only.
        """
    }

    private func copyInvite(for game: Game) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(inviteText(for: game), forType: .string)
        log("Invite copied for \(game.name).")
    }

    private func exportInvite(for game: Game) {
        writeMarkdown(defaultName: "\(safeFilename(game.name))_Invite.md", text: inviteText(for: game))
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

    private func selectSaveFolder(for game: Game) {
        let panel = NSOpenPanel()
        panel.title = "Select save/world folder for \(game.name)"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Save folder selection canceled.")
            return
        }
        saveFolderPath = url.path
        configStore.setSaveFolder(url.path, for: game)
        log("Save folder selected for \(game.name): \(url.path)")
    }

    private func createSaveBackup(for game: Game) {
        let folder = URL(fileURLWithPath: saveFolderPath)
        guard FileManager.default.fileExists(atPath: folder.path) else {
            log("Select an existing save folder first.")
            return
        }
        let destination = backupsFolder(for: game)
        try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let stamp = backupTimestamp()
        let output = destination.appendingPathComponent("\(safeFilename(folder.lastPathComponent))_\(stamp).zip")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--sequesterRsrc", "--keepParent", folder.path, output.path]
        DispatchQueue.global(qos: .utility).async {
            do {
                try process.run()
                process.waitUntilExit()
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        log("Backup created: \(output.path)")
                    } else {
                        log("Backup failed with exit code \(process.terminationStatus).")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    log("Backup failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func restoreSaveBackup(for game: Game) {
        let target = URL(fileURLWithPath: saveFolderPath)
        guard FileManager.default.fileExists(atPath: target.path) else {
            log("Select an existing restore target save folder first.")
            return
        }
        let panel = NSOpenPanel()
        panel.title = "Select backup zip for \(game.name)"
        panel.directoryURL = backupsFolder(for: game)
        panel.allowedFileTypes = ["zip"]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let backup = panel.url else {
            log("Restore canceled.")
            return
        }
        let alert = NSAlert()
        alert.messageText = "Restore backup?"
        alert.informativeText = "Restore \(backup.lastPathComponent) into \(target.path)? Existing files with the same names may be overwritten. This helper does not delete original saves."
        alert.addButton(withTitle: "Restore")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else {
            log("Restore canceled by user.")
            return
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-x", "-k", backup.path, target.path]
        DispatchQueue.global(qos: .utility).async {
            do {
                try process.run()
                process.waitUntilExit()
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        log("Backup restored into \(target.path).")
                    } else {
                        log("Restore failed with exit code \(process.terminationStatus).")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    log("Restore failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func selectModFolder(for game: Game) {
        let panel = NSOpenPanel()
        panel.title = "Select mods folder for \(game.name)"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Mods folder selection canceled.")
            return
        }
        modFolderPath = url.path
        configStore.setModFolder(url.path, for: game)
        log("Mods folder selected for \(game.name): \(url.path)")
    }

    private func exportModList(for game: Game) {
        let folder = URL(fileURLWithPath: modFolderPath)
        guard let contents = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey], options: [.skipsHiddenFiles]) else {
            log("Select an existing mods folder first.")
            return
        }
        let files = contents.filter { !$0.hasDirectoryPath }.sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var lines = [
            "# \(game.name) - Mod List",
            "",
            "Mods folder: \(folder.path)",
            "Exported: \(dateFormatter.string(from: Date()))",
            "",
            "Compare this list with every player before joining a modded LAN session.",
            "This helper does not download, install, or update mods.",
            "",
            "## Files",
        ]
        if files.isEmpty {
            lines.append("- no files found")
        } else {
            for file in files {
                let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                let modified = values?.contentModificationDate.map { dateFormatter.string(from: $0) } ?? "unknown"
                let size = values?.fileSize ?? 0
                lines.append("- \(file.lastPathComponent) (\(size) bytes, modified \(modified))")
            }
        }
        writeMarkdown(defaultName: "\(safeFilename(game.name))_Mod_List.md", text: lines.joined(separator: "\n"))
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

    private func serverStatusText(for game: Game) -> String {
        if let process = serverProcesses[game.name] {
            if process.isRunning {
                return "running (PID \(process.processIdentifier), started by this app)"
            }
            return "stopped"
        }
        return "stopped"
    }

    private func startManagedServer(for game: Game) {
        if ["none", "in_game_host"].contains(game.serverSupport) {
            log("No supported dedicated server is available for \(game.name). Host from inside the game if supported.")
            return
        }
        if let process = serverProcesses[game.name], process.isRunning {
            log("Server is already running with PID \(process.processIdentifier).")
            return
        }
        guard let path = configStore.serverPath(for: game), FileManager.default.fileExists(atPath: path) else {
            log("Select an official local server file first.")
            return
        }
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        process.executableURL = URL(fileURLWithPath: path)
        do {
            try process.run()
            serverProcesses[game.name] = process
            log("Started server for \(game.name) with PID \(process.processIdentifier).")
        } catch {
            log("Could not start server: \(error.localizedDescription)")
        }
    }

    private func stopManagedServer(for game: Game) {
        guard let process = serverProcesses[game.name], process.isRunning else {
            log("No server process started by this app is currently running for \(game.name).")
            return
        }
        let alert = NSAlert()
        alert.messageText = "Stop server?"
        alert.informativeText = "Stop the server process started by this app?\n\nPID: \(process.processIdentifier)\nGame: \(game.name)"
        alert.addButton(withTitle: "Stop")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else {
            log("Server stop canceled by user.")
            return
        }
        process.terminate()
        log("Stop requested for \(game.name) server process.")
    }

    private func openServerLog(for game: Game) {
        let configured = configStore.serverLogPath(for: game)
        var candidates: [URL] = []
        if let configured {
            candidates.append(URL(fileURLWithPath: configured))
        }
        if let base = configStore.serverPath(for: game) {
            let folder = URL(fileURLWithPath: base).deletingLastPathComponent()
            if let enumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) {
                for case let url as URL in enumerator {
                    if ["log", "txt"].contains(url.pathExtension.lowercased()) {
                        candidates.append(url)
                    }
                }
            }
        }
        if let logFile = candidates.filter({ FileManager.default.fileExists(atPath: $0.path) }).sorted(by: newerFirst).first {
            NSWorkspace.shared.open(logFile)
            log("Opened server log: \(logFile.path)")
            return
        }
        let panel = NSOpenPanel()
        panel.title = "Select server log for \(game.name)"
        panel.allowedFileTypes = ["log", "txt"]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("No server log selected.")
            return
        }
        configStore.setServerLogPath(url.path, for: game)
        NSWorkspace.shared.open(url)
        log("Opened selected server log: \(url.path)")
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
        if offlineMode {
            log("Offline Mode is enabled. Optional SteamCMD downloads are disabled.")
            return
        }
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
        log("Optional internet action: SteamCMD may connect to official Steam services.")

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
        if offlineMode {
            log("Offline Mode is enabled. Optional official download pages are disabled.")
            return
        }
        guard let url = URL(string: game.officialDownloadURL), !game.officialDownloadURL.isEmpty else {
            log("No official download page is configured for \(game.name).")
            return
        }
        if NSWorkspace.shared.open(url) {
            log("Optional internet action: opened official download page: \(game.officialDownloadURL)")
        } else {
            log("Could not open the official download page. The app remains usable offline for normal LAN-helper features.")
        }
    }

    private func openPayPalDonation() {
        if offlineMode {
            log(donationOfflineMessage)
            return
        }
        if let url = URL(string: paypalDonationURL), NSWorkspace.shared.open(url) {
            log("Opened optional donation link: \(paypalDonationURL)")
        } else {
            log(donationOfflineMessage)
        }
    }

    private func openGitHubSponsors() {
        if offlineMode {
            log(donationOfflineMessage)
            return
        }
        if let url = URL(string: githubSponsorsURL), NSWorkspace.shared.open(url) {
            log("Opened optional sponsor link: \(githubSponsorsURL)")
        } else {
            log(donationOfflineMessage)
        }
    }

    private func copyDonationLink() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(paypalDonationURL, forType: .string)
        log("Copied optional donation link.")
    }

    private func openMacRepository() {
        if let url = URL(string: macRepositoryURL), NSWorkspace.shared.open(url) {
            log("Opened macOS GitHub repository.")
        } else {
            log("Could not open GitHub repository URL.")
        }
    }

    private func openPrivacyPolicy() {
        do {
            let supportRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            let folder = supportRoot.appendingPathComponent("Offline LAN Games Helper", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let file = folder.appendingPathComponent("PRIVACY.md")
            try privacyText.write(to: file, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(file)
            log("Opened local privacy policy file.")
        } catch {
            log("Could not open privacy policy: \(error.localizedDescription)")
        }
    }

    private func choosePath(title: String, files: Bool, directories: Bool) -> String? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = files
        panel.canChooseDirectories = directories
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else {
            log("Path selection canceled.")
            return nil
        }
        return url.path
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
        if !defaultExportFolder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            panel.directoryURL = URL(fileURLWithPath: defaultExportFolder)
        }
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

    private func backupsFolder(for game: Game) -> URL {
        let base: URL
        if !defaultBackupFolder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            base = URL(fileURLWithPath: defaultBackupFolder)
        } else {
            let supportRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            base = supportRoot
                .appendingPathComponent("Offline LAN Games Helper", isDirectory: true)
                .appendingPathComponent("backups", isDirectory: true)
        }
        return base
            .appendingPathComponent(safeFilename(game.name), isDirectory: true)
    }

    private func defaultTCPPort(for game: Game) -> String {
        if let tcp = game.ports.first(where: { $0.proto.uppercased() == "TCP" }), let value = firstPortNumber(tcp.range) {
            return "\(value)"
        }
        if let value = firstPortNumber(firstPortRange(game.ports) ?? "") {
            return "\(value)"
        }
        return ""
    }

    private func newerFirst(_ lhs: URL, _ rhs: URL) -> Bool {
        let left = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
        let right = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
        return (left ?? .distantPast) > (right ?? .distantPast)
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logLines.append("[\(timestamp)] \(message)")
        if logLines.count > 250 {
            logLines.removeFirst(logLines.count - 250)
        }
    }
}

struct KiwiLogoView: View {
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(Color(red: 0.93, green: 0.98, blue: 0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.22)
                            .stroke(Color(red: 0.30, green: 0.57, blue: 0.17), lineWidth: max(2, size * 0.025))
                    )
                Circle()
                    .fill(Color(red: 0.35, green: 0.49, blue: 0.16))
                    .frame(width: size * 0.78, height: size * 0.78)
                Circle()
                    .fill(Color(red: 0.42, green: 0.75, blue: 0.22))
                    .frame(width: size * 0.67, height: size * 0.67)
                Circle()
                    .fill(Color(red: 0.81, green: 0.96, blue: 0.46))
                    .frame(width: size * 0.38, height: size * 0.38)
                ForEach(0..<18, id: \.self) { index in
                    let angle = Double(index) / 18.0 * Double.pi * 2.0
                    let x = center.x + CGFloat(cos(angle)) * size * 0.24
                    let y = center.y + CGFloat(sin(angle)) * size * 0.22
                    Capsule()
                        .fill(Color(red: 0.08, green: 0.14, blue: 0.07))
                        .frame(width: max(2, size * 0.025), height: max(4, size * 0.052))
                        .position(x: x, y: y)
                }
                Circle()
                    .fill(Color(red: 0.96, green: 1.0, blue: 0.82))
                    .frame(width: size * 0.12, height: size * 0.12)
                ForEach(0..<3, id: \.self) { index in
                    let x = center.x + CGFloat(index - 1) * size * 0.19
                    let y = center.y + size * 0.34
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    .stroke(Color(red: 0.13, green: 0.41, blue: 0.16), lineWidth: max(2, size * 0.018))
                    Circle()
                        .fill(Color(red: 0.94, green: 0.99, blue: 0.96))
                        .overlay(Circle().stroke(Color(red: 0.13, green: 0.41, blue: 0.16), lineWidth: max(1, size * 0.012)))
                        .frame(width: size * 0.09, height: size * 0.09)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Binding var language: String
    @Binding var themePreference: String
    @Binding var defaultOfflineMode: Bool
    @Binding var showSafetyWarnings: Bool
    @Binding var rememberLastSelectedGame: Bool
    @Binding var prismLauncherPath: String
    @Binding var defaultExportFolder: String
    @Binding var defaultBackupFolder: String

    let copyDonationLink: () -> Void
    let openPayPalDonation: () -> Void
    let openGitHubSponsors: () -> Void
    let openPrivacyPolicy: () -> Void
    let openRepository: () -> Void
    let choosePrismPath: () -> Void
    let chooseExportFolder: () -> Void
    let chooseBackupFolder: () -> Void

    private func t(_ key: String) -> String {
        localizedText[language]?[key] ?? localizedText["en"]?[key] ?? key
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 14) {
                    KiwiLogoView()
                        .frame(width: 72, height: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(t("settings"))
                            .font(.title2.bold())
                        Text(t("privacy_local"))
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox(t("settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker(t("language"), selection: $language) {
                            Text("English").tag("en")
                            Text("Italiano").tag("it")
                        }
                        .pickerStyle(.segmented)
                        Picker(t("theme"), selection: $themePreference) {
                            Text(t("system")).tag("system")
                            Text(t("light")).tag("light")
                            Text(t("dark")).tag("dark")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(4)
                }

                GroupBox(t("default_behavior")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(t("offline_mode"), isOn: $defaultOfflineMode)
                        Toggle(t("show_safety_warnings"), isOn: $showSafetyWarnings)
                        Toggle(t("remember_last_game"), isOn: $rememberLastSelectedGame)
                    }
                    .padding(4)
                }

                GroupBox(t("paths")) {
                    VStack(alignment: .leading, spacing: 10) {
                        settingsPathRow(title: t("prism_launcher_path"), value: prismLauncherPath, action: choosePrismPath)
                        settingsPathRow(title: t("default_export_folder"), value: defaultExportFolder, action: chooseExportFolder)
                        settingsPathRow(title: t("default_backup_folder"), value: defaultBackupFolder, action: chooseBackupFolder)
                    }
                    .padding(4)
                }

                GroupBox(t("support_project")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Offline LAN Games Helper is free to use. Donations are optional and do not unlock extra features.")
                            .foregroundStyle(.secondary)
                        HStack {
                            Button(t("donate"), action: openPayPalDonation)
                            Button(t("sponsor"), action: openGitHubSponsors)
                            Button(t("copy_donation"), action: copyDonationLink)
                        }
                    }
                    .padding(4)
                }

                GroupBox(t("about")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("""
                        Offline LAN Games Helper - macOS
                        Version: \(appVersion)
                        \(t("author"))
                        \(t("license"))
                        """)
                        .textSelection(.enabled)
                        HStack {
                            Button(t("open_privacy"), action: openPrivacyPolicy)
                            Button(t("open_repo"), action: openRepository)
                        }
                    }
                    .padding(4)
                }
            }
            .padding(14)
        }
    }

    private func settingsPathRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(value.isEmpty ? "Not set" : value)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
                    .padding(6)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Button(language == "it" ? "Seleziona" : "Select", action: action)
            }
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

struct MacControllerInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let connectionType: String
    let extendedGamepadAvailable: Bool
    let microGamepadAvailable: Bool
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

struct LanTestView: View {
    let game: Game
    @Binding var targetIP: String
    @Binding var tcpPort: String
    let result: String
    let onUseSelectedIP: () -> Void
    let onUseDefaultPort: () -> Void
    let onPing: () -> Void
    let onTCPTest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LAN Test / Connection Test")
                .font(.headline)
            Text("Tests one user-entered or selected IP only. This is not a network scanner.")
                .foregroundStyle(.secondary)
            HStack {
                TextField("Target IP", text: $targetIP)
                    .textFieldStyle(.roundedBorder)
                Button("Use Selected Host IP", action: onUseSelectedIP)
            }
            HStack {
                TextField("TCP Port", text: $tcpPort)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 160)
                Button("Use Game Default Port", action: onUseDefaultPort)
            }
            HStack {
                Button("Ping IP", action: onPing)
                Button("Test TCP Port", action: onTCPTest)
            }
            Text("Selected game: \(game.name)")
            Text("Default ports:\n\(formatPorts(game.ports))")
                .textSelection(.enabled)
            ScrollView {
                Text(result)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(8)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(12)
    }
}

struct InviteView: View {
    let inviteText: String
    let onCopy: () -> Void
    let onExport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Copy Invite Message")
                .font(.headline)
            ScrollView {
                Text(inviteText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(8)
            }
            HStack {
                Button("Copy Invite", action: onCopy)
                Button("Export Invite", action: onExport)
            }
        }
        .padding(12)
    }
}

struct BackupView: View {
    @Binding var saveFolderPath: String
    let onSelectFolder: () -> Void
    let onCreateBackup: () -> Void
    let onRestoreBackup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("World / Save Backup")
                .font(.headline)
            Text("Select a save folder, create timestamped zip backups, and restore only after confirmation.")
                .foregroundStyle(.secondary)
            HStack {
                TextField("Save folder", text: $saveFolderPath)
                    .textFieldStyle(.roundedBorder)
                Button("Select Save Folder", action: onSelectFolder)
            }
            HStack {
                Button("Create Backup", action: onCreateBackup)
                Button("Restore Backup", action: onRestoreBackup)
            }
            Text("""
            Backups are stored in Application Support/Offline LAN Games Helper/backups/GAME_NAME.
            Restore can overwrite files with matching names, but this helper does not delete original saves.
            """)
            .textSelection(.enabled)
            Spacer()
        }
        .padding(12)
    }
}

struct ModsView: View {
    @Binding var modFolderPath: String
    let onSelectFolder: () -> Void
    let onExportModList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mod List Export")
                .font(.headline)
            Text("Export mod file names so players can compare matching mod setups. This app does not download mods.")
                .foregroundStyle(.secondary)
            HStack {
                TextField("Mods folder", text: $modFolderPath)
                    .textFieldStyle(.roundedBorder)
                Button("Select Mods Folder", action: onSelectFolder)
            }
            Button("Export Mod List", action: onExportModList)
            Text("For Minecraft Java and other modded games, export the list and compare it with every player before hosting.")
                .textSelection(.enabled)
            Spacer()
        }
        .padding(12)
    }
}

struct SupportView: View {
    let offlineMode: Bool
    let onPayPal: () -> Void
    let onSponsors: () -> Void
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support the Project")
                .font(.headline)
            Text("""
            Offline LAN Games Helper is free to use.

            If this app helped you and you want to support development, you can donate or sponsor the project.

            Donations are optional and do not unlock extra features.
            """)
            .textSelection(.enabled)
            if offlineMode {
                Text(donationOfflineMessage)
                    .foregroundColor(.orange)
            }
            HStack {
                Button("Donate with PayPal", action: onPayPal)
                Button("Sponsor on GitHub", action: onSponsors)
                Button("Copy Donation Link", action: onCopy)
            }
            Text("PayPal: \(paypalDonationURL)\nGitHub Sponsors: \(githubSponsorsURL)")
                .textSelection(.enabled)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(12)
    }
}

struct ControllerHelperView: View {
    let controllers: [MacControllerInfo]
    let profiles: [ControllerProfile]
    @Binding var game: String
    @Binding var controllerName: String
    @Binding var connectionType: String
    @Binding var notes: String
    @Binding var recommendation: String
    let onRefresh: () -> Void
    let onOpenBluetooth: () -> Void
    let onOpenGameController: () -> Void
    let onOpenPrivacy: () -> Void
    let onOpenSteamHelp: () -> Void
    let onOpenSteam: () -> Void
    let onCopyChecklist: () -> Void
    let onCopySteamChecklist: () -> Void
    let onSaveProfile: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Controller Helper")
                    .font(.headline)
                Text("""
                macOS supports many controllers through Bluetooth or USB. Some games support controllers natively, while others may require Steam Input or in-game controller settings.

                This helper does not install drivers, hook input, or modify games. It provides safe local diagnostics and setup guidance.
                """)
                .textSelection(.enabled)

                GroupBox("Connected Controllers") {
                    VStack(alignment: .leading, spacing: 8) {
                        if controllers.isEmpty {
                            Text("No controller detected by macOS GameController framework. Try reconnecting by USB or Bluetooth.")
                                .foregroundColor(.orange)
                        } else {
                            ForEach(controllers) { controller in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(controller.name)
                                        .font(.subheadline.bold())
                                    Text("Connection type: \(controller.connectionType)")
                                    Text("Extended gamepad profile: \(controller.extendedGamepadAvailable ? "available" : "not available")")
                                    Text("Micro gamepad profile: \(controller.microGamepadAvailable ? "available" : "not available")")
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        Button("Refresh Controllers", action: onRefresh)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                GroupBox("macOS Controller Checks") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Button("Open Bluetooth Settings", action: onOpenBluetooth)
                            Button("Open Game Controller Settings if available", action: onOpenGameController)
                            Button("Open Privacy & Security Settings", action: onOpenPrivacy)
                        }
                        HStack {
                            Button("Open Steam Controller Settings help", action: onOpenSteamHelp)
                            Button("Copy macOS Controller Checklist", action: onCopyChecklist)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                GroupBox("Steam Input Guidance") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steam Input can sometimes help PlayStation, Xbox, and Nintendo controllers work in games that do not support them directly.")
                            .textSelection(.enabled)
                        HStack {
                            Button("Open Steam app if installed", action: onOpenSteam)
                            Button("Copy Steam Input Setup Checklist", action: onCopySteamChecklist)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                GroupBox("Minecraft / Prism Launcher Note") {
                    Text(minecraftPrismControllerNote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(4)
                }

                GroupBox("Local Multiplayer Profile Notes") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Game", text: $game)
                            .textFieldStyle(.roundedBorder)
                        TextField("Controller name", text: $controllerName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Connection type", text: $connectionType)
                            .textFieldStyle(.roundedBorder)
                        TextField("Recommended input setup", text: $recommendation)
                            .textFieldStyle(.roundedBorder)
                        Text("Notes")
                        TextEditor(text: $notes)
                            .frame(height: 90)
                            .border(Color(nsColor: .separatorColor))
                        Button("Save Controller Profile", action: onSaveProfile)
                        if !profiles.isEmpty {
                            Text("Saved profiles")
                                .font(.subheadline.bold())
                            ForEach(profiles) { profile in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(profile.game) - \(profile.controllerName)")
                                        .font(.caption.bold())
                                    Text("Connection: \(profile.connectionType)")
                                    Text("Recommended: \(profile.recommendedInputSetup)")
                                    if !profile.notes.isEmpty {
                                        Text("Notes: \(profile.notes)")
                                    }
                                }
                                .font(.caption)
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
            }
            .padding(12)
        }
    }
}

struct ServerToolsView: View {
    let game: Game
    let selectedServerPath: String?
    let steamcmdPath: String
    let offlineMode: Bool
    let serverStatus: String
    let onOpenServerFolder: () -> Void
    let onSelectServerFile: () -> Void
    let onLaunchServer: () -> Void
    let onStartServer: () -> Void
    let onStopServer: () -> Void
    let onOpenServerLog: () -> Void
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
                Server process status: \(serverStatus)
                SteamCMD path: \(steamcmdPath.isEmpty ? "not selected" : steamcmdPath)
                SteamCMD app ID: \(game.steamcmdAppID.isEmpty ? "none" : game.steamcmdAppID)
                Official download page: \(game.officialDownloadURL.isEmpty ? "none" : game.officialDownloadURL)
                Offline Mode: \(offlineMode ? "enabled" : "disabled")

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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button("Open Server Folder", action: onOpenServerFolder)
                        .disabled(dedicatedUnavailable)
                    Button("Select Server File", action: onSelectServerFile)
                        .disabled(dedicatedUnavailable)
                    Button("Launch Server", action: onLaunchServer)
                        .disabled(dedicatedUnavailable)
                    Button("Start Server", action: onStartServer)
                        .disabled(dedicatedUnavailable)
                    Button("Stop Server", action: onStopServer)
                        .disabled(dedicatedUnavailable)
                    Button("Open Server Log", action: onOpenServerLog)
                        .disabled(dedicatedUnavailable)
                }
                HStack {
                    Button("Select SteamCMD", action: onSelectSteamCMD)
                    Button("Install with SteamCMD", action: onInstallWithSteamCMD)
                        .disabled(game.steamcmdAppID.isEmpty || steamcmdPath.isEmpty || offlineMode)
                    Button("Open Official Download Page", action: onOpenOfficialDownload)
                        .disabled(game.officialDownloadURL.isEmpty || offlineMode)
                    Button("Export Server Guide", action: onExportServerGuide)
                }
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

private func firstPortRange(_ ports: [Port]) -> String? {
    ports.first(where: { !$0.range.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })?.range
}

private func firstPortNumber(_ value: String) -> Int? {
    guard let match = value.range(of: #"\d+"#, options: .regularExpression) else {
        return nil
    }
    guard let port = Int(value[match]), (1...65535).contains(port) else {
        return nil
    }
    return port
}

private func validateSingleIPv4(_ value: String) throws -> String {
    let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if raw.contains("/") || raw.contains(",") || raw.contains("-") || raw.contains(" ") {
        throw NSError(domain: "OfflineLANHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Enter one IPv4 address only. IP ranges and scans are not supported."])
    }
    let parts = raw.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count == 4, parts.allSatisfy({ UInt8($0) != nil }) else {
        throw NSError(domain: "OfflineLANHelper", code: 2, userInfo: [NSLocalizedDescriptionKey: "Enter an IPv4 address."])
    }
    return raw
}

private func backupTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    return formatter.string(from: Date())
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
