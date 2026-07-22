import SwiftUI

/// The semantic color palette used by Swift95 components.
///
/// Components select colors by purpose, so changing a value updates every
/// component that uses that semantic role. Start with ``classic`` when only a
/// few roles need customization.
///
/// ```swift
/// var colors = Colors95.classic
/// colors.accent = .purple
///
/// let theme = Theme95(
///   colors: colors,
///   metrics: .classic,
///   fonts: .classic
/// )
/// ```
public struct Colors95: Sendable {
  /// The primary surface color.
  public var background: Color
  /// The background of a workspace or desktop surface.
  public var workspaceBackground: Color
  /// The primary text color.
  public var text: Color
  /// Text displayed on an inverted surface.
  public var textInverted: Color
  /// Text for disabled controls.
  public var textDisabled: Color
  /// The light edge of embossed disabled text.
  public var textDisabledHighlight: Color
  /// The primary interactive emphasis color.
  public var accent: Color
  /// Text displayed on the accent color.
  public var accentText: Color
  /// The color of an unvisited link.
  public var link: Color
  /// The color of a visited link.
  public var linkVisited: Color
  /// The background of an editable input.
  public var inputBackground: Color
  /// The background of a disabled input.
  public var inputBackgroundDisabled: Color
  /// The background of inactive chrome.
  public var inactiveBackground: Color
  /// Text displayed on inactive chrome.
  public var inactiveText: Color
  /// The darkest border edge.
  public var borderDarkest: Color
  /// A dark border edge.
  public var borderDark: Color
  /// A light border edge.
  public var borderLight: Color
  /// A lighter border edge.
  public var borderLighter: Color
  /// The lightest border edge.
  public var borderLightest: Color

  /// Creates a semantic Swift95 color palette.
  ///
  /// - Parameters:
  ///   - background: The primary control and panel surface.
  ///   - workspaceBackground: The background of workspace and desktop surfaces.
  ///   - text: The primary foreground color.
  ///   - textInverted: Text shown on an inverted surface.
  ///   - textDisabled: Text used by disabled controls.
  ///   - textDisabledHighlight: The light edge used for embossed disabled text.
  ///   - accent: The primary interactive emphasis color.
  ///   - accentText: Text displayed on the accent color.
  ///   - link: The color of an unvisited link.
  ///   - linkVisited: The color of a visited link.
  ///   - inputBackground: The background of an editable input.
  ///   - inputBackgroundDisabled: The background of a disabled input.
  ///   - inactiveBackground: The background of inactive chrome.
  ///   - inactiveText: Text displayed on inactive chrome.
  ///   - borderDarkest: The darkest bevel or border edge.
  ///   - borderDark: A dark bevel or border edge.
  ///   - borderLight: A light bevel or border edge.
  ///   - borderLighter: A lighter bevel or border edge.
  ///   - borderLightest: The lightest bevel or border edge.
  public init(
    background: Color,
    workspaceBackground: Color,
    text: Color,
    textInverted: Color,
    textDisabled: Color,
    textDisabledHighlight: Color,
    accent: Color,
    accentText: Color,
    link: Color,
    linkVisited: Color,
    inputBackground: Color,
    inputBackgroundDisabled: Color,
    inactiveBackground: Color,
    inactiveText: Color,
    borderDarkest: Color,
    borderDark: Color,
    borderLight: Color,
    borderLighter: Color,
    borderLightest: Color
  ) {
    self.background = background
    self.workspaceBackground = workspaceBackground
    self.text = text
    self.textInverted = textInverted
    self.textDisabled = textDisabled
    self.textDisabledHighlight = textDisabledHighlight
    self.accent = accent
    self.accentText = accentText
    self.link = link
    self.linkVisited = linkVisited
    self.inputBackground = inputBackground
    self.inputBackgroundDisabled = inputBackgroundDisabled
    self.inactiveBackground = inactiveBackground
    self.inactiveText = inactiveText
    self.borderDarkest = borderDarkest
    self.borderDark = borderDark
    self.borderLight = borderLight
    self.borderLighter = borderLighter
    self.borderLightest = borderLightest
  }

  /// The default Windows 95-inspired palette.
  ///
  /// Use this value directly or copy it into a variable and customize individual
  /// semantic roles.
  public static let classic = Colors95(
    background: .rgb95(0xC3, 0xC7, 0xCB),
    workspaceBackground: .rgb95(0x00, 0x80, 0x80),
    text: .rgb95(0x00, 0x00, 0x00),
    textInverted: .rgb95(0xFF, 0xFF, 0xFF),
    textDisabled: .rgb95(0x86, 0x8A, 0x8E),
    textDisabledHighlight: .rgb95(0xD2, 0xD2, 0xD2),
    accent: .rgb95(0x00, 0x0E, 0x7A),
    accentText: .rgb95(0xFE, 0xFE, 0xFE),
    link: .rgb95(0x00, 0x0E, 0x7A),
    linkVisited: .rgb95(0x44, 0x03, 0x81),
    inputBackground: .rgb95(0xFF, 0xFF, 0xFF),
    inputBackgroundDisabled: .rgb95(0xD2, 0xD2, 0xD2),
    inactiveBackground: .rgb95(0x7F, 0x78, 0x7F),
    inactiveText: .rgb95(0xC6, 0xC6, 0xC6),
    borderDarkest: .rgb95(0x00, 0x00, 0x00),
    borderDark: .rgb95(0x86, 0x8A, 0x8E),
    borderLight: .rgb95(0xD2, 0xD2, 0xD2),
    borderLighter: .rgb95(0xE6, 0xE6, 0xE6),
    borderLightest: .rgb95(0xFF, 0xFF, 0xFF)
  )
}

extension Color {
  fileprivate static func rgb95(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Color {
    Color(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: 1
    )
  }
}
