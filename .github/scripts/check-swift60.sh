#!/usr/bin/env bash
set -euo pipefail

swift --version
if ! swift --version | grep -Eq 'Swift version 6\.0([ .]|$)'; then
  echo 'Select a Swift 6.0 toolchain before running this check.' >&2
  exit 1
fi
xcrun --sdk macosx --show-sdk-version
xcrun --sdk iphonesimulator --show-sdk-version

export SWIFT95_PACKAGE_PATH
SWIFT95_PACKAGE_PATH="$(cd "$(dirname "$0")/../.." && pwd)"
consumer="$(mktemp -d "${TMPDIR:-/tmp/}swift95-swift60.XXXXXX")"
trap 'rm -rf "$consumer"' EXIT
mkdir -p "$consumer/Sources/Consumer"
cat > "$consumer/Package.swift" <<'SWIFT'
// swift-tools-version: 6.0
import Foundation
import PackageDescription

let package = Package(
  name: "Swift60Consumer",
  platforms: [.iOS(.v18), .macOS(.v15)],
  dependencies: [
    .package(name: "swift95", path: ProcessInfo.processInfo.environment["SWIFT95_PACKAGE_PATH"]!)
  ],
  targets: [
    .target(name: "Consumer", dependencies: [
      .product(name: "Swift95", package: "swift95"),
      .product(name: "Swift95Icons", package: "swift95")
    ])
  ]
)
SWIFT
cat > "$consumer/Sources/Consumer/Consumer.swift" <<'SWIFT'
import SwiftUI
import Swift95
import Swift95Icons

public struct Consumer: View {
  public init() {}

  public var body: some View {
    VStack {
      Icon95(.computer)
      Button95("Hello, Swift95") {}
    }
  }
}
SWIFT

swift build --package-path "$consumer" --configuration release --scratch-path "$SWIFT60_BUILD_PATH-macos"
swift build --package-path "$consumer" --configuration release --scratch-path "$SWIFT60_BUILD_PATH-ios" \
  --sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" --triple arm64-apple-ios18.0-simulator
