import SwiftUI

struct DesktopPositionStore {
  var offsets: () -> [AnyHashable: CGSize]
  var setOffset: (AnyHashable, CGSize) -> Void
}

extension EnvironmentValues {
  @Entry var desktopPositionStore: DesktopPositionStore?
}
