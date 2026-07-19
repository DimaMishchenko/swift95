import Swift95
import SwiftUI

struct CatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var selection: CatalogDestination?

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        ForEach(CatalogSection.allCases) { section in
          Section(section.title) {
            ForEach(section.destinations) { destination in
              NavigationLink(value: destination) {
                Text(destination.title)
                  .font(theme.fonts.body)
              }
            }
          }
        }
      }
      .navigationTitle("Swift95")
      .scrollContentBackground(.hidden)
      .background(theme.colors.background)
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
  case textField
  case secureField
  case textEditor
  case scrollIndicator
  case divider
  case checkbox
  case radioButton
  case progressView
  case bevel
  case typography
  case colors
  case spacing
  case metrics

  var id: Self { self }

  var section: CatalogSection {
    switch self {
    case .text, .button, .textField, .secureField, .textEditor, .scrollIndicator,
      .divider, .checkbox, .radioButton, .progressView:
      .components
    case .bevel, .typography, .colors, .spacing, .metrics:
      .foundations
    }
  }

  var title: String {
    switch self {
    case .text: "Text95"
    case .button: "Button95"
    case .textField: "TextField95"
    case .secureField: "SecureField95"
    case .textEditor: "TextEditor95"
    case .scrollIndicator: "ScrollIndicator95"
    case .divider: "Divider95"
    case .checkbox: "Checkbox95"
    case .radioButton: "RadioButton95"
    case .progressView: "ProgressView95"
    case .bevel: "Bevel"
    case .typography: "Typography"
    case .colors: "Colors"
    case .spacing: "Spacing"
    case .metrics: "Metrics"
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
    case .textField:
      TextFieldCatalogView95()
    case .secureField:
      SecureFieldCatalogView95()
    case .textEditor:
      TextEditorCatalogView95()
    case .scrollIndicator:
      ScrollIndicatorCatalogView95()
    case .divider:
      DividerCatalogView95()
    case .checkbox:
      CheckboxCatalogView95()
    case .radioButton:
      RadioButtonCatalogView95()
    case .progressView:
      ProgressViewCatalogView95()
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
