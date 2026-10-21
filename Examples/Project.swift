import ProjectDescription

let apps = ["Spotify95", "Slack95", "Finder95"]
let destinations: Destinations = [.iPhone, .iPad, .mac]
let deploymentTargets = DeploymentTargets.multiplatform(iOS: "18.0", macOS: "15.0")

let project = Project(
  name: "Swift95Examples",
  packages: [.local(path: .relativeToManifest(".."))],
  settings: .settings(base: ["SWIFT_VERSION": "6.0"]),
  targets: apps.map { name in
    .target(
      name: name,
      destinations: destinations,
      product: .app,
      bundleId: "com.swift95.examples.\(name.lowercased())",
      deploymentTargets: deploymentTargets,
      infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": .string(name),
        "UILaunchScreen": [:],
        "UIApplicationSceneManifest": ["UIApplicationSupportsMultipleScenes": false]
      ]),
      buildableFolders: [.folder("\(name)/App"), .folder("\(name)/Features")],
      dependencies: [.package(product: "Swift95"), .package(product: "Swift95Icons")]
    )
  },
  schemes: [
    .scheme(
      name: "Examples",
      shared: true,
      buildAction: .buildAction(targets: apps.map { .target($0) })
    )
  ]
)
