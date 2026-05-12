import Foundation

struct ControllerProfile: Codable, Hashable, Identifiable {
    var id: String { "\(game)|\(controllerName)|\(updated)" }

    var game: String
    var controllerName: String
    var connectionType: String
    var notes: String
    var recommendedInputSetup: String
    var updated: String

    enum CodingKeys: String, CodingKey {
        case game
        case controllerName = "controller_name"
        case connectionType = "connection_type"
        case notes
        case recommendedInputSetup = "recommended_input_setup"
        case updated
    }
}

struct UserConfig: Codable {
    var paths: [String: String] = [:]
    var serverPaths: [String: String] = [:]
    var serverInstallDirs: [String: String] = [:]
    var steamcmdPath: String = ""
    var saveFolders: [String: String] = [:]
    var modFolders: [String: String] = [:]
    var serverLogPaths: [String: String] = [:]
    var controllerProfiles: [ControllerProfile] = []
    var customGames: [Game] = []

    enum CodingKeys: String, CodingKey {
        case paths
        case serverPaths = "server_paths"
        case serverInstallDirs = "server_install_dirs"
        case steamcmdPath = "steamcmd_path"
        case saveFolders = "save_folders"
        case modFolders = "mod_folders"
        case serverLogPaths = "server_log_paths"
        case controllerProfiles = "controller_profiles"
        case customGames = "custom_games"
    }
}
