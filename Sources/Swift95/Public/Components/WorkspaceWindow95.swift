import SwiftUI

/// A logical top-level window created by a ``Workspace95`` route.
///
/// The workspace owns the window's runtime identity and presentation. This value supplies the
/// title, icons, and SwiftUI content for that route.
///
/// ```swift
/// WorkspaceWindow95(
///   "Notes",
///   titleBarIcon: { Image95("notes-small") },
///   taskBarIcon: { Image95("notes") }
/// ) {
///   NotesView()
/// }
/// .statusBar95 { Text95("Ready") }
/// ```
public struct WorkspaceWindow95 {
  let title: Text
  let titleBarIcon: AnyView
  let taskBarIcon: AnyView
  var menus: [Menu95]
  var statusBar: AnyView?
  var resizeControl: WorkspaceWindowResizeControl95
  var configuration: WorkspaceWindowConfiguration95
  let makeContent: () -> AnyView

  /// Creates a window with a localized title and one icon for both surfaces.
  public init<Icon: View, Content: View>(
    _ titleKey: LocalizedStringKey,
    @ViewBuilder icon: () -> Icon,
    @ViewBuilder content: @escaping () -> Content
  ) {
    title = Text(titleKey)
    let icon = AnyView(icon())
    titleBarIcon = icon
    taskBarIcon = icon
    menus = []
    statusBar = nil
    resizeControl = .automatic
    configuration = .default
    makeContent = { AnyView(content()) }
  }

  /// Creates a window with an unlocalized title and one icon for both surfaces.
  public init<S: StringProtocol, Icon: View, Content: View>(
    _ title: S,
    @ViewBuilder icon: () -> Icon,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = Text(verbatim: String(title))
    let icon = AnyView(icon())
    titleBarIcon = icon
    taskBarIcon = icon
    menus = []
    statusBar = nil
    resizeControl = .automatic
    configuration = .default
    makeContent = { AnyView(content()) }
  }

  /// Creates a window with separate title-bar and taskbar icons.
  public init<TitleBarIcon: View, TaskBarIcon: View, Content: View>(
    _ titleKey: LocalizedStringKey,
    @ViewBuilder titleBarIcon: () -> TitleBarIcon,
    @ViewBuilder taskBarIcon: () -> TaskBarIcon,
    @ViewBuilder content: @escaping () -> Content
  ) {
    title = Text(titleKey)
    self.titleBarIcon = AnyView(titleBarIcon())
    self.taskBarIcon = AnyView(taskBarIcon())
    menus = []
    statusBar = nil
    resizeControl = .automatic
    configuration = .default
    makeContent = { AnyView(content()) }
  }

  /// Creates a window with an unlocalized title and separate title-bar and taskbar icons.
  public init<S: StringProtocol, TitleBarIcon: View, TaskBarIcon: View, Content: View>(
    _ title: S,
    @ViewBuilder titleBarIcon: () -> TitleBarIcon,
    @ViewBuilder taskBarIcon: () -> TaskBarIcon,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = Text(verbatim: String(title))
    self.titleBarIcon = AnyView(titleBarIcon())
    self.taskBarIcon = AnyView(taskBarIcon())
    menus = []
    statusBar = nil
    resizeControl = .automatic
    configuration = .default
    makeContent = { AnyView(content()) }
  }

  /// Adds an optional classic pull-down menu bar below the window title.
  ///
  /// ```swift
  /// WorkspaceWindow95("Notepad", icon: { noteIcon }) {
  ///   Editor()
  /// }
  /// .menuBar95 {
  ///   Menu95("File") {
  ///     MenuItem95("New", action: newDocument)
  ///     MenuDivider95()
  ///     MenuItem95("Close", action: closeDocument)
  ///   }
  /// }
  /// ```
  public func menuBar95(
    @MenuBuilder95 content: () -> [Menu95]
  ) -> WorkspaceWindow95 {
    var copy = self
    copy.menus = content()
    return copy
  }

  /// Adds application status content to the classic bar at the bottom of the window.
  public func statusBar95<Content: View>(
    @ViewBuilder content: () -> Content
  ) -> WorkspaceWindow95 {
    var copy = self
    copy.statusBar = AnyView(content())
    return copy
  }

  /// Configures the window's visible resize affordance.
  public func resizeControl95(
    _ control: WorkspaceWindowResizeControl95
  ) -> WorkspaceWindow95 {
    var copy = self
    copy.resizeControl = control
    return copy
  }

  /// Configures this window's minimum size and available operations.
  public func windowConfiguration95(
    _ configuration: WorkspaceWindowConfiguration95
  ) -> WorkspaceWindow95 {
    var copy = self
    copy.configuration = configuration
    return copy
  }
}
