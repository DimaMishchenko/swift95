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
        traits.userInterfaceStyle = .light
        traits.preferredContentSizeCategory = .large
        traits.layoutDirection = .leftToRight
      }
    }
  }
#endif
