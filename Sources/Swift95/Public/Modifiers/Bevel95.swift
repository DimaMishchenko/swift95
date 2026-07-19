import SwiftUI

/// The visual depth of a Swift95 bevel.
///
/// Use ``raised`` for controls and surfaces that sit above their surroundings,
/// and ``sunken`` for editable fields and recessed content areas.
public enum Bevel95Style: Sendable {
  /// A control edge that appears elevated above its background.
  case raised
  /// A control edge that appears recessed into its background.
  case sunken
}

public extension View {
  /// Draws a theme-aware Swift95 bevel over this view's bounds.
  ///
  /// The modifier reads the closest ``Theme95`` from the environment. It draws
  /// over the view without changing its layout or hit-testing behavior.
  ///
  /// ```swift
  /// Text("Status")
  ///   .padding(Spacing95[8])
  ///   .background(Theme95.classic.colors.background)
  ///   .bevel95(.raised)
  /// ```
  ///
  /// - Parameter style: Whether the view appears raised or sunken.
  /// - Returns: A view with the selected bevel drawn over its content.
  func bevel95(_ style: Bevel95Style = .raised) -> some View {
    modifier(BevelModifier95(style: style))
  }
}

private struct BevelModifier95: ViewModifier {
  @Environment(\.theme95) private var theme

  let style: Bevel95Style

  func body(content: Content) -> some View {
    content.overlay {
      BevelDrawing95(colors: theme.colors, style: style)
    }
  }
}
