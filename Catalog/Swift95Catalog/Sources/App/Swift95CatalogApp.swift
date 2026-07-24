import Swift95
import SwiftUI

@main
struct Swift95CatalogApp: App {
  private let configuration = CatalogLaunchConfiguration.current

  var body: some Scene {
    WindowGroup {
      catalogContent
    }
    #if os(macOS)
      .defaultSize(width: 1_100, height: 760)
      .windowResizability(.contentMinSize)
      .restorationBehavior(.disabled)
      .defaultLaunchBehavior(.presented)
    #endif
  }

  @ViewBuilder
  private var catalogContent: some View {
    #if os(macOS)
      CatalogView(configuration: configuration)
        .environment(\.catalogLaunchConfiguration, configuration)
        .frame(minWidth: 760, minHeight: 520)
    #else
      CatalogView(configuration: configuration)
        .environment(\.catalogLaunchConfiguration, configuration)
    #endif
  }
}
