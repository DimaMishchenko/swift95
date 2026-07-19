import SwiftUI

/// A single-line text field with a sunken Swift95 input surface.
///
/// The field uses the active theme's body font, input colors, disabled appearance, and sunken
/// bevel while retaining the binding and editing behavior of SwiftUI's `TextField`.
///
/// ```swift
/// @State private var name = ""
///
/// TextField95("Name", text: $name)
///   .swiftUI { field in
///     field
///       .textContentType(.name)
///       .textInputAutocapitalization(.words)
///   }
/// ```
public struct TextField95<Field: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme

  private let field: Field

  /// Creates a text field with a localized prompt.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key displayed while the field is empty.
  ///   - text: The editable text value.
  public init(_ titleKey: LocalizedStringKey, text: Binding<String>)
  where Field == TextField<Text> {
    field = TextField(titleKey, text: text)
  }

  /// Creates a text field with an unlocalized prompt.
  ///
  /// - Parameters:
  ///   - title: The text displayed while the field is empty.
  ///   - text: The editable text value.
  public init<S>(_ title: S, text: Binding<String>)
  where Field == TextField<Text>, S: StringProtocol {
    field = TextField(String(title), text: text)
  }

  private init(field: Field) {
    self.field = field
  }

  /// The styled text field.
  public var body: some View {
    field
      .textFieldStyle(.plain)
      .font(theme.fonts.body)
      .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
      .padding(.horizontal, Spacing95[6])
      .padding(.vertical, Spacing95[5])
      .bevel95(
        .input,
        background: isEnabled ? theme.colors.inputBackground : theme.colors.inputBackgroundDisabled
      )
  }

  /// Applies a transformation to the embedded SwiftUI text field.
  ///
  /// Use this method to configure native input behavior such as content type, capitalization,
  /// submission, and keyboard settings.
  ///
  /// - Parameter transform: A closure that receives the embedded text field.
  /// - Returns: A text field containing the transformed SwiftUI control.
  public func swiftUI<ModifiedField: View>(
    @ViewBuilder _ transform: (Field) -> ModifiedField
  ) -> TextField95<ModifiedField> {
    TextField95<ModifiedField>(field: transform(field))
  }
}
