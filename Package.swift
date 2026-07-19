// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-95",
  platforms: [
    .iOS(.v18),
    .macOS(.v15)
  ],
  products: [
    .library(
      name: "Swift95",
      targets: ["Swift95"]
    )
  ],
  targets: [
    .target(
      name: "Swift95",
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "Swift95Tests",
      dependencies: ["Swift95"]
    )
  ]
)
