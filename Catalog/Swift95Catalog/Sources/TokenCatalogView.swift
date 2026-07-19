import Swift95
import SwiftUI

struct TokenCatalogView: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: Spacing95[20]) {
        header
        fontSection
        colorSection
        spacingSection
        metricsSection
      }
      .padding(Spacing95[16])
    }
    .scrollIndicators(.visible)
    .background(theme.colors.background.ignoresSafeArea())
    .foregroundStyle(theme.colors.text)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: Spacing95[4]) {
      Text("swift-95")
        .font(theme.fonts.title2)
      Text("Initial token catalog")
        .font(theme.fonts.body)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(Spacing95[8])
    .foregroundStyle(theme.colors.accentText)
    .background(theme.colors.accent)
  }

  private var fontSection: some View {
    CatalogSection95("W95FA") {
      VStack(alignment: .leading, spacing: Spacing95[8]) {
        Text("Title")
          .font(theme.fonts.title)
        Text("Title 2")
          .font(theme.fonts.title2)
        Text("Title 3")
          .font(theme.fonts.title3)
        Text("The quick brown fox jumps over the lazy dog.")
          .font(theme.fonts.body)
        Text("18-point bold, relative to body")
          .font(theme.fonts.font(size: 18, weight: .bold, relativeTo: .body))
        Text("12-point fixed size")
          .font(theme.fonts.font(size: 12))
      }
    }
  }

  private var colorSection: some View {
    CatalogSection95("Colors95.classic") {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 150), spacing: Spacing95[8])],
        spacing: Spacing95[8]
      ) {
        ForEach(colorTokens) { token in
          ColorTokenView95(token: token)
        }
      }
    }
  }

  private var spacingSection: some View {
    CatalogSection95("Spacing95[0...24]") {
      VStack(alignment: .leading, spacing: Spacing95[4]) {
        ForEach(Array(Spacing95.initialRange), id: \.self) { value in
          HStack(spacing: Spacing95[8]) {
            Text("\(value)")
              .font(theme.fonts.body)
              .frame(width: 24, alignment: .trailing)

            Rectangle()
              .fill(theme.colors.accent)
              .frame(width: max(1, Spacing95[value] * 5), height: 8)
          }
        }
      }
    }
  }

  private var metricsSection: some View {
    CatalogSection95("Metrics95.classic") {
      Grid(alignment: .leading, horizontalSpacing: Spacing95[12], verticalSpacing: Spacing95[6]) {
        metricRow("bevelWidth", theme.metrics.bevelWidth)
        metricRow("checkboxSize", theme.metrics.checkboxSize)
        metricRow("radioButtonSize", theme.metrics.radioButtonSize)
        metricRow("scrollBarWidth", theme.metrics.scrollBarWidth)
        metricRow("progressBarHeight", theme.metrics.progressBarHeight)
        metricRow("titleBarHeight", theme.metrics.titleBarHeight)
        metricRow("taskbarHeight", theme.metrics.taskbarHeight)
        metricRow("minimumTouchTarget", theme.metrics.minimumTouchTarget)
      }
      .font(theme.fonts.body)
    }
  }

  private func metricRow(_ name: String, _ value: CGFloat) -> some View {
    GridRow {
      Text(name)
      Text(value.formatted())
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }

  private var colorTokens: [ColorToken95] {
    let colors = theme.colors
    return [
      .init("link", "#000E7A", colors.link),
      .init("linkVisited", "#440381", colors.linkVisited),
      .init("accent", "#000E7A", colors.accent),
      .init("accentText", "#FEFEFE", colors.accentText),
      .init("background", "#C3C7CB", colors.background),
      .init("text", "#000000", colors.text),
      .init("textDisabled", "#868A8E", colors.textDisabled),
      .init("textDisabledHighlight", "#D2D2D2", colors.textDisabledHighlight),
      .init("textInverted", "#FFFFFF", colors.textInverted),
      .init("borderDark", "#868A8E", colors.borderDark),
      .init("borderDarkest", "#000000", colors.borderDarkest),
      .init("borderLight", "#D2D2D2", colors.borderLight),
      .init("borderLighter", "#E6E6E6", colors.borderLighter),
      .init("borderLightest", "#FFFFFF", colors.borderLightest),
      .init("inactiveBackground", "#7F787F", colors.inactiveBackground),
      .init("inactiveText", "#C6C6C6", colors.inactiveText),
      .init("inputBackground", "#FFFFFF", colors.inputBackground),
      .init("inputBackgroundDisabled", "#D2D2D2", colors.inputBackgroundDisabled),
    ]
  }
}

private struct CatalogSection95<Content: View>: View {
  @Environment(\.theme95) private var theme

  private let title: String
  private let content: Content

  init(_ title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[10]) {
      Text(title)
        .font(theme.fonts.title3)
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(Spacing95[12])
    .background(theme.colors.background)
    .overlay(alignment: .topLeading) {
      Rectangle()
        .stroke(theme.colors.borderLightest, lineWidth: theme.metrics.bevelWidth)
    }
    .overlay(alignment: .bottomTrailing) {
      Rectangle()
        .stroke(theme.colors.borderDarkest, lineWidth: theme.metrics.bevelWidth)
        .offset(x: theme.metrics.bevelWidth, y: theme.metrics.bevelWidth)
    }
  }
}

private struct ColorToken95: Identifiable {
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

private struct ColorTokenView95: View {
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

#Preview("Classic tokens") {
  TokenCatalogView()
}
