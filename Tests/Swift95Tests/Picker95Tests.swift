import CoreGraphics
import SwiftUI
import Testing

@testable import Swift95

#if os(macOS)
  import AppKit
#endif

struct Picker95Tests {
  #if os(macOS)
    @MainActor
    @Test func presentationAnchorDoesNotConsumePickerClicks() {
      let anchor = PickerPresentationAnchor95(frame: CGRect(x: 0, y: 0, width: 200, height: 32))

      #expect(anchor.hitTest(CGPoint(x: 100, y: 16)) == nil)
    }

    @MainActor
    @Test func pickerPanelIsOrderedAboveItsParentWindow() {
      let window = NSWindow(
        contentRect: CGRect(x: 100, y: 100, width: 400, height: 300),
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
      )
      let anchor = PickerPresentationAnchor95(
        frame: CGRect(x: 40, y: 220, width: 240, height: 32)
      )
      window.contentView?.addSubview(anchor)
      let coordinator = MacPickerPresentation95<EmptyView>.Coordinator()

      coordinator.present(
        AnyView(Text("Option").frame(width: 240, height: 40)),
        from: anchor,
        overlap: 2
      )

      #expect(window.childWindows?.count == 1)
      #expect(window.childWindows?.first?.isVisible == true)

      coordinator.dismiss()
      #expect(window.childWindows?.isEmpty == true)
    }
  #endif

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
