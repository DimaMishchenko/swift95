import SwiftUI

@main
struct Finder95App: App {
  var body: some Scene {
    WindowGroup {
      FinderExampleView()
        #if os(macOS)
          .frame(minWidth: 800, minHeight: 580)
        #endif
    }
    #if os(macOS)
      .defaultSize(width: 1100, height: 760)
      .windowStyle(.plain)
    #endif
  }
}
