import Swift95
import SwiftUI

@main
struct Swift95TestHostApp: App {
  var body: some Scene {
    WindowGroup {
      if ProcessInfo.processInfo.arguments.contains("--workspace") {
        WorkspaceAccessibilityTestScreen(
          disablesResize: ProcessInfo.processInfo.arguments.contains("--no-resize")
        )
      } else {
        AccessibilityTestScreen(
          usesCustomStrings: ProcessInfo.processInfo.arguments.contains("--custom-strings")
        )
      }
    }
  }
}

private struct WorkspaceAccessibilityTestScreen: View {
  let disablesResize: Bool

  @State private var workspace = WorkspaceState95(
    openWindows: [TestRoute.notes],
    activeWindow: TestRoute.notes
  )

  var body: some View {
    Workspace95(
      for: TestRoute.self,
      state: $workspace,
      presentation: .windowed
    ) { _ in
      var window = WorkspaceWindow95(
        "Notes",
        icon: {
          EmptyView()
        }
      ) {
        Text95("Accessible workspace content")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      if disablesResize {
        window = window.windowConfiguration95(
          WorkspaceWindowConfiguration95(
            capabilities: [.minimize, .maximize, .close, .move]
          )
        )
      } else {
        window = window.statusBar95 {
          Text95("Ready")
        }
      }
      return window
    } desktop: {
      Desktop95 {}
    } taskBar: {
      EmptyView()
    }
    .theme95(.classic)
  }
}

private enum TestRoute: Hashable {
  case notes
}

private struct AccessibilityTestScreen: View {
  let usesCustomStrings: Bool

  @State private var checkbox = true
  @State private var radio = 1
  @State private var slider = 0.5
  @State private var scrollOffset = CGFloat.zero

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text95("Swift95 accessibility test host")
          .swiftUI { $0.accessibilityAddTraits(.isHeader) }

        Button95("Run action") {}
          .swiftUI { $0.accessibilityIdentifier("primary-button") }

        Checkbox95("Enable sound", isOn: $checkbox)
          .swiftUI { $0.accessibilityIdentifier("sound-checkbox") }

        RadioButton95("Automatic", value: 1, selection: $radio)
          .swiftUI { $0.accessibilityIdentifier("automatic-radio") }

        Slider95(value: $slider) {
          Text("Volume")
        }
        .swiftUI { $0.accessibilityIdentifier("volume-slider") }

        ScrollIndicator95(
          contentOffset: $scrollOffset,
          contentLength: 600,
          viewportLength: 200
        )
        .frame(height: 180)
        .accessibilityIdentifier("scroll-indicator")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(24)
    }
    .background(Theme95.classic.colors.background)
    .theme95(.classic)
    .strings95(usesCustomStrings ? customStrings : .localized)
  }

  private var customStrings: Strings95 {
    var strings = Strings95.localized
    strings.scrollUp = "Custom scroll up"
    strings.scrollDown = "Custom scroll down"
    strings.scrollPosition = "Custom scroll position"
    return strings
  }
}
