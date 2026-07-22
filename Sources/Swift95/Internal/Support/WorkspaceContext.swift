import SwiftUI

struct WorkspaceTaskContext: Identifiable {
  let id: AnyHashable
  let title: Text
  let icon: AnyView
  let isActive: Bool
  let isMinimized: Bool
}

struct WorkspaceContext {
  var tasks: [WorkspaceTaskContext] = []
  var toggleTask: (AnyHashable) -> Void = { _ in }
}

extension EnvironmentValues {
  @Entry var workspaceContext = WorkspaceContext()
  @Entry var dismissStartMenu: () -> Void = {}
}
