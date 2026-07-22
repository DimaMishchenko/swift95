import Swift95
import SwiftUI

struct CatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var workspaceState = WorkspaceState95<CatalogRoute>()

  var body: some View {
    Workspace95(
      for: CatalogRoute.self,
      state: $workspaceState,
      catalogWindow
    ) {
      Desktop95 {
        DesktopShortcut95("Components", value: CatalogRoute.browser(.components)) {
          catalogIcon("shippingbox.fill")
        }

        DesktopShortcut95("Foundations", value: CatalogRoute.browser(.foundations)) {
          catalogIcon("square.3.layers.3d")
        }

        DesktopShortcut95("Workspace95", value: CatalogRoute.destination(.workspace)) {
          catalogIcon("macwindow.on.rectangle")
        }
      }
      .desktopState95(CatalogRoute.self, storageKey: "Swift95Catalog.MainDesktop")
    } taskBar: {
      TaskBar95("Start") {
        catalogTaskBarIcon("flag.fill")
      } menu: {
        StartMenu95 {
          WorkspaceLink95("Components", value: CatalogRoute.browser(.components))
          WorkspaceLink95("Foundations", value: CatalogRoute.browser(.foundations))

          Divider95()

          WorkspaceLink95("Workspace95", value: CatalogRoute.destination(.workspace))
        }
      } tray: {
        Text95(Date.now.formatted(date: .omitted, time: .shortened))
      }
    }
    .background(theme.colors.background.ignoresSafeArea())
  }

  private func catalogWindow(_ route: CatalogRoute) -> WorkspaceWindow95 {
    switch route {
    case let .browser(section):
      WorkspaceWindow95(section.title) {
        catalogIcon(section.symbol)
      } taskBarIcon: {
        catalogTaskBarIcon(section.symbol)
      } content: {
        CatalogBrowserView(section: section)
      }
    case let .destination(destination):
      WorkspaceWindow95(destination.title) {
        catalogIcon(destination.symbol)
      } taskBarIcon: {
        catalogTaskBarIcon(destination.symbol)
      } content: {
        CatalogDestinationView(destination: destination)
      }
    }
  }

  private func catalogIcon(_ systemName: String) -> some View {
    Image(systemName: systemName)
      .resizable()
      .scaledToFit()
      .foregroundStyle(.white)
      .padding(2)
  }

  private func catalogTaskBarIcon(_ systemName: String) -> some View {
    Image(systemName: systemName)
      .resizable()
      .scaledToFit()
      .padding(2)
  }
}

private enum CatalogRoute: Hashable, Codable {
  case browser(CatalogSection)
  case destination(CatalogDestination)
}

private enum CatalogSection: String, CaseIterable, Identifiable, Hashable, Codable {
  case components
  case foundations

  var id: Self { self }

  var title: String {
    switch self {
    case .components: "Components"
    case .foundations: "Foundations"
    }
  }

  var symbol: String {
    switch self {
    case .components: "shippingbox.fill"
    case .foundations: "square.3.layers.3d"
    }
  }

  var destinations: [CatalogDestination] {
    CatalogDestination.allCases.filter { $0.section == self }
  }
}

private enum CatalogDestination: String, CaseIterable, Identifiable, Hashable, Codable {
  case text
  case button
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

  var id: Self { self }

  var section: CatalogSection {
    switch self {
    case .text, .button, .image, .slider, .textField, .secureField, .textEditor,
      .scrollIndicator, .scrollView, .list, .divider, .checkbox, .radioButton,
      .progressView, .picker, .tabs, .workspace:
      .components
    case .bevel, .typography, .colors, .spacing, .metrics:
      .foundations
    }
  }

  var title: String {
    switch self {
    case .text: "Text95"
    case .button: "Button95"
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
    }
  }

  var symbol: String {
    switch self {
    case .text: "textformat"
    case .button: "capsule"
    case .image: "photo"
    case .slider: "slider.horizontal.3"
    case .textField: "character.cursor.ibeam"
    case .secureField: "lock"
    case .textEditor: "doc.text"
    case .scrollIndicator: "arrow.up.and.down"
    case .scrollView: "scroll"
    case .list: "list.bullet"
    case .divider: "minus"
    case .checkbox: "checkmark.square"
    case .radioButton: "circle.inset.filled"
    case .progressView: "chart.bar.fill"
    case .picker: "list.bullet.rectangle"
    case .tabs: "square.on.square"
    case .workspace: "macwindow.on.rectangle"
    case .bevel: "square.3.layers.3d"
    case .typography: "textformat.size"
    case .colors: "paintpalette"
    case .spacing: "arrow.left.and.right"
    case .metrics: "ruler"
    }
  }
}

private struct CatalogBrowserView: View {
  let section: CatalogSection

  var body: some View {
    List95(section.destinations, style: .largeIcon) { destination in
      WorkspaceLink95(value: CatalogRoute.destination(destination)) {
        Row95 {
          Image(systemName: destination.symbol)
            .resizable()
            .scaledToFit()
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

private struct CatalogDestinationView: View {
  let destination: CatalogDestination

  var body: some View {
    switch destination {
    case .text:
      TextCatalogView95()
    case .button:
      ButtonCatalogView95()
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
    }
  }
}

#Preview("Catalog") {
  CatalogView()
}
