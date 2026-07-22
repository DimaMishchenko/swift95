import Testing

@testable import Swift95

@Test func automaticShortcutActivationUsesTheCurrentLayoutMode() {
  #expect(DesktopShortcutActivation95.automatic.resolved(isCompact: true) == .singleClick)
  #expect(DesktopShortcutActivation95.automatic.resolved(isCompact: false) == .doubleClick)
}
