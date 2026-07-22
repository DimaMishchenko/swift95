import ProjectDescription

let project = Project(
  name: "Swift95Catalog",
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
        .package(product: "Swift95")
      ]
    )
  ]
)
