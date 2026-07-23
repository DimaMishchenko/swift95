import SwiftUI

/// A complete set of tokens consumed by Swift95 components.
///
/// Swift95 components read the closest theme from the SwiftUI environment. Use
/// ``classic`` without a modifier for the default appearance, or create a theme
/// and install it with ``SwiftUI/View/theme95(_:)`` for a view hierarchy.
///
/// ```swift
/// var colors = Colors95.classic
/// colors.accent = .purple
///
/// let theme = Theme95(
///   colors: colors,
///   metrics: .classic,
///   fonts: .classic,
///   spacing: .classic
/// )
/// ```
public struct Theme95: Sendable {
  /// The theme's semantic colors.
  public var colors: Colors95
  /// The theme's component measurements.
  public var metrics: Metrics95
  /// The theme's typography.
  public var fonts: Fonts95
  /// The theme's shared spacing scale.
  public var spacing: Spacing95

  /// Creates a theme from its token groups.
  ///
  /// - Parameters:
  ///   - colors: The semantic colors used by components.
  ///   - metrics: The component measurements used by components.
  ///   - fonts: The typography roles and font factory used by components.
  ///   - spacing: The spacing scale used by components and app layouts.
  public init(
    colors: Colors95,
    metrics: Metrics95,
    fonts: Fonts95,
    spacing: Spacing95 = .classic
  ) {
    self.colors = colors
    self.metrics = metrics
    self.fonts = fonts
    self.spacing = spacing
  }

  /// The default Windows 95-inspired theme.
  public static let classic = Theme95(
    colors: .classic,
    metrics: .classic,
    fonts: .classic,
    spacing: .classic
  )
}

extension EnvironmentValues {
  /// The Swift95 theme inherited by the current view.
  ///
  /// The environment returns ``Theme95/classic`` when no ancestor installs a
  /// custom theme.
  ///
  /// ```swift
  /// @Environment(\.theme95) private var theme
  /// ```
  @Entry public var theme95: Theme95 = .classic
}

extension View {
  /// Sets the tokens used by Swift95 components in this view hierarchy.
  ///
  /// The modifier affects only Swift95 components that read `theme95` from the
  /// environment. A nested call can override the theme for a smaller subtree.
  ///
  /// ```swift
  /// ContentView()
  ///   .theme95(customTheme)
  /// ```
  ///
  /// - Parameter theme: The theme inherited by this view and its descendants.
  /// - Returns: A view that supplies the theme through the environment.
  public func theme95(_ theme: Theme95) -> some View {
    environment(\.theme95, theme)
  }
}
