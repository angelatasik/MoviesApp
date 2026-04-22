// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MoviesCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        .library(name: "MoviesCore", targets: ["MoviesCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "MoviesCore",
            dependencies: ["Kingfisher"]
        )
    ]
)
