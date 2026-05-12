import Foundation

enum GameCatalog {
    static func loadBuiltInGames() -> [Game] {
        let decoder = JSONDecoder()
        let urls = candidateURLs()

        for url in urls {
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            do {
                let games = try decoder.decode([Game].self, from: data)
                return games.filter { $0.platforms.contains("macOS") }
            } catch {
                continue
            }
        }

        return []
    }

    private static func candidateURLs() -> [URL] {
        var urls: [URL] = []
        if let bundled = Bundle.module.url(forResource: "games", withExtension: "json") {
            urls.append(bundled)
        }
        if let mainBundle = Bundle.main.url(forResource: "games", withExtension: "json") {
            urls.append(mainBundle)
        }
        urls.append(URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("games.json"))
        urls.append(URL(fileURLWithPath: FileManager.default.currentDirectoryPath).deletingLastPathComponent().appendingPathComponent("games.json"))
        return urls
    }
}
