import SwiftUI

/// An optional classic desktop surface for a ``Workspace95`` or ``Desktop95``.
///
/// Use this convenience view when you want the theme's classic workspace color. It is not required; ``Desktop95`` also accepts any custom SwiftUI background:
///
/// ```swift
/// ZStack {
///   ClassicWorkspaceBackground95()
///   desktopContent
/// }
/// ```
public struct ClassicWorkspaceBackground95: View {
  @Environment(\.theme95) private var theme

  /// Creates a workspace background using ``Colors95/workspaceBackground``.
  public init() {}

  /// The workspace background surface.
  public var body: some View {
    theme.colors.workspaceBackground
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
