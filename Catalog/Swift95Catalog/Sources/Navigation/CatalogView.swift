import Swift95
import SwiftUI

struct CatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var selection: CatalogDestination?

  var body: some View {
    NavigationSplitView {
      List95(catalogSections, selection: $selection, style: .largeIcon) { section in
        Text95(section.id.title)
      } rowContent: { destination in
        NavigationLink {
          CatalogDestinationView(destination: destination)
            .onAppear {
              selection = destination
            }
        } label: {
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
        .navigationLinkIndicatorVisibility(.hidden)
      }
      .navigationTitle("Swift95")
    } detail: {
      if let selection {
        CatalogDestinationView(destination: selection)
      } else {
        ContentUnavailableView(
          "Select an element",
          systemImage: "rectangle.grid.1x2"
        )
      }
    }
    .tint(theme.colors.accent)
  }

  private var catalogSections: [List95.Section<CatalogSection, CatalogDestination>] {
    CatalogSection.allCases.map { section in
      List95.Section(id: section, items: section.destinations)
    }
  }
}

private enum CatalogSection: String, CaseIterable, Identifiable {
  case components
  case foundations

  var id: Self { self }

  var title: String {
    switch self {
    case .components: "Components"
    case .foundations: "Foundations"
    }
  }

  var destinations: [CatalogDestination] {
    CatalogDestination.allCases.filter { $0.section == self }
  }
}

private enum CatalogDestination: String, CaseIterable, Identifiable {
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
      .progressView, .picker, .tabs:
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
    case .bevel: "square.3.layers.3d"
    case .typography: "textformat.size"
    case .colors: "paintpalette"
    case .spacing: "arrow.left.and.right"
    case .metrics: "ruler"
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
