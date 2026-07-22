import SwiftUI

/// A button that opens or focuses a route in the enclosing ``Workspace95``.
///
/// Use workspace links in a ``StartMenu95`` or anywhere else inside the workspace hierarchy:
///
/// ```swift
/// WorkspaceLink95("Settings", value: App.settings)
///   .swiftUI { button in
///     button.keyboardShortcut(",", modifiers: .command)
///   }
/// ```
public struct WorkspaceLink95<Route: Hashable, Label: View>: View {
  @Environment(\.dismissStartMenu) private var dismissStartMenu
  @Environment(\.openWorkspaceWindow95) private var openWindow

  private let value: Route
  private let label: Label
  private let controlTransform: (AnyView) -> AnyView

  /// Creates a workspace link with a custom label.
  public init(value: Route, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
    controlTransform = { $0 }
  }

  private init(
    value: Route,
    label: Label,
    controlTransform: @escaping (AnyView) -> AnyView
  ) {
    self.value = value
    self.label = label
    self.controlTransform = controlTransform
  }

  /// The launch button.
  public var body: some View {
    controlTransform(
      AnyView(
        Button {
          openWindow(value)
          dismissStartMenu()
        } label: {
          label
            .contentShape(.rect)
        }
      )
    )
  }

  /// Applies a transformation to the embedded SwiftUI button.
  ///
  /// Use this method for native button APIs, such as keyboard shortcuts or context menus, that
  /// Swift95 doesn't expose directly.
  public func swiftUI<ModifiedControl: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedControl
  ) -> WorkspaceLink95<Route, Label> {
    WorkspaceLink95<Route, Label>(
      value: value,
      label: label,
      controlTransform: { control in
        AnyView(transform(self.controlTransform(control)))
      }
    )
  }
}

extension WorkspaceLink95 where Label == Text {
  /// Creates a workspace link with a localized text label.
  public init(_ titleKey: LocalizedStringKey, value: Route) {
    self.init(value: value) { Text(titleKey) }
  }

  /// Creates a workspace link with an unlocalized text label.
  public init<S: StringProtocol>(_ title: S, value: Route) {
    self.init(value: value) { Text(verbatim: String(title)) }
  }
}
