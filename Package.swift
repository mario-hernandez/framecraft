// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FrameCraft",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // GUI App
        .executable(
            name: "FrameCraft",
            targets: ["FrameCraft"]
        ),
        // CLI MCP Server
        .executable(
            name: "framecraft-mcp",
            targets: ["FrameCraftCLI"]
        ),
        // Shared Library
        .library(
            name: "FrameCraftCore",
            targets: ["FrameCraftCore"]
        )
    ],
    targets: [
        // Shared Core Library
        .target(
            name: "FrameCraftCore",
            path: "Sources/FrameCraftCore"
        ),
        // CLI MCP Server
        .executableTarget(
            name: "FrameCraftCLI",
            dependencies: ["FrameCraftCore"],
            path: "Sources/FrameCraftCLI"
        ),
        // GUI App (renamed from HeroGenerator)
        .executableTarget(
            name: "FrameCraft",
            dependencies: ["FrameCraftCore"],
            path: "Sources/HeroGenerator"
        )
    ]
)
