import CoreGraphics
import Testing

@testable import Swift95

struct DesktopPlacementTests {
  @Test func draggingAShortcutIsClampedToDesktopBounds() {
    let id = AnyHashable(TestRoute.notes)
    let frames = [id: CGRect(x: 12, y: 12, width: 88, height: 72)]

    let translation = DesktopPlacement.boundedTranslation(
      for: id,
      proposed: CGSize(width: 500, height: 500),
      frames: frames,
      desktopSize: CGSize(width: 320, height: 240)
    )

    #expect(translation == CGSize(width: 220, height: 156))
  }

  @Test func settlingAShortcutAvoidsOccupiedDesktopSpace() {
    let notes = AnyHashable(TestRoute.notes)
    let settings = AnyHashable(TestRoute.settings)
    let frames = [
      notes: CGRect(x: 12, y: 12, width: 88, height: 72),
      settings: CGRect(x: 12, y: 96, width: 88, height: 72)
    ]

    let translation = DesktopPlacement.resolvedTranslation(
      for: settings,
      proposed: CGSize(width: 0, height: -84),
      frames: frames,
      desktopSize: CGSize(width: 320, height: 240),
      clearance: 4
    )
    let resolvedFrame = frames[settings]!
      .offsetBy(
        dx: translation.width,
        dy: translation.height
      )

    #expect(!resolvedFrame.intersects(frames[notes]!.insetBy(dx: -4, dy: -4)))
  }

  @Test func restoredPositionsAreNormalizedAfterTheDesktopShrinks() {
    let notes = AnyHashable(TestRoute.notes)
    let settings = AnyHashable(TestRoute.settings)
    let baseFrames = [
      notes: CGRect(x: 12, y: 12, width: 88, height: 72),
      settings: CGRect(x: 12, y: 96, width: 88, height: 72)
    ]

    let offsets = DesktopPlacement.normalizedOffsets(
      baseFrames: baseFrames,
      offsets: [
        notes: CGSize(width: 500, height: 500),
        settings: CGSize(width: 500, height: 500)
      ],
      desktopSize: CGSize(width: 320, height: 180),
      clearance: 4
    )
    let frames = DesktopPlacement.positionedFrames(baseFrames: baseFrames, offsets: offsets)
    let desktopBounds = CGRect(x: 0, y: 0, width: 320, height: 180)

    #expect(desktopBounds.contains(frames[notes]!))
    #expect(desktopBounds.contains(frames[settings]!))
    #expect(!frames[notes]!.intersects(frames[settings]!.insetBy(dx: -4, dy: -4)))
  }

  private enum TestRoute: Hashable {
    case notes
    case settings
  }
}
