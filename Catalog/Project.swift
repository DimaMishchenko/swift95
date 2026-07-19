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
      destinations: .iOS,
      product: .app,
      bundleId: "com.swift95.catalog",
      deploymentTargets: .iOS("18.0"),
      infoPlist: .extendingDefault(
        with: [
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
