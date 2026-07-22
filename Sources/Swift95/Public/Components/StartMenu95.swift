import SwiftUI

/// A Start menu surface intended for use from ``TaskBar95``.
///
/// Fill the menu with ``WorkspaceLink95`` values or custom commands:
///
/// ```swift
/// StartMenu95 {
///   WorkspaceLink95("Notes", value: App.notes)
///   WorkspaceLink95("Settings", value: App.settings)
/// }
/// ```
public struct StartMenu95<Content: View>: View {
  @Environment(\.theme95) private var theme

  private let content: Content

  /// Creates a Start menu with arbitrary commands and workspace links.
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  /// The raised menu panel.
  public var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[2]) {
      content
    }
    .font(theme.fonts.body)
    .foregroundStyle(theme.colors.text)
    .padding(Spacing95[4])
    .frame(width: 280, alignment: .leading)
    .background(theme.colors.background)
    .bevel95(.raised)
    .buttonStyle(StartMenuButtonStyle(theme: theme))
  }
}

private struct StartMenuButtonStyle: ButtonStyle {
  let theme: Theme95

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(theme.fonts.body)
      .foregroundStyle(configuration.isPressed ? theme.colors.accentText : theme.colors.text)
      .padding(.horizontal, Spacing95[8])
      .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
      .background(configuration.isPressed ? theme.colors.accent : Color.clear)
      .contentShape(.rect)
  }
}
