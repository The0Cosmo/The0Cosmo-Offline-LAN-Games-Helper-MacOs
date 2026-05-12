// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OfflineLANHelperMac",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "OfflineLANHelperMac", targets: ["OfflineLANHelperMac"])
    ],
    targets: [
        .executableTarget(
            name: "OfflineLANHelperMac",
            resources: [.copy("Resources/games.json")]
        )
    ]
)
