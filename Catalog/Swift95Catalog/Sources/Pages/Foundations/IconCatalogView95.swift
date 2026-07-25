import Swift95
import Swift95Icons
import SwiftUI

struct IconCatalogView95: View {
  @Environment(\.theme95) private var theme
  @State private var query = ""

  var body: some View {
    CatalogPage95("Swift95Icons") {
      TextField95("Filter icons", text: $query)

      Text95("\(filteredIcons.count) icons")
        .accessibilityRespondsToUserInteraction(false)

      LazyVGrid(
        columns: [
          GridItem(
            .adaptive(minimum: 136, maximum: 192),
            spacing: theme.spacing.m,
            alignment: .top
          )
        ],
        alignment: .leading,
        spacing: theme.spacing.m
      ) {
        ForEach(filteredIcons, id: \.self) { name in
          iconCell(name)
        }
      }
    }
  }

  private var filteredIcons: [Icon95.Name] {
    Icon95.Name.allCases
      .filter { name in
        query.isEmpty
          || name.identifier.localizedStandardContains(query)
          || name.rawValue.localizedStandardContains(query)
      }
      .sorted {
        $0.identifier.localizedCaseInsensitiveCompare($1.identifier) == .orderedAscending
      }
  }

  private func iconCell(_ name: Icon95.Name) -> some View {
    VStack(spacing: theme.spacing.m) {
      Icon95(name)
        .accessibilityHidden(true)

      Text95(".\(name.identifier)")
        .swiftUI { text in
          text
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
    }
    .padding(theme.spacing.m)
    .frame(maxWidth: .infinity, minHeight: 88, alignment: .top)
    .bevel95(.raised)
    .accessibilityElement(children: .combine)
  }
}

#Preview("Icons") {
  IconCatalogView95()
    .theme95(.classic)
}
