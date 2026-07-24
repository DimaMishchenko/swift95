#if os(iOS)
  import SnapshotTesting
  @testable import Swift95
  import SwiftUI
  import UIKit

  @MainActor
  func snapshotCanvas<Content: View>(
    @ViewBuilder content: () -> Content
  ) -> some View {
    content()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .padding(24)
      .background(Theme95.classic.colors.background)
      .environment(\.theme95, .classic)
      .environment(\.locale, Locale(identifier: "en_US_POSIX"))
      .environment(\.colorScheme, .light)
      .environment(\.horizontalSizeClass, .compact)
      .environment(\.verticalSizeClass, .regular)
      .environment(\.layoutDirection, .leftToRight)
      .transaction { $0.disablesAnimations = true }
  }

  @MainActor
  func snapshotImage<V: View>(height: CGFloat) -> Snapshotting<V, UIImage> {
    .image(
      precision: 1,
      perceptualPrecision: 0.98,
      layout: .fixed(width: 390, height: height),
      traits: snapshotTraits()
    )
  }

  @MainActor
  func snapshotTraits() -> UITraitCollection {
    UITraitCollection { traits in
      MainActor.assumeIsolated {
        traits.displayScale = 1
        traits.userInterfaceIdiom = .phone
        traits.userInterfaceStyle = .light
        traits.preferredContentSizeCategory = .large
        traits.horizontalSizeClass = .compact
        traits.verticalSizeClass = .regular
        traits.layoutDirection = .leftToRight
      }
    }
  }

  /// Adds the runtime device idiom to iPad references because SnapshotTesting's
  /// default identifier contains only the test name and invocation counter.
  @MainActor
  func assertSnapshot95<Value, Format>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
  ) {
    let resolvedName =
      UIDevice.current.userInterfaceIdiom == .pad
      ? [name, "iPad"].compactMap(\.self).joined(separator: ".")
      : name

    assertSnapshot(
      of: try value(),
      as: snapshotting,
      named: resolvedName,
      fileID: fileID,
      file: filePath,
      testName: testName,
      line: line,
      column: column
    )
  }
#endif
