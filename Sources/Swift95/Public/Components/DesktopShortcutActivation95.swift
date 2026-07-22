import SwiftUI

/// How shortcuts activate their associated workspace window.
///
/// The default ``automatic`` behavior matches each platform idiom: a single tap in compact
/// layouts and a double-click in regular desktop layouts.
///
/// ```swift
/// Desktop95(shortcutActivation: .doubleClick) {
///   DesktopShortcut95("Notes", value: App.notes) {
///     Image95("notes")
///   }
/// }
/// ```
public enum DesktopShortcutActivation95: Sendable, Equatable {
  /// Uses double-click activation in regular desktop layouts and single-click activation in
  /// compact layouts.
  case automatic
  /// Opens the shortcut on its first click or tap.
  case singleClick
  /// Selects on one click and opens on a double-click.
  case doubleClick

  func resolved(isCompact: Bool) -> DesktopShortcutActivation95 {
    switch self {
    case .automatic:
      isCompact ? .singleClick : .doubleClick
    case .singleClick, .doubleClick:
      self
    }
  }
}
