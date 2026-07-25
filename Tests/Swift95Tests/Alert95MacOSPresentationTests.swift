#if os(macOS)
  import AppKit
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Alert95MacOSPresentationTests {
    @Test func alertUsesABorderlessPanelWithoutACoverOrAnimation() throws {
      let model = AlertPresentationModel95()
      let root = AlertPresentationHarness95(model: model)
        .frame(width: 900, height: 650)

      let window = NSWindow(
        contentRect: CGRect(x: 0, y: 0, width: 900, height: 650),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
      window.isReleasedWhenClosed = false
      window.contentView = NSHostingView(rootView: root)
      window.orderFrontRegardless()

      defer {
        window.close()
      }

      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))

      #expect(window.attachedSheet == nil)
      let panel = try #require(window.childWindows?.first as? NSPanel)
      #expect(panel.styleMask == [.borderless])
      #expect(panel.animationBehavior == .none)
      #expect(panel.backgroundColor == .clear)
      #expect(panel.hasShadow == false)
      #expect(panel.isOpaque == false)
      #expect(panel.frame.width <= 600)
      #expect(panel.frame.height <= 400)
      #expect(panel.frame.size != window.frame.size)

      model.isPresented = false
      RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
      #expect(window.childWindows?.isEmpty == true)
    }
  }

  @MainActor
  private final class AlertPresentationModel95: ObservableObject {
    @Published var isPresented = true
  }

  private struct AlertPresentationHarness95: View {
    @ObservedObject var model: AlertPresentationModel95

    var body: some View {
      Text("Presentation anchor")
        .alert95(
          "Replace file?",
          isPresented: $model.isPresented,
          isCloseButtonEnabled: false
        ) {
          Button("Replace") {}
          Button("Cancel", role: .cancel) {}
        } message: {
          Text("A file with this name already exists.")
        }
    }
  }
#endif
