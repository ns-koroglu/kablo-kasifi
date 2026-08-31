// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KabloKasifi",
    platforms: [.macOS("14.0")],
    targets: [
        .executableTarget(
            name: "KabloKasifi",
            path: "Sources/KabloKasifi",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
