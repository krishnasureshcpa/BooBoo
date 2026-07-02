// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BooBoo",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "BooBooCore", targets: ["BooBooCore"]),
        .executable(name: "booboo", targets: ["BooBooCLI"]),
        .executable(name: "BooBooGUI", targets: ["BooBooGUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "BooBooCore",
            dependencies: [],
            path: "Sources/BooBooCore"
        ),
        .executableTarget(
            name: "BooBooCLI",
            dependencies: [
                "BooBooCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/BooBooCLI"
        ),
        .executableTarget(
            name: "BooBooGUI",
            dependencies: ["BooBooCore"],
            path: "Sources/BooBooGUI"
        ),

    ]
)