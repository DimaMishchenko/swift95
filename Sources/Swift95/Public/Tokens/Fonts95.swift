import CoreText
import SwiftUI

/// The typography roles and font factory used by a Swift95 theme.
///
/// Components use the semantic ``title``, ``title2``, ``title3``, and ``body``
/// roles. Applications can supply any SwiftUI `Font` for those roles and can
/// optionally provide a ``Factory`` to retain the same family at arbitrary
/// sizes.
///
/// ```swift
/// let fonts = Fonts95(
///   title: .system(.title),
///   title2: .system(.title2),
///   title3: .system(.title3),
///   body: .system(.body)
/// )
/// ```
public struct Fonts95: Sendable {
  /// A function that creates a themed font at a requested size and weight.
  ///
  /// The third argument is the Dynamic Type text style to scale relative to.
  /// A `nil` text style requests a fixed-size font.
  public typealias Factory = @Sendable (CGFloat, Font.Weight, Font.TextStyle?) -> Font

  /// The primary title font.
  public var title: Font
  /// The secondary title font.
  public var title2: Font
  /// The tertiary title font.
  public var title3: Font
  /// The default interface font.
  public var body: Font

  private let factory: Factory

  /// Creates a font set from concrete SwiftUI fonts.
  ///
  /// Arbitrary fonts requested through ``font(size:weight:)`` or
  /// ``font(size:weight:relativeTo:)`` use the system font. Use
  /// ``init(title:title2:title3:body:factory:)`` to preserve a custom family for
  /// arbitrary sizes.
  ///
  /// - Parameters:
  ///   - title: The primary title font.
  ///   - title2: The secondary title font.
  ///   - title3: The tertiary title font.
  ///   - body: The default interface font.
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

  /// Creates a font set with a factory for arbitrary sizes.
  ///
  /// - Parameters:
  ///   - title: The primary title font.
  ///   - title2: The secondary title font.
  ///   - title3: The tertiary title font.
  ///   - body: The default interface font.
  ///   - factory: A closure that creates additional fonts in the theme's family.
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
  ///
  /// A fixed-size font does not scale with Dynamic Type. Prefer
  /// ``font(size:weight:relativeTo:)`` for user-facing text.
  ///
  /// ```swift
  /// Text("12 pt")
  ///   .font(theme.fonts.font(size: 12))
  /// ```
  ///
  /// - Parameters:
  ///   - size: The font size in points.
  ///   - weight: The requested font weight.
  /// - Returns: A fixed-size font created by this set's factory.
  public func font(
    size: CGFloat,
    weight: Font.Weight = .regular
  ) -> Font {
    factory(size, weight, nil)
  }

  /// Creates a Dynamic Type-aware font using this theme's font family.
  ///
  /// ```swift
  /// Text("Custom body text")
  ///   .font(theme.fonts.font(size: 18, relativeTo: .body))
  /// ```
  ///
  /// - Parameters:
  ///   - size: The font's base size in points.
  ///   - weight: The requested font weight.
  ///   - textStyle: The SwiftUI text style that controls Dynamic Type scaling.
  /// - Returns: A scalable font created by this set's factory.
  public func font(
    size: CGFloat,
    weight: Font.Weight = .regular,
    relativeTo textStyle: Font.TextStyle
  ) -> Font {
    factory(size, weight, textStyle)
  }

  /// The default Windows 95-inspired type ramp.
  ///
  /// The bundled W95FA font is registered lazily when one of these fonts is
  /// first resolved. All semantic roles scale with Dynamic Type.
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
      title: factory(28, .regular, .title),
      title2: factory(22, .regular, .title2),
      title3: factory(20, .regular, .title3),
      body: factory(17, .regular, .body),
      factory: factory
    )
  }()

  private static let systemFont: Factory = { size, weight, textStyle in
    if let textStyle, let systemFont = CTFontCreateUIFontForLanguage(.system, size, nil) {
      return
        Font.custom(
          CTFontCopyFamilyName(systemFont) as String,
          size: size,
          relativeTo: textStyle
        )
        .weight(weight)
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
