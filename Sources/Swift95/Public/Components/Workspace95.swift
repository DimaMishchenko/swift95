import SwiftUI

/// A Windows 95-inspired desktop workspace driven by hashable window routes.
///
/// `Workspace95` keeps logical windows alive while switching or minimizing them. In compact
/// layouts one active window fills the workspace. In wide layouts the same windows overlap and
/// can be moved and resized.
///
/// ```swift
/// Workspace95(for: App.self) { route in
///   switch route {
///   case .notes:
///     WorkspaceWindow95("Notes", icon: { Image95("notes") }) { NotesView() }
///   case .settings:
///     WorkspaceWindow95("Settings", icon: { Image95("settings") }) { SettingsView() }
///   }
/// } desktop: {
///   Desktop95 { shortcuts }
/// } taskBar: {
///   TaskBar95("Start", icon: { startIcon }, menu: { startMenu })
/// }
/// ```
public struct Workspace95<Route: Hashable, Desktop: View, TaskBar: View>: View {
  @State private var ownedState: WorkspaceState95<Route>

  private let externalState: Binding<WorkspaceState95<Route>>?
  private let presentation: WorkspacePresentation95
  private let configuration: WorkspaceConfiguration95
  private let makeWindow: (Route) -> WorkspaceWindow95
  private let desktop: Desktop
  private let taskBar: TaskBar

  /// Creates a workspace that owns transient window state.
  public init(
    for routeType: Route.Type = Route.self,
    presentation: WorkspacePresentation95 = .automatic,
    configuration: WorkspaceConfiguration95 = .default,
    _ window: @escaping (Route) -> WorkspaceWindow95,
    @ViewBuilder desktop: () -> Desktop,
    @ViewBuilder taskBar: () -> TaskBar
  ) {
    _ownedState = State(initialValue: WorkspaceState95())
    externalState = nil
    self.presentation = presentation
    self.configuration = configuration
    makeWindow = window
    self.desktop = desktop()
    self.taskBar = taskBar()
  }

  /// Creates a workspace driven by external state.
  public init(
    for routeType: Route.Type = Route.self,
    state: Binding<WorkspaceState95<Route>>,
    presentation: WorkspacePresentation95 = .automatic,
    configuration: WorkspaceConfiguration95 = .default,
    _ window: @escaping (Route) -> WorkspaceWindow95,
    @ViewBuilder desktop: () -> Desktop,
    @ViewBuilder taskBar: () -> TaskBar
  ) {
    _ownedState = State(initialValue: state.wrappedValue)
    externalState = state
    self.presentation = presentation
    self.configuration = configuration
    makeWindow = window
    self.desktop = desktop()
    self.taskBar = taskBar()
  }

  /// The desktop, logical windows, and taskbar.
  public var body: some View {
    let state = stateBinding
    let context = makeContext(state: state)
    let openAction = OpenWorkspaceWindow95Action { value in
      guard let route = value.base as? Route else { return }
      state.wrappedValue.open(route)
    }

    VStack(spacing: 0) {
      GeometryReader { geometry in
        let resolvedPresentation = presentation.resolved(
          for: geometry.size,
          configuration: configuration
        )

        ZStack(alignment: .topLeading) {
          desktop
            .frame(maxWidth: .infinity, maxHeight: .infinity)

          ForEach(state.wrappedValue.openWindows, id: \.self) { route in
            windowHost(
              route: route,
              state: state,
              workspaceSize: geometry.size,
              presentation: resolvedPresentation
            )
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
      }

      taskBar
        .environment(\.workspaceContext, context)
    }
    .environment(\.openWorkspaceWindow95, openAction)
  }

  private var stateBinding: Binding<WorkspaceState95<Route>> {
    externalState ?? $ownedState
  }

  private func makeContext(
    state: Binding<WorkspaceState95<Route>>
  ) -> WorkspaceContext {
    WorkspaceContext(
      tasks: state.wrappedValue.openWindows.map { route in
        let window = makeWindow(route)
        return WorkspaceTaskContext(
          id: AnyHashable(route),
          title: window.title,
          icon: window.taskBarIcon,
          isActive: state.wrappedValue.activeWindow == route,
          isMinimized: state.wrappedValue.minimizedWindows.contains(route)
        )
      },
      toggleTask: { value in
        guard let route = value.base as? Route else { return }
        let allowsMinimization = makeWindow(route).configuration.capabilities.contains(.minimize)
        state.wrappedValue.activateTask(route, allowsMinimization: allowsMinimization)
      }
    )
  }

  private func windowHost(
    route: Route,
    state: Binding<WorkspaceState95<Route>>,
    workspaceSize: CGSize,
    presentation: WorkspacePresentation95
  ) -> some View {
    let window = makeWindow(route)
    let isMinimized = state.wrappedValue.minimizedWindows.contains(route)
    let isActive = state.wrappedValue.activeWindow == route
    let zIndex = Double(state.wrappedValue.windowOrder.firstIndex(of: route) ?? 0)
    let fallbackFrame = initialFrame(
      for: route,
      state: state.wrappedValue,
      workspaceSize: workspaceSize
    )
    let frame = Binding(
      get: { state.wrappedValue.windowFrames[route] ?? fallbackFrame },
      set: { state.wrappedValue.setFrame($0, for: route) }
    )

    return WorkspaceWindowHost(
      window: window,
      isActive: isActive,
      presentation: presentation,
      workspaceSize: workspaceSize,
      frame: frame,
      activate: { state.wrappedValue.activate(route) },
      minimize: { state.wrappedValue.minimize(route) },
      close: { state.wrappedValue.close(route) },
      configuration: configuration
    )
    .opacity(isMinimized || (!isActive && presentation == .compact) ? 0 : 1)
    .allowsHitTesting(!isMinimized && (isActive || presentation == .windowed))
    // Hidden windows stay mounted to preserve their SwiftUI state, so they must
    // be removed from the accessibility tree separately.
    .accessibilityHidden(isMinimized || (!isActive && presentation == .compact))
    .accessibilitySortPriority(isActive ? 10_000 : zIndex)
    .zIndex(zIndex)
  }

  private func initialFrame(
    for route: Route,
    state: WorkspaceState95<Route>,
    workspaceSize: CGSize
  ) -> CGRect {
    let index = state.openWindows.firstIndex(of: route) ?? 0
    return WorkspaceInitialFrame95.frame(
      index: index,
      workspaceSize: workspaceSize,
      configuration: configuration
    )
  }
}
