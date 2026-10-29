// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "DocumentationImageGenerator",
  platforms: [
    .macOS(.v15)
  ],
  dependencies: [
    .package(name: "swift95", path: "../..")
  ],
  targets: [
    .executableTarget(
      name: "DocumentationImageGenerator",
      dependencies: [
        .product(name: "Swift95", package: "swift95")
      ]
    )
  ]
)
