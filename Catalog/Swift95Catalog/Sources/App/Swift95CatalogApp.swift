import Swift95
import SwiftUI

@main
struct Swift95CatalogApp: App {
  var body: some Scene {
    WindowGroup {
      catalogContent
    }
    #if os(macOS)
      .defaultSize(width: 1_100, height: 760)
      .windowResizability(.contentMinSize)
    #endif
  }

  @ViewBuilder
  private var catalogContent: some View {
    #if os(macOS)
      CatalogView()
        .frame(minWidth: 760, minHeight: 520)
    #else
      CatalogView()
    #endif
  }
}
