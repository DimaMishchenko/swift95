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
    minimize: LocalizedStringResource(
      "swift95.window.minimize", bundle: .atURL(Bundle.module.bundleURL)),
    maximize: LocalizedStringResource(
      "swift95.window.maximize", bundle: .atURL(Bundle.module.bundleURL)),
    restore: LocalizedStringResource(
      "swift95.window.restore", bundle: .atURL(Bundle.module.bundleURL)),
    close: LocalizedStringResource("swift95.window.close", bundle: .atURL(Bundle.module.bundleURL)),
    scrollPosition: LocalizedStringResource(
      "swift95.scroll.position", bundle: .atURL(Bundle.module.bundleURL)),
    scrollUp: LocalizedStringResource("swift95.scroll.up", bundle: .atURL(Bundle.module.bundleURL)),
    scrollDown: LocalizedStringResource(
      "swift95.scroll.down", bundle: .atURL(Bundle.module.bundleURL)),
    moveWindow: LocalizedStringResource(
      "swift95.window.move", bundle: .atURL(Bundle.module.bundleURL)),
    resizeWindow: LocalizedStringResource(
      "swift95.window.resize", bundle: .atURL(Bundle.module.bundleURL)),
    expanded: LocalizedStringResource(
      "swift95.state.expanded", bundle: .atURL(Bundle.module.bundleURL)),
    collapsed: LocalizedStringResource(
      "swift95.state.collapsed", bundle: .atURL(Bundle.module.bundleURL)),
    active: LocalizedStringResource(
      "swift95.state.active", bundle: .atURL(Bundle.module.bundleURL)),
    minimized: LocalizedStringResource(
      "swift95.state.minimized", bundle: .atURL(Bundle.module.bundleURL))
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
