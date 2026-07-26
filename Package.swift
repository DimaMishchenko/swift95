// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-95",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v18),
    .macOS(.v15)
  ],
  products: [
    .library(
      name: "Swift95",
      targets: ["Swift95"]
    ),
    .library(
      name: "Swift95Icons",
      targets: ["Swift95Icons"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing",
      .upToNextMajor(from: "1.19.2")
    )
  ],
  targets: [
    .target(
      name: "Swift95",
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "Swift95Icons",
      resources: [
        .copy("Resources/Icons")
      ]
    ),
    .testTarget(
      name: "Swift95Tests",
      dependencies: [
        "Swift95",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      exclude: ["__Snapshots__"]
    ),
    .testTarget(
      name: "Swift95IconsTests",
      dependencies: ["Swift95Icons"]
    )
  ]
)
