import Foundation
import SwiftUI

/// Library-owned text used by Swift95 controls.
///
/// Keep product copy in the application. This value only contains labels that
/// Swift95 must provide itself for system and accessibility behavior.
public struct Strings95: Sendable {
  /// The minimize-window label.
  public var minimize: LocalizedStringResource
  /// The maximize-window label.
  public var maximize: LocalizedStringResource
  /// The restore-window label.
  public var restore: LocalizedStringResource
  /// The close-window label.
  public var close: LocalizedStringResource
  /// The scrollbar position label.
  public var scrollPosition: LocalizedStringResource
  /// The scroll-up label.
  public var scrollUp: LocalizedStringResource
  /// The scroll-down label.
  public var scrollDown: LocalizedStringResource
  /// The move-window action label.
  public var moveWindow: LocalizedStringResource
  /// The resize-window action label.
  public var resizeWindow: LocalizedStringResource
  /// The expanded-state value.
  public var expanded: LocalizedStringResource
  /// The collapsed-state value.
  public var collapsed: LocalizedStringResource
  /// The active-state value.
  public var active: LocalizedStringResource
  /// The minimized-state value.
  public var minimized: LocalizedStringResource

  /// Creates a set of library-owned interface strings.
  public init(
    minimize: LocalizedStringResource,
    maximize: LocalizedStringResource,
    restore: LocalizedStringResource,
    close: LocalizedStringResource,
    scrollPosition: LocalizedStringResource,
    scrollUp: LocalizedStringResource,
    scrollDown: LocalizedStringResource,
    moveWindow: LocalizedStringResource,
    resizeWindow: LocalizedStringResource,
    expanded: LocalizedStringResource,
    collapsed: LocalizedStringResource,
    active: LocalizedStringResource,
    minimized: LocalizedStringResource
  ) {
    self.minimize = minimize
    self.maximize = maximize
    self.restore = restore
    self.close = close
    self.scrollPosition = scrollPosition
    self.scrollUp = scrollUp
    self.scrollDown = scrollDown
    self.moveWindow = moveWindow
    self.resizeWindow = resizeWindow
    self.expanded = expanded
    self.collapsed = collapsed
    self.active = active
    self.minimized = minimized
  }

  /// Labels localized from Swift95's resource bundle.
  public static let localized = Strings95(
    minimize: LocalizedStringResource("swift95.window.minimize", bundle: .module),
    maximize: LocalizedStringResource("swift95.window.maximize", bundle: .module),
    restore: LocalizedStringResource("swift95.window.restore", bundle: .module),
    close: LocalizedStringResource("swift95.window.close", bundle: .module),
    scrollPosition: LocalizedStringResource("swift95.scroll.position", bundle: .module),
    scrollUp: LocalizedStringResource("swift95.scroll.up", bundle: .module),
    scrollDown: LocalizedStringResource("swift95.scroll.down", bundle: .module),
    moveWindow: LocalizedStringResource("swift95.window.move", bundle: .module),
    resizeWindow: LocalizedStringResource("swift95.window.resize", bundle: .module),
    expanded: LocalizedStringResource("swift95.state.expanded", bundle: .module),
    collapsed: LocalizedStringResource("swift95.state.collapsed", bundle: .module),
    active: LocalizedStringResource("swift95.state.active", bundle: .module),
    minimized: LocalizedStringResource("swift95.state.minimized", bundle: .module)
  )
}

extension EnvironmentValues {
  /// Library-owned text inherited by Swift95 components.
  @Entry public var strings95: Strings95 = .localized
}

extension View {
  /// Overrides library-owned text for this view hierarchy.
  public func strings95(_ strings: Strings95) -> some View {
    environment(\.strings95, strings)
  }
}
