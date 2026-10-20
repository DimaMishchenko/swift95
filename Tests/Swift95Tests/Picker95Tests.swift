import CoreGraphics
import SwiftUI
import Testing

@testable import Swift95

#if os(macOS)
  import AppKit
#endif

@Suite(.serialized)
struct Picker95Tests {
  #if os(macOS)
    @MainActor
    @Test func presentationAnchorDoesNotConsumePickerClicks() {
      let anchor = PickerPresentationAnchor95(frame: CGRect(x: 0, y: 0, width: 200, height: 32))

      #expect(anchor.hitTest(CGPoint(x: 100, y: 16)) == nil)
    }

    @MainActor
    @Test func optionPanelInheritsAndUpdatesThePresentingEnvironment() throws {
      let model = PickerEnvironmentModel95()
      let recorder = PickerEnvironmentRecorder95()
      let host = NSHostingView(
        rootView: PickerEnvironmentHarness95(model: model, recorder: recorder))
      let window = NSWindow(
        contentRect: CGRect(x: 100, y: 100, width: 400, height: 300),
        styleMask: [.borderless], backing: .buffered, defer: false
      )
      window.isReleasedWhenClosed = false
      window.contentView = host
      window.orderFrontRegardless()
      defer { window.close() }
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

      model.isPresented = true
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

      let initial = try #require(recorder.values)
      #expect(initial.locale.identifier == "ar")
      #expect(initial.layoutDirection == .rightToLeft)
      #expect(initial.dynamicTypeSize == .accessibility1)
      #expect(String(localized: initial.strings95.close) == "Custom close")
      #expect(initial.pickerTestMarker95 == "Initial marker")
      #expect(window.childWindows?.first?.isVisible == true)

      model.marker = "Updated marker"
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
      #expect(recorder.values?.pickerTestMarker95 == "Updated marker")

      model.isPresented = false
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
      #expect(window.childWindows?.isEmpty == true)
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

#if os(macOS)
  private struct PickerTestMarkerKey95: EnvironmentKey {
    static let defaultValue = "Missing marker"
  }

  extension EnvironmentValues {
    fileprivate var pickerTestMarker95: String {
      get { self[PickerTestMarkerKey95.self] }
      set { self[PickerTestMarkerKey95.self] = newValue }
    }
  }

  @MainActor
  private final class PickerEnvironmentModel95: ObservableObject {
    @Published var isPresented = false
    @Published var marker = "Initial marker"
  }

  @MainActor
  private final class PickerEnvironmentRecorder95 {
    var values: EnvironmentValues?
  }

  private struct PickerEnvironmentProbe95: NSViewRepresentable {
    let recorder: PickerEnvironmentRecorder95

    func makeNSView(context: Context) -> NSView {
      recorder.values = context.environment
      return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      recorder.values = context.environment
    }
  }

  private struct PickerEnvironmentHarness95: View {
    @ObservedObject var model: PickerEnvironmentModel95
    let recorder: PickerEnvironmentRecorder95

    var body: some View {
      MacPickerPresentation95(
        isPresented: $model.isPresented,
        overlap: 2,
        minimumWidth: 180
      ) {
        PickerEnvironmentProbe95(recorder: recorder)
          .frame(width: 180, height: 40)
      }
      .frame(width: 180, height: 32)
      .environment(\.locale, Locale(identifier: "ar"))
      .environment(\.layoutDirection, .rightToLeft)
      .environment(\.dynamicTypeSize, .accessibility1)
      .environment(\.pickerTestMarker95, model.marker)
      .strings95(strings)
    }

    private var strings: Strings95 {
      var strings = Strings95.localized
      strings.close = "Custom close"
      return strings
    }
  }
#endif
