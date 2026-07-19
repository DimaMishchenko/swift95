import SwiftUI

/// A secure text field with a sunken Swift95 input surface.
///
/// `SecureField95` preserves SwiftUI's secure text entry and binding behavior while applying the
/// active theme's typography, input colors, disabled state, and sunken bevel.
///
/// ```swift
/// @State private var password = ""
///
/// SecureField95("Password", text: $password)
///   .swiftUI { field in
///     field
///       .textContentType(.password)
///       .submitLabel(.done)
///   }
/// ```
public struct SecureField95<Field: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme

  private let field: Field

  /// Creates a secure field with a localized prompt.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key displayed while the field is empty.
  ///   - text: The private editable text value.
  public init(_ titleKey: LocalizedStringKey, text: Binding<String>)
  where Field == SecureField<Text> {
    field = SecureField(titleKey, text: text)
  }

  /// Creates a secure field with an unlocalized prompt.
  ///
  /// - Parameters:
  ///   - title: The text displayed while the field is empty.
  ///   - text: The private editable text value.
  public init<S>(_ title: S, text: Binding<String>)
  where Field == SecureField<Text>, S: StringProtocol {
    field = SecureField(String(title), text: text)
  }

  /// Creates a secure field with separate localized labeling and prompt content.
  ///
  /// - Parameters:
  ///   - titleKey: The localized accessibility label for the field.
  ///   - text: The private editable text value.
  ///   - prompt: The content displayed while the field is empty.
  public init(
    _ titleKey: LocalizedStringKey,
    text: Binding<String>,
    prompt: Text?
  ) where Field == SecureField<Text> {
    field = SecureField(titleKey, text: text, prompt: prompt)
  }

  /// Creates a secure field with separate unlocalized labeling and prompt content.
  ///
  /// - Parameters:
  ///   - title: The unlocalized accessibility label for the field.
  ///   - text: The private editable text value.
  ///   - prompt: The content displayed while the field is empty.
  public init<S>(
    _ title: S,
    text: Binding<String>,
    prompt: Text?
  ) where Field == SecureField<Text>, S: StringProtocol {
    field = SecureField(String(title), text: text, prompt: prompt)
  }

  private init(field: Field) {
    self.field = field
  }

  /// The styled secure field.
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

  /// Applies a transformation to the embedded SwiftUI secure field.
  ///
  /// Use this method to configure native secure-input behavior before Swift95 applies its style.
  ///
  /// - Parameter transform: A closure that receives the embedded secure field.
  /// - Returns: A secure field containing the transformed SwiftUI control.
  public func swiftUI<ModifiedField: View>(
    @ViewBuilder _ transform: (Field) -> ModifiedField
  ) -> SecureField95<ModifiedField> {
    SecureField95<ModifiedField>(field: transform(field))
  }
}
