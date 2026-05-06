import Foundation
import Combine

final class ConfigStore: ObservableObject {
    @Published private(set) var config = UserConfig()

    private let configURL: URL

    init() {
        let fileManager = FileManager.default
        let supportRoot = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let appDirectory = supportRoot.appendingPathComponent("Offline LAN Games Helper", isDirectory: true)
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        configURL = appDirectory.appendingPathComponent("user_config.json")
        load()
    }

    func path(for game: Game) -> String? {
        config.paths[game.name]
    }

    func serverPath(for game: Game) -> String? {
        config.serverPaths[game.name]
    }

    func setPath(_ path: String, for game: Game) {
        config.paths[game.name] = path
        save()
    }

    func setServerPath(_ path: String, for game: Game) {
        config.serverPaths[game.name] = path
        save()
    }

    func setServerInstallDirectory(_ path: String, for game: Game) {
        config.serverInstallDirs[game.name] = path
        save()
    }

    func setSteamCMDPath(_ path: String) {
        config.steamcmdPath = path
        save()
    }

    func addCustomGame(_ game: Game) {
        config.customGames.removeAll { $0.name == game.name }
        config.customGames.append(game)
        if let path = game.commonPathsMacos.first, !path.isEmpty {
            config.paths[game.name] = path
        }
        if let serverPath = game.serverCommonPathsMacos.first, !serverPath.isEmpty {
            config.serverPaths[game.name] = serverPath
        }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: configURL) else {
            save()
            return
        }
        do {
            config = try JSONDecoder().decode(UserConfig.self, from: data)
        } catch {
            config = UserConfig()
            save()
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder.pretty.encode(config)
            try data.write(to: configURL, options: [.atomic])
        } catch {
            // The UI logs user-facing actions; config write failures should not crash the app.
        }
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
