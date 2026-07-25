import ProjectDescription

let project = Project(
  name: "Swift95Catalog",
  options: .options(
    automaticSchemesOptions: .enabled()
  ),
  packages: [
    .local(path: .relativeToManifest(".."))
  ],
  settings: .settings(
    base: [
      "SWIFT_VERSION": "6.0"
    ]
  ),
  targets: [
    .target(
      name: "Swift95Catalog",
      destinations: [.iPhone, .iPad, .mac],
      product: .app,
      bundleId: "com.swift95.catalog",
      deploymentTargets: .multiplatform(
        iOS: "18.0",
        macOS: "15.0"
      ),
      infoPlist: .extendingDefault(
        with: [
          "CFBundleDisplayName": "Swift95 Catalog",
          "CFBundleName": "Swift95 Catalog",
          "UILaunchScreen": [:],
          "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false
          ]
        ]
      ),
      sources: ["Swift95Catalog/Sources/**"],
      dependencies: [
        .package(product: "Swift95"),
        .package(product: "Swift95Icons")
      ]
    ),
    .target(
      name: "Swift95Tests",
      destinations: [.iPhone, .iPad, .mac],
      product: .unitTests,
      bundleId: "com.swift95.tests",
      deploymentTargets: .multiplatform(
        iOS: "18.0",
        macOS: "15.0"
      ),
      infoPlist: .default,
      sources: ["../Tests/Swift95Tests/**/*.swift"],
      dependencies: [
        .target(name: "Swift95Catalog"),
        .package(product: "Swift95"),
        .package(product: "SnapshotTesting")
      ]
    ),
    .target(
      name: "Swift95UITests",
      destinations: [.iPhone, .iPad, .mac],
      product: .uiTests,
      bundleId: "com.swift95.ui-tests",
      deploymentTargets: .multiplatform(
        iOS: "18.0",
        macOS: "15.0"
      ),
      infoPlist: .default,
      sources: ["Swift95UITests/Sources/**"],
      dependencies: [
        .target(name: "Swift95Catalog")
      ]
    )
  ]
)
