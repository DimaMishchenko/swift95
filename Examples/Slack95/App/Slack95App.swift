import SwiftUI

@main
struct Slack95App: App {
  var body: some Scene {
    WindowGroup("Slack95 — Fieldnotes") {
      SlackExampleView()
        #if os(macOS)
          .frame(minWidth: 800, minHeight: 580)
        #endif
    }
    #if os(macOS)
      .defaultSize(width: 1100, height: 760)
    #endif
  }
}
