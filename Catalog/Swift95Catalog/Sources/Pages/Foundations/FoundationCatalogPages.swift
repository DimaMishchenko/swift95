import Swift95
import SwiftUI

struct BevelCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Bevel") {
      CatalogExample95("Raised") {
        Color.clear
          .frame(width: 160, height: 72)
          .bevel95(.raised)
      }

      CatalogExample95("Sunken") {
        Color.clear
          .frame(width: 160, height: 72)
          .bevel95(.sunken)
      }

      CatalogExample95("Input") {
        Color.clear
          .frame(width: 160, height: 72)
          .bevel95(.input)
      }

      CatalogExample95("Raised with accent background") {
        Color.clear
          .frame(width: 160, height: 72)
          .bevel95(.raised, background: theme.colors.accent)
      }

      CatalogExample95("Raised + sunken") {
        Color.clear
          .frame(width: 152, height: 64)
          .bevel95(.raisedSunken)
      }

      CatalogExample95("Raised + input, 8-point spacing") {
        Color.clear
          .frame(width: 152, height: 64)
          .bevel95(.raisedInput, spacing: theme.spacing.m)
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
    }
  }
}

struct ColorsCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Colors") {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 150), spacing: theme.spacing.m)],
        spacing: theme.spacing.m
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
      .init("workspaceBackground", "#008080", colors.workspaceBackground),
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
      Grid(
        alignment: .leading,
        horizontalSpacing: theme.spacing.xl,
        verticalSpacing: theme.spacing.s
      ) {
        spacingRow("xxxs", theme.spacing.xxxs)
        spacingRow("xxs", theme.spacing.xxs)
        spacingRow("xs", theme.spacing.xs)
        spacingRow("s", theme.spacing.s)
        spacingRow("m", theme.spacing.m)
        spacingRow("l", theme.spacing.l)
        spacingRow("xl", theme.spacing.xl)
        spacingRow("xxl", theme.spacing.xxl)
      }
      .font(theme.fonts.body)
    }
  }

  private func spacingRow(_ name: String, _ value: CGFloat) -> some View {
    GridRow {
      Text(name)
      Text(value.formatted())
        .frame(width: 32, alignment: .trailing)
      Rectangle()
        .fill(theme.colors.accent)
        .frame(width: max(1, value * 5), height: theme.spacing.m)
    }
  }
}

struct MetricsCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Metrics") {
      Grid(
        alignment: .leading,
        horizontalSpacing: theme.spacing.xl,
        verticalSpacing: theme.spacing.s
      ) {
        metricRow("bevelWidth", theme.metrics.bevelWidth)
        metricRow("checkboxSize", theme.metrics.checkboxSize)
        metricRow("radioButtonSize", theme.metrics.radioButtonSize)
        metricRow("scrollBarWidth", theme.metrics.scrollBarWidth)
        metricRow("scrollThumbMinimumLength", theme.metrics.scrollThumbMinimumLength)
        metricRow("scrollLineIncrementMinimum", theme.metrics.scrollLineIncrementMinimum)
        metricRow("progressBarHeight", theme.metrics.progressBarHeight)
        metricRow("titleBarHeight", theme.metrics.titleBarHeight)
        metricRow("compactTitleBarHeight", theme.metrics.compactTitleBarHeight)
        metricRow("taskbarHeight", theme.metrics.taskbarHeight)
        metricRow("taskbarItemHeight", theme.metrics.taskbarItemHeight)
        metricRow("pressedContentOffset", theme.metrics.pressedContentOffset)
        metricRow("progressContentInset", theme.metrics.progressContentInset)
        metricRow("tabStripOverlap", theme.metrics.tabStripOverlap)
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
