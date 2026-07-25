import Swift95
import Swift95Icons
import SwiftUI

struct CatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var workspaceState: WorkspaceState95<CatalogRoute>
  @State private var menuActivation = "None"

  private let configuration: CatalogLaunchConfiguration

  init(configuration: CatalogLaunchConfiguration = .current) {
    self.configuration = configuration
    if let rawValue = configuration.destination,
      let destination = CatalogDestination(rawValue: rawValue)
    {
      let route = CatalogRoute.destination(destination)
      _workspaceState = State(
        initialValue: WorkspaceState95(
          openWindows: [route],
          activeWindow: route
        )
      )
    } else {
      _workspaceState = State(initialValue: WorkspaceState95())
    }
  }

  var body: some View {
    Workspace95(
      for: CatalogRoute.self,
      state: $workspaceState,
      presentation: catalogPresentation,
      catalogWindow
    ) {
      catalogDesktop
    } taskBar: {
      TaskBar95("Start") {
        catalogTaskBarIcon(.logo, size: .standard)
      } menu: {
        StartMenu95 {
          WorkspaceLink95("Components", value: CatalogRoute.browser(.components))
          WorkspaceLink95("Foundations", value: CatalogRoute.browser(.foundations))
          WorkspaceLink95("Icons", value: CatalogRoute.destination(.icons))
          WorkspaceLink95("Test Lab", value: CatalogRoute.browser(.testLab))

          Divider95()

          WorkspaceLink95("Workspace95", value: CatalogRoute.destination(.workspace))
        }
      } tray: {
        Text95(
          configuration.isUITesting
            ? "12:00"
            : Date.now.formatted(date: .omitted, time: .shortened)
        )
      }
      .accessibilityHidden(configuration.isUITesting && configuration.destination != nil)
    }
    .background(theme.colors.background.ignoresSafeArea())
  }

  private var catalogPresentation: WorkspacePresentation95 {
    if configuration.destination == CatalogDestination.testWorkspace.rawValue {
      return .windowed
    }
    if configuration.isUITesting, configuration.destination != nil {
      return .compact
    }
    return .automatic
  }

  @ViewBuilder
  private var catalogDesktop: some View {
    let desktop = Desktop95 {
      DesktopShortcut95("Components", value: CatalogRoute.browser(.components)) {
        catalogIcon(CatalogSection.components.icon)
      }

      DesktopShortcut95("Foundations", value: CatalogRoute.browser(.foundations)) {
        catalogIcon(CatalogSection.foundations.icon)
      }

      DesktopShortcut95("Icons", value: CatalogRoute.destination(.icons)) {
        catalogIcon(CatalogDestination.icons.icon)
      }

      DesktopShortcut95("Test Lab", value: CatalogRoute.browser(.testLab)) {
        catalogIcon(CatalogSection.testLab.icon)
      }

      DesktopShortcut95("Workspace95", value: CatalogRoute.destination(.workspace)) {
        catalogIcon(CatalogDestination.workspace.icon)
      }
    }

    if configuration.isUITesting, configuration.destination != nil {
      Desktop95 {}
    } else if configuration.isUITesting {
      desktop
    } else {
      desktop.desktopState95(CatalogRoute.self, storageKey: "Swift95Catalog.MainDesktop")
    }
  }

  private func catalogWindow(_ route: CatalogRoute) -> WorkspaceWindow95 {
    switch route {
    case let .browser(section):
      return WorkspaceWindow95(section.title) {
        catalogIcon(section.icon, size: .small)
      } taskBarIcon: {
        catalogTaskBarIcon(section.icon)
      } content: {
        CatalogBrowserView(section: section)
      }
    case .destination(.testWorkspace):
      var window = WorkspaceWindow95("Workspace") {
        EmptyView()
      } taskBarIcon: {
        EmptyView()
      } content: {
        TestLabWorkspaceView95()
      }

      if configuration.disablesResize {
        window = window.windowConfiguration95(
          WorkspaceWindowConfiguration95(
            capabilities: [.minimize, .maximize, .close, .move]
          )
        )
      } else {
        window = window.statusBar95 {
          Text95("Ready")
            .accessibilityRespondsToUserInteraction(false)
        }
      }
      return window
    case .destination(.testMenu):
      return WorkspaceWindow95("Menu") {
        EmptyView()
      } taskBarIcon: {
        EmptyView()
      } content: {
        TestLabMenuView95(activation: menuActivation)
      }
      .menuBar95 {
        Menu95("File") {
          MenuItem95("Activate") {
            menuActivation = "Activate"
          }
          .swiftUI { $0.accessibilityIdentifier("menu.activate") }
          MenuItem95("Second") {
            menuActivation = "Second"
          }
          .swiftUI { $0.accessibilityIdentifier("menu.second") }
          MenuDivider95()
          MenuItem95("Unavailable", isEnabled: false) {}
            .swiftUI { $0.accessibilityIdentifier("menu.unavailable") }
        }
        .swiftUI { $0.accessibilityIdentifier("menu.file") }
        Menu95("Help") {
          MenuItem95("About") {
            menuActivation = "About"
          }
        }
        .swiftUI { $0.accessibilityIdentifier("menu.help") }
      }
    case let .destination(destination):
      return WorkspaceWindow95(destination.title) {
        catalogIcon(destination.icon, size: .small)
      } taskBarIcon: {
        catalogTaskBarIcon(destination.icon)
      } content: {
        CatalogDestinationView(destination: destination)
      }
    }
  }

  private func catalogIcon(
    _ name: Icon95.Name,
    size: Icon95.Size = .standard
  ) -> some View {
    Icon95(name, size: size)
      .padding(theme.spacing.xxxs)
      .accessibilityHidden(true)
  }

  private func catalogTaskBarIcon(
    _ name: Icon95.Name,
    size: Icon95.Size = .small
  ) -> some View {
    Icon95(name, size: size)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .accessibilityHidden(true)
  }
}

enum CatalogRoute: Hashable, Codable {
  case browser(CatalogSection)
  case destination(CatalogDestination)
}

enum CatalogSection: String, CaseIterable, Identifiable, Hashable, Codable {
  case components
  case foundations
  case testLab

  var id: Self { self }

  var title: String {
    switch self {
    case .components: "Components"
    case .foundations: "Foundations"
    case .testLab: "Test Lab"
    }
  }

  var icon: Icon95.Name {
    switch self {
    case .components: .controls3000
    case .foundations: .packager
    case .testLab: .hardwareDiag
    }
  }

  var destinations: [CatalogDestination] {
    CatalogDestination.allCases.filter { $0.section == self }
  }
}

enum CatalogDestination: String, CaseIterable, Identifiable, Hashable, Codable {
  case text
  case button
  case alert
  case image
  case slider
  case textField
  case secureField
  case textEditor
  case scrollIndicator
  case scrollView
  case list
  case divider
  case checkbox
  case radioButton
  case progressView
  case picker
  case tabs
  case workspace
  case bevel
  case typography
  case colors
  case spacing
  case metrics
  case icons
  case testControls
  case testInteractions
  case testOverrides
  case testWorkspace
  case testMenu

  var id: Self { self }

  var section: CatalogSection {
    switch self {
    case .text, .button, .alert, .image, .slider, .textField, .secureField, .textEditor,
      .scrollIndicator, .scrollView, .list, .divider, .checkbox, .radioButton,
      .progressView, .picker, .tabs, .workspace:
      .components
    case .bevel, .typography, .colors, .spacing, .metrics, .icons:
      .foundations
    case .testControls, .testInteractions, .testOverrides, .testWorkspace, .testMenu:
      .testLab
    }
  }

  var title: String {
    switch self {
    case .text: "Text95"
    case .button: "Button95"
    case .alert: "Alert95"
    case .image: "Image95"
    case .slider: "Slider95"
    case .textField: "TextField95"
    case .secureField: "SecureField95"
    case .textEditor: "TextEditor95"
    case .scrollIndicator: "ScrollIndicator95"
    case .scrollView: "ScrollView95"
    case .list: "List95"
    case .divider: "Divider95"
    case .checkbox: "Checkbox95"
    case .radioButton: "RadioButton95"
    case .progressView: "ProgressView95"
    case .picker: "Picker95"
    case .tabs: "Tabs95"
    case .workspace: "Workspace95"
    case .bevel: "Bevel"
    case .typography: "Typography"
    case .colors: "Colors"
    case .spacing: "Spacing"
    case .metrics: "Metrics"
    case .icons: "Swift95Icons"
    case .testControls: "Accessibility"
    case .testInteractions: "Interactions"
    case .testOverrides: "Overrides"
    case .testWorkspace: "Workspace Fixtures"
    case .testMenu: "Menu Fixtures"
    }
  }

  var icon: Icon95.Name {
    switch self {
    case .text: .fontWindow
    case .button: .pushButton
    case .alert: .warning
    case .image: .imgedit10
    case .slider: .sndvol32300
    case .textField: .fileText
    case .secureField: .lock
    case .textEditor: .notepad
    case .scrollIndicator: .scrollingMarquee100
    case .scrollView: .fileTextSettings
    case .list: .list
    case .divider: .columns
    case .checkbox: .tick
    case .radioButton: .circle
    case .progressView: .graphWindow
    case .picker: .details
    case .tabs: .windowsExplorer
    case .workspace: .desktop
    case .bevel: .d3PipesIdApp
    case .typography: .font
    case .colors: .paint
    case .spacing: .alignCenter
    case .metrics: .calculatorSmall
    case .icons: .fileIcons
    case .testControls: .accessibility
    case .testInteractions: .hand
    case .testOverrides: .settings
    case .testWorkspace: .shellDesktop
    case .testMenu: .list
    }
  }
}

private struct CatalogBrowserView: View {
  @Environment(\.theme95) private var theme

  let section: CatalogSection

  var body: some View {
    VStack(alignment: .leading, spacing: theme.spacing.m) {
      if section == .testLab {
        Text95(
          """
          Test Lab contains deterministic fixtures used by UI tests to verify interactions and \
          accessibility that image snapshots cannot cover.
          """
        )
        .padding(.horizontal, theme.spacing.xl)
        .padding(.top, theme.spacing.xl)
        .accessibilityIdentifier("test-lab.notice")
        .accessibilityRespondsToUserInteraction(false)
      }

      List95(section.destinations, style: .largeIcon) { destination in
        WorkspaceLink95(value: CatalogRoute.destination(destination)) {
          Row95 {
            Icon95(destination.icon)
              .accessibilityHidden(true)
          } label: {
            Text95(destination.title)
          } accessory: {
            true
          }
        }
        .buttonStyle(.plain)
      }
    }
  }
}

private struct CatalogDestinationView: View {
  let destination: CatalogDestination

  var body: some View {
    switch destination {
    case .text:
      TextCatalogView95()
    case .button:
      ButtonCatalogView95()
    case .alert:
      AlertCatalogView95()
    case .image:
      ImageCatalogView95()
    case .slider:
      SliderCatalogView95()
    case .textField:
      TextFieldCatalogView95()
    case .secureField:
      SecureFieldCatalogView95()
    case .textEditor:
      TextEditorCatalogView95()
    case .scrollIndicator:
      ScrollIndicatorCatalogView95()
    case .scrollView:
      ScrollViewCatalogView95()
    case .list:
      ListCatalogView()
    case .divider:
      DividerCatalogView95()
    case .checkbox:
      CheckboxCatalogView95()
    case .radioButton:
      RadioButtonCatalogView95()
    case .progressView:
      ProgressViewCatalogView95()
    case .picker:
      PickerCatalogView95()
    case .tabs:
      TabsCatalogView95()
    case .workspace:
      WorkspaceCatalogView()
    case .bevel:
      BevelCatalogView95()
    case .typography:
      TypographyCatalogView95()
    case .colors:
      ColorsCatalogView95()
    case .spacing:
      SpacingCatalogView95()
    case .metrics:
      MetricsCatalogView95()
    case .icons:
      IconCatalogView95()
    case .testControls:
      TestLabAccessibilityView95()
    case .testInteractions:
      TestLabInteractionsView95()
    case .testOverrides:
      TestLabOverridesView95()
    case .testWorkspace:
      TestLabWorkspaceView95()
    case .testMenu:
      TestLabMenuView95(activation: "None")
    }
  }
}

#Preview("Catalog") {
  CatalogView()
}
