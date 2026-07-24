import SwiftUI

/// A radio button that selects one value from a bound selection.
///
/// Radio buttons that share the same binding form a mutually exclusive group.
/// Selecting one button writes its value to the binding. The control uses a
/// pixel-style circular indicator and exposes selected-state accessibility.
///
/// ```swift
/// @State private var mode = Mode.automatic
///
/// RadioButton95("Automatic", value: .automatic, selection: $mode)
/// RadioButton95("Manual", value: .manual, selection: $mode)
/// ```
public struct RadioButton95<Value: Hashable, Label: View, Control: View>: View {
  @Environment(\.theme95) private var theme
  @Binding private var selection: Value

  private let value: Value
  private let control: Control

  /// Creates a radio button with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - value: The value represented by this radio button.
  ///   - selection: The currently selected value in the group.
  ///   - label: The content displayed beside the radio indicator.
  public init(
    value: Value,
    selection: Binding<Value>,
    @ViewBuilder label: () -> Label
  ) where Control == Button<Label> {
    self.value = value
    _selection = selection
    control = Button {
      selection.wrappedValue = value
    } label: {
      label()
    }
  }

  private init(
    value: Value,
    selection: Binding<Value>,
    control: Control
  ) {
    self.value = value
    _selection = selection
    self.control = control
  }

  /// The styled radio button control.
  public var body: some View {
    control
      .buttonStyle(
        RadioButtonStyle95(
          isSelected: selection == value,
          theme: theme
        )
      )
      .accessibilityAddTraits(selection == value ? .isSelected : [])
      .minimumInteractionTarget95()
  }

  /// Applies a transformation to the embedded SwiftUI button.
  ///
  /// The transformed button keeps its selection action and Swift95 radio style.
  ///
  /// - Parameter transform: A closure that receives the embedded button.
  /// - Returns: A radio button containing the transformed SwiftUI control.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: (Control) -> ModifiedControl
  ) -> RadioButton95<Value, Label, ModifiedControl> {
    RadioButton95<Value, Label, ModifiedControl>(
      value: value,
      selection: $selection,
      control: transform(control)
    )
  }
}

extension RadioButton95 where Label == Text, Control == Button<Text> {
  /// Creates a radio button with a localized text label.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key used for the label.
  ///   - value: The value represented by this radio button.
  ///   - selection: The currently selected value in the group.
  public init(
    _ titleKey: LocalizedStringKey,
    value: Value,
    selection: Binding<Value>
  ) {
    self.value = value
    _selection = selection
    control = Button(titleKey) {
      selection.wrappedValue = value
    }
  }

  /// Creates a radio button with an unlocalized text label.
  ///
  /// - Parameters:
  ///   - title: The text displayed beside the radio indicator.
  ///   - value: The value represented by this radio button.
  ///   - selection: The currently selected value in the group.
  public init<S>(
    _ title: S,
    value: Value,
    selection: Binding<Value>
  ) where S: StringProtocol {
    self.value = value
    _selection = selection
    control = Button {
      selection.wrappedValue = value
    } label: {
      Text(verbatim: String(title))
    }
  }
}

private struct RadioButtonStyle95: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  let isSelected: Bool
  let theme: Theme95

  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: theme.spacing.s) {
      RadioIndicatorDrawing95(
        isSelected: isSelected,
        isEnabled: isEnabled,
        colors: theme.colors
      )
      .frame(
        width: theme.metrics.radioButtonSize,
        height: theme.metrics.radioButtonSize
      )

      configuration.label
    }
    .font(theme.fonts.body)
    .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
    .contentShape(.rect)
  }
}
