import Foundation

struct Port: Codable, Hashable {
    var proto: String
    var range: String

    enum CodingKeys: String, CodingKey {
        case proto = "protocol"
        case range
    }
}

enum ServerSupport: String, CaseIterable, Identifiable {
    case none
    case inGameHost = "in_game_host"
    case officialDedicated = "official_dedicated"
    case steamcmd
    case manualFiles = "manual_files"
    case officialDownloadPage = "official_download_page"

    var id: String { rawValue }
}

struct Game: Codable, Hashable, Identifiable {
    var id: String { name }

    var name: String
    var platforms: [String]
    var lanStatus: String
    var exeNames: [String]
    var commonPathsWindows: [String]
    var commonPathsMacos: [String]
    var steamFolders: [String]
    var ports: [Port]
    var hostTutorial: [String]
    var clientTutorial: [String]
    var offlineNotes: [String]
    var troubleshooting: [String]
    var launchNotes: [String]
    var launchURI: String?

    var serverSupport: String
    var serverNotes: [String]
    var serverFiles: [String]
    var steamcmdAppID: String
    var serverExecutableNames: [String]
    var serverCommonPathsWindows: [String]
    var serverCommonPathsMacos: [String]
    var serverInstallSteps: [String]
    var serverLaunchCommandWindows: String
    var serverLaunchCommandMacos: String
    var serverConfigFiles: [String]
    var serverPorts: [Port]
    var officialDownloadURL: String
    var custom: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case platforms
        case lanStatus = "lan_status"
        case exeNames = "exe_names"
        case commonPathsWindows = "common_paths_windows"
        case commonPathsMacos = "common_paths_macos"
        case steamFolders = "steam_folders"
        case ports
        case hostTutorial = "host_tutorial"
        case clientTutorial = "client_tutorial"
        case offlineNotes = "offline_notes"
        case troubleshooting
        case launchNotes = "launch_notes"
        case launchURI = "launch_uri"
        case serverSupport = "server_support"
        case serverNotes = "server_notes"
        case serverFiles = "server_files"
        case steamcmdAppID = "steamcmd_app_id"
        case serverExecutableNames = "server_executable_names"
        case serverCommonPathsWindows = "server_common_paths_windows"
        case serverCommonPathsMacos = "server_common_paths_macos"
        case serverInstallSteps = "server_install_steps"
        case serverLaunchCommandWindows = "server_launch_command_windows"
        case serverLaunchCommandMacos = "server_launch_command_macos"
        case serverConfigFiles = "server_config_files"
        case serverPorts = "server_ports"
        case officialDownloadURL = "official_download_url"
        case custom
    }

    init(
        name: String,
        platforms: [String] = ["macOS"],
        lanStatus: String = "Custom user entry. Verify real offline/LAN support before use.",
        exeNames: [String] = [],
        commonPathsWindows: [String] = [],
        commonPathsMacos: [String] = [],
        steamFolders: [String] = [],
        ports: [Port] = [],
        hostTutorial: [String] = [],
        clientTutorial: [String] = [],
        offlineNotes: [String] = [],
        troubleshooting: [String] = [],
        launchNotes: [String] = [],
        launchURI: String? = nil,
        serverSupport: String = ServerSupport.manualFiles.rawValue,
        serverNotes: [String] = [],
        serverFiles: [String] = [],
        steamcmdAppID: String = "",
        serverExecutableNames: [String] = [],
        serverCommonPathsWindows: [String] = [],
        serverCommonPathsMacos: [String] = [],
        serverInstallSteps: [String] = [],
        serverLaunchCommandWindows: String = "",
        serverLaunchCommandMacos: String = "",
        serverConfigFiles: [String] = [],
        serverPorts: [Port] = [],
        officialDownloadURL: String = "",
        custom: Bool = false
    ) {
        self.name = name
        self.platforms = platforms
        self.lanStatus = lanStatus
        self.exeNames = exeNames
        self.commonPathsWindows = commonPathsWindows
        self.commonPathsMacos = commonPathsMacos
        self.steamFolders = steamFolders
        self.ports = ports
        self.hostTutorial = hostTutorial
        self.clientTutorial = clientTutorial
        self.offlineNotes = offlineNotes
        self.troubleshooting = troubleshooting
        self.launchNotes = launchNotes
        self.launchURI = launchURI
        self.serverSupport = serverSupport
        self.serverNotes = serverNotes
        self.serverFiles = serverFiles
        self.steamcmdAppID = steamcmdAppID
        self.serverExecutableNames = serverExecutableNames
        self.serverCommonPathsWindows = serverCommonPathsWindows
        self.serverCommonPathsMacos = serverCommonPathsMacos
        self.serverInstallSteps = serverInstallSteps
        self.serverLaunchCommandWindows = serverLaunchCommandWindows
        self.serverLaunchCommandMacos = serverLaunchCommandMacos
        self.serverConfigFiles = serverConfigFiles
        self.serverPorts = serverPorts
        self.officialDownloadURL = officialDownloadURL
        self.custom = custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        platforms = try container.decodeIfPresent([String].self, forKey: .platforms) ?? []
        lanStatus = try container.decodeIfPresent(String.self, forKey: .lanStatus) ?? ""
        exeNames = try container.decodeIfPresent([String].self, forKey: .exeNames) ?? []
        commonPathsWindows = try container.decodeIfPresent([String].self, forKey: .commonPathsWindows) ?? []
        commonPathsMacos = try container.decodeIfPresent([String].self, forKey: .commonPathsMacos) ?? []
        steamFolders = try container.decodeIfPresent([String].self, forKey: .steamFolders) ?? []
        ports = try container.decodeIfPresent([Port].self, forKey: .ports) ?? []
        hostTutorial = try container.decodeIfPresent([String].self, forKey: .hostTutorial) ?? []
        clientTutorial = try container.decodeIfPresent([String].self, forKey: .clientTutorial) ?? []
        offlineNotes = try container.decodeIfPresent([String].self, forKey: .offlineNotes) ?? []
        troubleshooting = try container.decodeIfPresent([String].self, forKey: .troubleshooting) ?? []
        launchNotes = try container.decodeIfPresent([String].self, forKey: .launchNotes) ?? []
        launchURI = try container.decodeIfPresent(String.self, forKey: .launchURI)
        serverSupport = try container.decodeIfPresent(String.self, forKey: .serverSupport) ?? ServerSupport.inGameHost.rawValue
        serverNotes = try container.decodeIfPresent([String].self, forKey: .serverNotes) ?? []
        serverFiles = try container.decodeIfPresent([String].self, forKey: .serverFiles) ?? []
        steamcmdAppID = try container.decodeIfPresent(String.self, forKey: .steamcmdAppID) ?? ""
        serverExecutableNames = try container.decodeIfPresent([String].self, forKey: .serverExecutableNames) ?? []
        serverCommonPathsWindows = try container.decodeIfPresent([String].self, forKey: .serverCommonPathsWindows) ?? []
        serverCommonPathsMacos = try container.decodeIfPresent([String].self, forKey: .serverCommonPathsMacos) ?? []
        serverInstallSteps = try container.decodeIfPresent([String].self, forKey: .serverInstallSteps) ?? []
        serverLaunchCommandWindows = try container.decodeIfPresent(String.self, forKey: .serverLaunchCommandWindows) ?? ""
        serverLaunchCommandMacos = try container.decodeIfPresent(String.self, forKey: .serverLaunchCommandMacos) ?? ""
        serverConfigFiles = try container.decodeIfPresent([String].self, forKey: .serverConfigFiles) ?? []
        serverPorts = try container.decodeIfPresent([Port].self, forKey: .serverPorts) ?? []
        officialDownloadURL = try container.decodeIfPresent(String.self, forKey: .officialDownloadURL) ?? ""
        custom = try container.decodeIfPresent(Bool.self, forKey: .custom) ?? false
    }
}
