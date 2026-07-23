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
      VStack(alignment: .leading, spacing: theme.spacing.xxl) {
        content
      }
      .frame(maxWidth: 720, alignment: .leading)
      .padding(theme.spacing.xxl)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .catalogNavigationTitle(title)
    .background(theme.colors.background.ignoresSafeArea())
    .foregroundStyle(theme.colors.text)
  }
}

extension View {
  @ViewBuilder
  func catalogNavigationTitle(_ title: String) -> some View {
    #if os(macOS)
      self
    #else
      navigationTitle(title)
    #endif
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
    VStack(alignment: .leading, spacing: theme.spacing.m) {
      Text(title)
        .font(theme.fonts.title3)
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
