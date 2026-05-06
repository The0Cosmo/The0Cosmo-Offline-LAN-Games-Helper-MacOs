import Foundation

struct UserConfig: Codable {
    var paths: [String: String] = [:]
    var serverPaths: [String: String] = [:]
    var serverInstallDirs: [String: String] = [:]
    var steamcmdPath: String = ""
    var customGames: [Game] = []

    enum CodingKeys: String, CodingKey {
        case paths
        case serverPaths = "server_paths"
        case serverInstallDirs = "server_install_dirs"
        case steamcmdPath = "steamcmd_path"
        case customGames = "custom_games"
    }
}
