import SwiftUI

/// How shortcuts activate their associated workspace window.
///
/// ```swift
/// Desktop95(shortcutActivation: .doubleClick) {
///   DesktopShortcut95("Notes", value: App.notes) {
///     Image95("notes")
///   }
/// }
/// ```
public enum DesktopShortcutActivation95: Sendable, Equatable {
  /// Opens the shortcut on its first click or tap.
  case singleClick
  /// Selects on one click or tap and opens on a double-click or double-tap.
  case doubleClick
}
