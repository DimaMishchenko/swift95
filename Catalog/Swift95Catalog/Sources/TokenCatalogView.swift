import Swift95
import SwiftUI

struct TokenCatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var selection: CatalogElement95?

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        ForEach(CatalogCategory95.allCases) { category in
          Section(category.title) {
            ForEach(category.elements) { element in
              NavigationLink(value: element) {
                Text(element.title)
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
        CatalogElementView95(element: selection)
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

private enum CatalogCategory95: String, CaseIterable, Identifiable {
  case components
  case foundations

  var id: Self { self }

  var title: String {
    switch self {
    case .components: "Components"
    case .foundations: "Foundations"
    }
  }

  var elements: [CatalogElement95] {
    CatalogElement95.allCases.filter { $0.category == self }
  }
}

enum CatalogElement95: String, CaseIterable, Identifiable {
  case text
  case button
  case textField
  case secureField
  case textEditor
  case scrollIndicator
  case bevel
  case typography
  case colors
  case spacing
  case metrics

  var id: Self { self }

  fileprivate var category: CatalogCategory95 {
    switch self {
    case .text, .button, .textField, .secureField, .textEditor, .scrollIndicator:
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
    case .bevel: "Bevel"
    case .typography: "Typography"
    case .colors: "Colors"
    case .spacing: "Spacing"
    case .metrics: "Metrics"
    }
  }
}

private struct CatalogElementView95: View {
  let element: CatalogElement95

  var body: some View {
    switch element {
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
  TokenCatalogView()
}
