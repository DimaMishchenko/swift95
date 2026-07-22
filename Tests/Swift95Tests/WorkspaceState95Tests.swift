import CoreGraphics
import Testing

@testable import Swift95

struct WorkspaceState95Tests {
  @Test func initializationNormalizesInvalidWindowMetadata() {
    let state = WorkspaceState95<TestRoute>(
      openWindows: [.notes, .notes, .settings],
      windowOrder: [.settings, .settings],
      activeWindow: .settings,
      minimizedWindows: [.settings],
      windowFrames: [
        .notes: CGRect(x: 10, y: 10, width: 300, height: 200),
        .closed: CGRect(x: 20, y: 20, width: 300, height: 200)
      ]
    )

    #expect(state.openWindows == [.notes, .settings])
    #expect(state.windowOrder == [.settings, .notes])
    #expect(state.activeWindow == .notes)
    #expect(state.minimizedWindows == [.settings])
    #expect(Set(state.windowFrames.keys) == [.notes])
  }

  @Test func fullyMinimizedWorkspaceHasNoActiveWindow() {
    let state = WorkspaceState95<TestRoute>(
      openWindows: [.notes, .settings],
      minimizedWindows: [.notes, .settings]
    )

    #expect(state.activeWindow == nil)
  }

  @Test func openingAnExistingWindowFocusesWithoutDuplicatingItsTask() {
    var state = WorkspaceState95<TestRoute>()

    state.open(.notes)
    state.open(.settings)
    state.open(.notes)

    #expect(state.openWindows == [.notes, .settings])
    #expect(state.windowOrder == [.settings, .notes])
    #expect(state.activeWindow == .notes)
  }

  @Test func minimizingTheActiveWindowRevealsTheFrontmostVisibleWindow() {
    var state = WorkspaceState95<TestRoute>(openWindows: [.notes, .settings])

    state.minimize(.settings)

    #expect(state.minimizedWindows == [.settings])
    #expect(state.activeWindow == .notes)
  }

  @Test func changingAnInactiveWindowDoesNotStealFocus() {
    var state = WorkspaceState95<TestRoute>(
      openWindows: [.notes, .settings],
      activeWindow: .settings
    )

    state.minimize(.notes)
    #expect(state.activeWindow == .settings)

    state.close(.notes)
    #expect(state.activeWindow == .settings)
    #expect(state.openWindows == [.settings])
  }

  @Test func taskActivationMinimizesAndRestoresTheActiveWindow() {
    var state = WorkspaceState95<TestRoute>(openWindows: [.notes])

    state.toggleTask(.notes)
    #expect(state.activeWindow == nil)
    #expect(state.minimizedWindows == [.notes])

    state.toggleTask(.notes)
    #expect(state.activeWindow == .notes)
    #expect(state.minimizedWindows.isEmpty)
  }

  @Test func closingTheActiveWindowRemovesRuntimeStateAndFocusesTheNextWindow() {
    var state = WorkspaceState95<TestRoute>(
      openWindows: [.notes, .settings],
      activeWindow: .settings,
      windowFrames: [.settings: CGRect(x: 20, y: 30, width: 320, height: 240)]
    )

    state.close(.settings)

    #expect(state.openWindows == [.notes])
    #expect(state.windowOrder == [.notes])
    #expect(state.activeWindow == .notes)
    #expect(state.windowFrames[.settings] == nil)
  }

  private enum TestRoute: Hashable {
    case notes
    case settings
    case closed
  }
}
