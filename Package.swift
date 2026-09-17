// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacClean",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MacClean", targets: ["MacClean"])
    ],
    targets: [
        .executableTarget(
            name: "MacClean",
            resources: [
                // Copies Info.plist, icons, and PrivacyInfo.xcprivacy into the bundle.
                // SPM processes the whole Resources/ directory; PrivacyInfo.xcprivacy
                // is automatically recognised as a privacy manifest by the toolchain.
                .process("Resources")
            ]
        )
    ]
)
