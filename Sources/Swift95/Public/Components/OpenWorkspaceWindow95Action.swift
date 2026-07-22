import SwiftUI

/// Opens or focuses a logical window in the enclosing ``Workspace95``.
///
/// ```swift
/// @Environment(\.openWorkspaceWindow95) private var openWindow
///
/// Button95("Open Notes") { openWindow(App.notes) }
/// ```
public struct OpenWorkspaceWindow95Action {
  private let handler: (AnyHashable) -> Void

  init(handler: @escaping (AnyHashable) -> Void = { _ in }) {
    self.handler = handler
  }

  /// Opens the window represented by `value`, or focuses it when it is already open.
  public func callAsFunction<Route: Hashable>(_ value: Route) {
    handler(AnyHashable(value))
  }
}

extension EnvironmentValues {
  /// An action that opens or focuses a route in the nearest workspace.
  @Entry public var openWorkspaceWindow95 = OpenWorkspaceWindow95Action()
}
