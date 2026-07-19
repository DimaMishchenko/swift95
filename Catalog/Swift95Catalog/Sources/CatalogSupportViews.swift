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

struct ColorToken95: Identifiable {
  let name: String
  let hex: String
  let color: Color

  var id: String { name }

  init(_ name: String, _ hex: String, _ color: Color) {
    self.name = name
    self.hex = hex
    self.color = color
  }
}

struct ColorTokenView95: View {
  @Environment(\.theme95) private var theme
  let token: ColorToken95

  var body: some View {
    HStack(spacing: Spacing95[8]) {
      token.color
        .frame(width: 36, height: 36)
        .overlay {
          Rectangle()
            .stroke(theme.colors.borderDarkest, lineWidth: 1)
        }

      VStack(alignment: .leading, spacing: Spacing95[2]) {
        Text(token.name)
          .font(theme.fonts.body)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
        Text(token.hex)
          .font(theme.fonts.body)
          .foregroundStyle(theme.colors.textDisabled)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
