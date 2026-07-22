import SwiftUI

/// Actions for the logical window containing the current content.
///
/// ```swift
/// @Environment(\.workspaceWindow95) private var window
///
/// Button95("Done") { window.close() }
/// ```
public struct WorkspaceWindowActions95 {
  private let closeHandler: () -> Void
  private let minimizeHandler: () -> Void

  init(close: @escaping () -> Void = {}, minimize: @escaping () -> Void = {}) {
    closeHandler = close
    minimizeHandler = minimize
  }

  /// Closes the current logical window.
  public func close() { closeHandler() }

  /// Minimizes the current logical window into the taskbar.
  public func minimize() { minimizeHandler() }
}

extension EnvironmentValues {
  /// Actions targeting the logical workspace window containing the current view.
  @Entry public var workspaceWindow95 = WorkspaceWindowActions95()
}
