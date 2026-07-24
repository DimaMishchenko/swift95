import SwiftUI

/// A checkbox backed by SwiftUI's native `Toggle` behavior.
///
/// `Checkbox95` uses a pixel checkmark, an input-style indicator, and the active
/// theme's body typography. It preserves the binding, enabled state, keyboard
/// behavior, and accessibility semantics of the embedded `Toggle`.
///
/// ```swift
/// @State private var isEnabled = true
///
/// Checkbox95("Enable sound", isOn: $isEnabled)
///   .swiftUI { toggle in
///     toggle.accessibilityHint("Controls interface sounds")
///   }
/// ```
public struct Checkbox95<Label: View, Control: View>: View {
  @Environment(\.theme95) private var theme

  private let control: Control

  /// Creates a checkbox with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - isOn: A binding that determines whether the checkbox is checked.
  ///   - label: The content displayed beside the checkbox indicator.
  public init(
    isOn: Binding<Bool>,
    @ViewBuilder label: () -> Label
  ) where Control == Toggle<Label> {
    control = Toggle(isOn: isOn, label: label)
  }

  private init(control: Control) {
    self.control = control
  }

  /// The styled checkbox control.
  public var body: some View {
    control
      .toggleStyle(CheckboxToggleStyle95(theme: theme))
      .minimumInteractionTarget95()
  }

  /// Applies a transformation to the embedded SwiftUI toggle.
  ///
  /// Use this method for native toggle APIs that Swift95 doesn't expose
  /// directly. The transformed control continues to receive the checkbox style.
  ///
  /// - Parameter transform: A closure that receives the embedded toggle.
  /// - Returns: A checkbox containing the transformed SwiftUI control.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: (Control) -> ModifiedControl
  ) -> Checkbox95<Label, ModifiedControl> {
    Checkbox95<Label, ModifiedControl>(control: transform(control))
  }
}

extension Checkbox95 where Label == Text, Control == Toggle<Text> {
  /// Creates a checkbox with a localized text label.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key used for the label.
  ///   - isOn: A binding that determines whether the checkbox is checked.
  public init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
    control = Toggle(titleKey, isOn: isOn)
  }

  /// Creates a checkbox with an unlocalized text label.
  ///
  /// - Parameters:
  ///   - title: The text displayed beside the checkbox indicator.
  ///   - isOn: A binding that determines whether the checkbox is checked.
  public init<S>(_ title: S, isOn: Binding<Bool>) where S: StringProtocol {
    control = Toggle(isOn: isOn) {
      Text(verbatim: String(title))
    }
  }
}

private struct CheckboxToggleStyle95: ToggleStyle {
  @Environment(\.isEnabled) private var isEnabled

  let theme: Theme95

  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      HStack(spacing: theme.spacing.s) {
        CheckboxIndicator95(
          isChecked: configuration.isOn,
          isEnabled: isEnabled,
          theme: theme
        )

        configuration.label
      }
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .font(theme.fonts.body)
    .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
  }
}

private struct CheckboxIndicator95: View {
  let isChecked: Bool
  let isEnabled: Bool
  let theme: Theme95

  var body: some View {
    Color.clear
      .frame(
        width: theme.metrics.checkboxSize,
        height: theme.metrics.checkboxSize
      )
      .bevel95(
        .input,
        background: isEnabled
          ? theme.colors.inputBackground
          : theme.colors.inputBackgroundDisabled
      )
      .overlay {
        if isChecked {
          CheckmarkDrawing95(
            color: isEnabled ? theme.colors.text : theme.colors.textDisabled,
            size: theme.metrics.checkboxSize * 7 / 12
          )
        }
      }
      .accessibilityHidden(true)
  }
}
