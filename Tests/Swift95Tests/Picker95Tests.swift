import CoreGraphics
import Testing

@testable import Swift95

struct Picker95Tests {
  @Test func optionPanelOpensBelowWhenSpaceIsAvailable() {
    let frame = PickerOptionPlacement95.frame(
      triggerFrame: CGRect(x: 20, y: 100, width: 240, height: 32),
      contentSize: CGSize(width: 240, height: 120),
      bounds: CGRect(x: 0, y: 0, width: 320, height: 640),
      minimumWidth: 160,
      overlap: 2
    )

    #expect(frame == CGRect(x: 20, y: 130, width: 240, height: 120))
  }

  @Test func optionPanelFlipsAboveNearTheBottomEdge() {
    let frame = PickerOptionPlacement95.frame(
      triggerFrame: CGRect(x: 20, y: 580, width: 240, height: 32),
      contentSize: CGSize(width: 240, height: 120),
      bounds: CGRect(x: 0, y: 0, width: 320, height: 640),
      minimumWidth: 160,
      overlap: 2
    )

    #expect(frame == CGRect(x: 20, y: 462, width: 240, height: 120))
  }

  @Test func optionPanelRemainsInsideTheHorizontalViewport() {
    let frame = PickerOptionPlacement95.frame(
      triggerFrame: CGRect(x: 280, y: 100, width: 80, height: 32),
      contentSize: CGSize(width: 160, height: 120),
      bounds: CGRect(x: 0, y: 0, width: 320, height: 640),
      minimumWidth: 160,
      overlap: 2
    )

    #expect(frame == CGRect(x: 160, y: 130, width: 160, height: 120))
  }
}
