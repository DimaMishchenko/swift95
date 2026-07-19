import Swift95
import SwiftUI

struct BevelCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Bevel") {
      CatalogExample95("Raised") {
        Rectangle()
          .fill(theme.colors.background)
          .frame(width: 160, height: 72)
          .bevel95(.raised)
      }

      CatalogExample95("Sunken") {
        Rectangle()
          .fill(theme.colors.inputBackground)
          .frame(width: 160, height: 72)
          .bevel95(.sunken)
      }
    }
  }
}

struct TypographyCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Typography") {
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

struct ColorsCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Colors") {
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

  private var colorTokens: [ColorToken95] {
    let colors = theme.colors
    return [
      .init("background", "#C3C7CB", colors.background),
      .init("text", "#000000", colors.text),
      .init("textInverted", "#FFFFFF", colors.textInverted),
      .init("textDisabled", "#868A8E", colors.textDisabled),
      .init("textDisabledHighlight", "#D2D2D2", colors.textDisabledHighlight),
      .init("accent", "#000E7A", colors.accent),
      .init("accentText", "#FEFEFE", colors.accentText),
      .init("link", "#000E7A", colors.link),
      .init("linkVisited", "#440381", colors.linkVisited),
      .init("inputBackground", "#FFFFFF", colors.inputBackground),
      .init("inputBackgroundDisabled", "#D2D2D2", colors.inputBackgroundDisabled),
      .init("inactiveBackground", "#7F787F", colors.inactiveBackground),
      .init("inactiveText", "#C6C6C6", colors.inactiveText),
      .init("borderDarkest", "#000000", colors.borderDarkest),
      .init("borderDark", "#868A8E", colors.borderDark),
      .init("borderLight", "#D2D2D2", colors.borderLight),
      .init("borderLighter", "#E6E6E6", colors.borderLighter),
      .init("borderLightest", "#FFFFFF", colors.borderLightest)
    ]
  }
}

struct SpacingCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Spacing") {
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

struct MetricsCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Metrics") {
      Grid(alignment: .leading, horizontalSpacing: Spacing95[12], verticalSpacing: Spacing95[6]) {
        metricRow("bevelWidth", theme.metrics.bevelWidth)
        metricRow("checkboxSize", theme.metrics.checkboxSize)
        metricRow("radioButtonSize", theme.metrics.radioButtonSize)
        metricRow("scrollBarWidth", theme.metrics.scrollBarWidth)
        metricRow("progressBarHeight", theme.metrics.progressBarHeight)
        metricRow("titleBarHeight", theme.metrics.titleBarHeight)
        metricRow("taskbarHeight", theme.metrics.taskbarHeight)
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
}
