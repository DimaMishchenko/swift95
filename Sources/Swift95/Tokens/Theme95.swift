import SwiftUI

/// A complete set of tokens consumed by Swift95 components.
public struct Theme95: Sendable {
  public var colors: Colors95
  public var metrics: Metrics95
  public var fonts: Fonts95

  public init(colors: Colors95, metrics: Metrics95, fonts: Fonts95) {
    self.colors = colors
    self.metrics = metrics
    self.fonts = fonts
  }

  public static let classic = Theme95(
    colors: .classic,
    metrics: .classic,
    fonts: .classic
  )
}

extension EnvironmentValues {
  @Entry public var theme95: Theme95 = .classic
}

extension View {
  /// Sets the tokens used by Swift95 components in this view hierarchy.
  public func theme95(_ theme: Theme95) -> some View {
    environment(\.theme95, theme)
  }
}
