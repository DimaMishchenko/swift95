import SwiftUI

/// Text that uses the active Swift95 theme by default.
///
/// `Text95` applies the theme's body font and semantic text color. A disabled view hierarchy
/// automatically uses the theme's disabled text color.
///
/// ```swift
/// Text95("Ready")
///
/// Text95("Unavailable")
///   .disabled(true)
/// ```
///
/// Use ``swiftUI(_:)`` when a native `Text` operation is needed before Swift95 applies its defaults:
///
/// ```swift
/// Text95("Spaced")
///   .swiftUI { text in
///     text.kerning(1)
///   }
/// ```
public struct Text95<Content: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme

  private let content: Content

  /// Creates localized text from a localization key.
  ///
  /// - Parameter key: The key used to look up localized content.
  public init(_ key: LocalizedStringKey) where Content == Text {
    content = Text(key)
  }

  /// Creates unlocalized text from a string value.
  ///
  /// - Parameter content: The text to display verbatim.
  public init<S>(_ content: S) where Content == Text, S: StringProtocol {
    self.content = Text(verbatim: String(content))
  }

  /// Creates text from styled attributed content.
  ///
  /// - Parameter attributedContent: The attributed content to display.
  public init(_ attributedContent: AttributedString) where Content == Text {
    content = Text(attributedContent)
  }

  private init(content: Content) {
    self.content = content
  }

  /// The styled text content.
  public var body: some View {
    content
      .font(theme.fonts.body)
      .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
  }

  /// Applies a transformation to the embedded SwiftUI text.
  ///
  /// Use this escape hatch for APIs that are specific to SwiftUI's `Text`.
  ///
  /// - Parameter transform: A closure that receives the embedded text.
  /// - Returns: Text containing the transformed SwiftUI content.
  public func swiftUI<ModifiedContent: View>(
    @ViewBuilder _ transform: (Content) -> ModifiedContent
  ) -> Text95<ModifiedContent> {
    Text95<ModifiedContent>(content: transform(content))
  }
}
