import SwiftUI

public struct Colors95: Sendable {
  public var background: Color
  public var text: Color
  public var textInverted: Color
  public var textDisabled: Color
  public var textDisabledHighlight: Color
  public var accent: Color
  public var accentText: Color
  public var link: Color
  public var linkVisited: Color
  public var inputBackground: Color
  public var inputBackgroundDisabled: Color
  public var inactiveBackground: Color
  public var inactiveText: Color
  public var borderDarkest: Color
  public var borderDark: Color
  public var borderLight: Color
  public var borderLighter: Color
  public var borderLightest: Color

  public init(
    background: Color,
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

  public static let classic = Colors95(
    background: .rgb95(0xC3, 0xC7, 0xCB),
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
