import CoreText
import SwiftUI

/// The typography set used by a Swift95 theme.
///
/// Applications can replace every role with an arbitrary SwiftUI `Font`.
public struct Fonts95: Sendable {
  public typealias Factory = @Sendable (CGFloat, Font.Weight, Font.TextStyle?) -> Font

  public var title: Font
  public var title2: Font
  public var title3: Font
  public var body: Font

  private let factory: Factory

  public init(
    title: Font,
    title2: Font,
    title3: Font,
    body: Font
  ) {
    self.init(
      title: title,
      title2: title2,
      title3: title3,
      body: body,
      factory: Fonts95.systemFont
    )
  }

  public init(
    title: Font,
    title2: Font,
    title3: Font,
    body: Font,
    factory: @escaping Factory
  ) {
    self.title = title
    self.title2 = title2
    self.title3 = title3
    self.body = body
    self.factory = factory
  }

  /// Creates a fixed-size font using this theme's font family.
  public func font(
    size: CGFloat,
    weight: Font.Weight = .regular
  ) -> Font {
    factory(size, weight, nil)
  }

  /// Creates a Dynamic Type-aware font using this theme's font family.
  public func font(
    size: CGFloat,
    weight: Font.Weight = .regular,
    relativeTo textStyle: Font.TextStyle
  ) -> Font {
    factory(size, weight, textStyle)
  }

  public static let classic: Fonts95 = {
    let factory: Factory = { size, weight, textStyle in
      FontRegistry95.ensureRegistered()

      let font: Font
      if let textStyle {
        font = .custom("W95FARegular", size: size, relativeTo: textStyle)
      } else {
        font = .custom("W95FARegular", fixedSize: size)
      }
      return font.weight(weight)
    }

    return Fonts95(
      title: factory(32, .regular, .title),
      title2: factory(24, .regular, .title2),
      title3: factory(18.72, .regular, .title3),
      body: factory(12, .regular, .body),
      factory: factory
    )
  }()

  private static let systemFont: Factory = { size, weight, textStyle in
    if let textStyle {
      return Font.system(textStyle).weight(weight)
    }
    return Font.system(size: size, weight: weight)
  }
}

private enum FontRegistry95 {
  static func ensureRegistered() {
    _ = registration
  }

  private static let registration: Void = {
    guard
      let url = Bundle.module.url(
        forResource: "W95FA",
        withExtension: "otf"
      )
    else {
      return
    }

    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }()
}
