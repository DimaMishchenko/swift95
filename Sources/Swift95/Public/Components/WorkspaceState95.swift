import CoreGraphics

/// Persistent task and window state for a ``Workspace95``.
///
/// Supply initial routes to launch with windows already open, or keep the value in app state to
/// observe and restore the user's workspace:
///
/// ```swift
/// @State private var workspace = WorkspaceState95(
///   openWindows: [App.notes],
///   activeWindow: App.notes
/// )
/// ```
public struct WorkspaceState95<Route: Hashable>: Equatable {
  /// Routes in taskbar launch order.
  public private(set) var openWindows: [Route]
  /// Routes ordered from backmost to frontmost.
  public private(set) var windowOrder: [Route]
  /// The window that currently receives workspace input.
  public private(set) var activeWindow: Route?
  /// Windows retained as tasks but hidden from the workspace.
  public private(set) var minimizedWindows: Set<Route>
  /// Window geometry used by windowed presentation.
  public private(set) var windowFrames: [Route: CGRect]

  /// Creates normalized workspace state.
  public init(
    openWindows: [Route] = [],
    windowOrder: [Route] = [],
    activeWindow: Route? = nil,
    minimizedWindows: Set<Route> = [],
    windowFrames: [Route: CGRect] = [:]
  ) {
    var seenOpen = Set<Route>()
    let normalizedOpenWindows = openWindows.filter { seenOpen.insert($0).inserted }
    let openWindowSet = Set(normalizedOpenWindows)

    var seenOrder = Set<Route>()
    var normalizedWindowOrder = windowOrder.filter {
      openWindowSet.contains($0) && seenOrder.insert($0).inserted
    }
    normalizedWindowOrder.append(
      contentsOf: normalizedOpenWindows.filter { seenOrder.insert($0).inserted }
    )

    let normalizedMinimizedWindows = minimizedWindows.intersection(openWindowSet)
    let requestedActiveWindow = activeWindow.flatMap { route in
      openWindowSet.contains(route) && !normalizedMinimizedWindows.contains(route) ? route : nil
    }
    let normalizedActiveWindow =
      requestedActiveWindow
      ?? normalizedWindowOrder.last { !normalizedMinimizedWindows.contains($0) }

    if let normalizedActiveWindow {
      normalizedWindowOrder.removeAll { $0 == normalizedActiveWindow }
      normalizedWindowOrder.append(normalizedActiveWindow)
    }

    self.openWindows = normalizedOpenWindows
    self.windowOrder = normalizedWindowOrder
    self.activeWindow = normalizedActiveWindow
    self.minimizedWindows = normalizedMinimizedWindows
    self.windowFrames = windowFrames.filter { openWindowSet.contains($0.key) }
  }

  /// Opens and activates a route, preserving its existing task when already open.
  public mutating func open(_ route: Route) {
    if !openWindows.contains(route) { openWindows.append(route) }
    minimizedWindows.remove(route)
    activate(route)
  }

  /// Restores and activates an open route.
  public mutating func activate(_ route: Route) {
    guard openWindows.contains(route) else { return }
    minimizedWindows.remove(route)
    windowOrder.removeAll { $0 == route }
    windowOrder.append(route)
    activeWindow = route
  }

  /// Minimizes the active route or restores and activates an inactive route.
  public mutating func toggleTask(_ route: Route) {
    if activeWindow == route && !minimizedWindows.contains(route) {
      minimize(route)
    } else {
      activate(route)
    }
  }

  /// Minimizes an open route and activates the next frontmost visible window when needed.
  public mutating func minimize(_ route: Route) {
    guard openWindows.contains(route) else { return }
    minimizedWindows.insert(route)
    if activeWindow == route { activeWindow = frontmostVisibleWindow(excluding: route) }
  }

  /// Closes a route and removes its retained window geometry.
  public mutating func close(_ route: Route) {
    openWindows.removeAll { $0 == route }
    windowOrder.removeAll { $0 == route }
    minimizedWindows.remove(route)
    windowFrames[route] = nil
    if activeWindow == route { activeWindow = frontmostVisibleWindow() }
  }

  mutating func setFrame(_ frame: CGRect, for route: Route) {
    guard openWindows.contains(route) else { return }
    windowFrames[route] = frame
  }

  private func frontmostVisibleWindow(excluding excluded: Route? = nil) -> Route? {
    windowOrder.last {
      $0 != excluded && openWindows.contains($0) && !minimizedWindows.contains($0)
    }
  }
}
