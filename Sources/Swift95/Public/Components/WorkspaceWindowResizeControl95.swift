/// The visible resize control used by a ``WorkspaceWindow95``.
///
/// ```swift
/// WorkspaceWindow95("About", icon: { icon }) { AboutView() }
///   .resizeControl95(.hidden)
/// ```
public enum WorkspaceWindowResizeControl95: Sendable {
  /// Uses a status-bar resize grip in windowed presentation and hides it in compact presentation.
  case automatic
  /// Reserves a classic status bar at the bottom of the window and includes a resize grip when
  /// the workspace supports resizing.
  case statusBar
  /// Hides the resize grip and disables interactive resizing.
  case hidden
}
