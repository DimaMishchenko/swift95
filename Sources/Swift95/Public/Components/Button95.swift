import SwiftUI

/// A button with the raised, pressed, and disabled appearance of Swift95.
///
/// `Button95` preserves the action, role, enabled state, and accessibility behavior of SwiftUI's
/// `Button`. It applies the active theme's body font and colors, draws a raised bevel, and briefly
/// retains the sunken pressed appearance so quick taps remain visible.
///
/// Create a text button with the concise initializer:
///
/// ```swift
/// Button95("Save") {
///   saveDocument()
/// }
/// ```
///
/// Custom labels and native button configuration remain available:
///
/// ```swift
/// Button95(role: .destructive, action: deleteDocument) {
///   Label("Delete", systemImage: "trash")
/// }
/// .swiftUI { button in
///   button.keyboardShortcut("d", modifiers: .command)
/// }
/// ```
public struct Button95<Label: View, Control: View>: View {
  @Environment(\.theme95) private var theme

  private let control: Control
  private let contentInsets: EdgeInsets?

  /// Creates a button with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - role: The optional semantic role of the button.
  ///   - action: The action to perform when the user activates the button.
  ///   - label: The content displayed inside the button.
  public init(
    role: ButtonRole? = nil,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
  ) where Control == Button<Label> {
    control = Button(role: role, action: action, label: label)
    contentInsets = nil
  }

  init(
    action: @escaping () -> Void,
    contentInsets: EdgeInsets,
    @ViewBuilder label: () -> Label
  ) where Control == Button<Label> {
    control = Button(action: action, label: label)
    self.contentInsets = contentInsets
  }

  private init(control: Control, contentInsets: EdgeInsets?) {
    self.control = control
    self.contentInsets = contentInsets
  }

  /// The styled button control.
  public var body: some View {
    control.buttonStyle(
      ButtonStyle95(
        theme: theme,
        contentInsets: contentInsets ?? .button95(theme.spacing)
      )
    )
  }

  /// Applies a transformation to the embedded SwiftUI button.
  ///
  /// Use this method for native button APIs that Swift95 doesn't expose directly. The transformed
  /// control continues to receive the Swift95 button style.
  ///
  /// - Parameter transform: A closure that receives the embedded control.
  /// - Returns: A button containing the transformed SwiftUI control.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: (Control) -> ModifiedControl
  ) -> Button95<Label, ModifiedControl> {
    Button95<Label, ModifiedControl>(
      control: transform(control),
      contentInsets: contentInsets
    )
  }
}

extension Button95 where Label == Text, Control == Button<Text> {
  /// Creates a button with a localized text label.
  ///
  /// - Parameters:
  ///   - titleKey: The localization key used for the label.
  ///   - role: The optional semantic role of the button.
  ///   - action: The action to perform when the user activates the button.
  public init(
    _ titleKey: LocalizedStringKey,
    role: ButtonRole? = nil,
    action: @escaping () -> Void
  ) {
    control = Button(titleKey, role: role, action: action)
    contentInsets = nil
  }

  /// Creates a button with an unlocalized text label.
  ///
  /// - Parameters:
  ///   - title: The text displayed by the button.
  ///   - role: The optional semantic role of the button.
  ///   - action: The action to perform when the user activates the button.
  public init<S>(
    _ title: S,
    role: ButtonRole? = nil,
    action: @escaping () -> Void
  ) where S: StringProtocol {
    control = Button(role: role, action: action) {
      Text(verbatim: String(title))
    }
    contentInsets = nil
  }
}

struct ButtonStyle95: ButtonStyle {
  let theme: Theme95
  let contentInsets: EdgeInsets
  var forcedPressed: Bool?

  init(
    theme: Theme95,
    contentInsets: EdgeInsets,
    forcedPressed: Bool? = nil
  ) {
    self.theme = theme
    self.contentInsets = contentInsets
    self.forcedPressed = forcedPressed
  }

  func makeBody(configuration: Configuration) -> some View {
    ButtonStyleContent95(
      configuration: configuration,
      theme: theme,
      contentInsets: contentInsets,
      forcedPressed: forcedPressed
    )
  }
}

private struct ButtonStyleContent95: View {
  @Environment(\.isEnabled) private var isEnabled
  @State private var isVisuallyPressed = false
  @State private var releaseTask: Task<Void, Never>?

  let configuration: ButtonStyle95.Configuration
  let theme: Theme95
  let contentInsets: EdgeInsets
  let forcedPressed: Bool?

  var body: some View {
    let isPressed = forcedPressed ?? isVisuallyPressed

    configuration.label
      .font(theme.fonts.body)
      .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
      .padding(contentInsets)
      .contentShape(.rect)
      .offset(
        x: isPressed ? theme.metrics.pressedContentOffset : 0,
        y: isPressed ? theme.metrics.pressedContentOffset : 0
      )
      .bevel95(isPressed ? .sunken : .raised)
      .onChange(of: configuration.isPressed, initial: true, updateVisualPressState)
      .onDisappear {
        releaseTask?.cancel()
      }
  }

  private func updateVisualPressState(_ oldValue: Bool, _ isPressed: Bool) {
    releaseTask?.cancel()

    if isPressed {
      isVisuallyPressed = true
      return
    }

    guard oldValue || isVisuallyPressed else {
      return
    }

    releaseTask = Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(80))
      guard !Task.isCancelled else {
        return
      }
      isVisuallyPressed = false
    }
  }
}

private extension EdgeInsets {
  static func button95(_ spacing: Spacing95) -> EdgeInsets {
    EdgeInsets(
      top: spacing.s,
      leading: spacing.xl,
      bottom: spacing.s,
      trailing: spacing.xl
    )
  }
}
