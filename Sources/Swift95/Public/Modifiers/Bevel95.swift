import SwiftUI

/// The visual treatment of a complete Swift95 surface.
///
/// Use ``raised`` for controls and surfaces that sit above their surroundings,
/// ``sunken`` for recessed neutral areas, and ``input`` for editable content.
/// Each style supplies its conventional theme background by default.
public enum Bevel95Style: Sendable {
  /// A control edge that appears elevated above its background.
  case raised

  /// A single recessed edge for neutral panels and pressed controls.
  case sunken

  /// A deeply recessed edge and input background for editable content.
  case input
}

/// A nested Swift95 surface treatment made from two bevels.
///
/// Composed bevels reproduce the framed surfaces used by classic panels and
/// input areas. Use ``raisedSunken`` for a neutral inset panel and
/// ``raisedInput`` for a white editable or document surface.
public enum ComposedBevel95Style: Sendable {
  /// A raised outer surface containing a neutral sunken surface.
  case raisedSunken

  /// A raised outer surface containing a deeply recessed input surface.
  case raisedInput
}

public extension View {
  /// Applies a theme-aware Swift95 background and bevel to this view.
  ///
  /// The modifier reads the closest ``Theme95`` from the environment. Raised
  /// and sunken surfaces use ``Colors95/background``; input surfaces use
  /// ``Colors95/inputBackground``. The bevel does not change layout or
  /// hit-testing behavior.
  ///
  /// ```swift
  /// Text("Status")
  ///   .padding(Spacing95[8])
  ///   .bevel95(.raised)
  /// ```
  ///
  /// - Parameter style: The surface treatment to apply.
  /// - Returns: A view with the style's default background and bevel.
  func bevel95(_ style: Bevel95Style = .raised) -> some View {
    modifier(BevelModifier95(style: style, background: nil))
  }

  /// Applies a Swift95 bevel with a custom background style.
  ///
  /// Use this overload when the surface needs a background other than the
  /// selected bevel style's semantic default.
  ///
  /// ```swift
  /// content
  ///   .bevel95(.input, background: Color.yellow)
  /// ```
  ///
  /// - Parameters:
  ///   - style: The surface treatment to apply.
  ///   - background: The style drawn behind the view's content.
  /// - Returns: A view with the custom background and selected bevel.
  func bevel95<Background: ShapeStyle>(
    _ style: Bevel95Style = .raised,
    background: Background
  ) -> some View {
    modifier(
      BevelModifier95(
        style: style,
        background: AnyShapeStyle(background)
      )
    )
  }

  /// Applies a nested Swift95 bevel with configurable space between its edges.
  ///
  /// The modifier adds layout space between the inner and outer bevels. Its
  /// default spacing is four points.
  ///
  /// ```swift
  /// content
  ///   .bevel95(.raisedSunken)
  ///
  /// editor
  ///   .bevel95(.raisedInput, spacing: Spacing95[6])
  /// ```
  ///
  /// - Parameters:
  ///   - style: The nested surface treatment to apply.
  ///   - spacing: The nonnegative distance between the two bevels.
  /// - Returns: A view with nested inner and outer bevels.
  func bevel95(
    _ style: ComposedBevel95Style,
    spacing: CGFloat = Spacing95[4]
  ) -> some View {
    precondition(spacing >= 0, "Composed bevel spacing must be nonnegative")
    return modifier(ComposedBevelModifier95(style: style, spacing: spacing))
  }
}

private struct ComposedBevelModifier95: ViewModifier {
  let style: ComposedBevel95Style
  let spacing: CGFloat

  func body(content: Content) -> some View {
    switch style {
    case .raisedSunken:
      content
        .bevel95(.sunken)
        .padding(spacing)
        .bevel95(.raised)
    case .raisedInput:
      content
        .bevel95(.input)
        .padding(spacing)
        .bevel95(.raised)
    }
  }
}

private struct BevelModifier95: ViewModifier {
  @Environment(\.theme95) private var theme

  let style: Bevel95Style
  let background: AnyShapeStyle?

  func body(content: Content) -> some View {
    content
      .background(background ?? AnyShapeStyle(style.defaultBackground(in: theme.colors)))
      .overlay {
        BevelDrawing95(colors: theme.colors, style: style)
      }
  }
}

private extension Bevel95Style {
  func defaultBackground(in colors: Colors95) -> Color {
    switch self {
    case .raised, .sunken:
      colors.background
    case .input:
      colors.inputBackground
    }
  }
}
