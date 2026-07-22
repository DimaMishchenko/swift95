import CoreGraphics

/// The presentation used for windows inside a ``Workspace95``.
///
/// ```swift
/// Workspace95(for: App.self, presentation: .windowed, makeWindow) {
///   Desktop95 { shortcuts }
/// } taskBar: {
///   taskBar
/// }
/// ```
public enum WorkspacePresentation95: Sendable, Equatable {
  /// Uses compact presentation in narrow spaces and overlapping windows in wide spaces.
  case automatic
  /// Displays one retained, full-workspace window at a time.
  case compact
  /// Displays movable and resizable overlapping windows.
  case windowed

  func resolved(for workspaceSize: CGSize) -> WorkspacePresentation95 {
    switch self {
    case .automatic:
      workspaceSize.width >= 600 && workspaceSize.height >= 480 ? .windowed : .compact
    case .compact, .windowed:
      self
    }
  }
}
