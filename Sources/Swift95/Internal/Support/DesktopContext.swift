import SwiftUI

struct DesktopContext {
  var allowsShortcutMovement = false
  var shortcutActivation = DesktopShortcutActivation95.singleClick
  var isSelected: (AnyHashable) -> Bool = { _ in false }
  var select: (AnyHashable) -> Void = { _ in }
  var offset: (AnyHashable) -> CGSize = { _ in .zero }
  var settle: (AnyHashable, CGSize) -> Void = { _, _ in }
  var boundedTranslation: (AnyHashable, CGSize) -> CGSize = { _, translation in translation }
  var resolvedTranslation: (AnyHashable, CGSize) -> CGSize = { _, translation in translation }
}

enum DesktopCoordinateSpace {
  static let name = "Swift95.Desktop"
}

struct DesktopShortcutFramesPreferenceKey: PreferenceKey {
  static var defaultValue: [AnyHashable: CGRect] { [:] }

  static func reduce(
    value: inout [AnyHashable: CGRect],
    nextValue: () -> [AnyHashable: CGRect]
  ) {
    value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
  }
}

extension EnvironmentValues {
  @Entry var desktopContext = DesktopContext()
}
