import Swift95
import SwiftUI

struct CatalogPage95<Content: View>: View {
  @Environment(\.theme95) private var theme

  private let title: String
  private let content: Content

  init(_ title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Spacing95[16]) {
        content
      }
      .frame(maxWidth: 720, alignment: .leading)
      .padding(Spacing95[16])
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .navigationTitle(title)
    .background(theme.colors.background.ignoresSafeArea())
    .foregroundStyle(theme.colors.text)
  }
}

struct CatalogExample95<Content: View>: View {
  @Environment(\.theme95) private var theme

  private let title: String
  private let content: Content

  init(_ title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[8]) {
      Text(title)
        .font(theme.fonts.title3)
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
