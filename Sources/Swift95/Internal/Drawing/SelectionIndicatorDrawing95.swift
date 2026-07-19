import SwiftUI

struct CheckmarkDrawing95: View {
  let color: Color
  let size: CGFloat

  var body: some View {
    Canvas { context, canvasSize in
      let unit = min(canvasSize.width, canvasSize.height) / 7
      let pixels = [
        CGPoint(x: 6, y: 0),
        CGPoint(x: 5, y: 1), CGPoint(x: 6, y: 1),
        CGPoint(x: 0, y: 2), CGPoint(x: 4, y: 2), CGPoint(x: 5, y: 2),
        CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3), CGPoint(x: 3, y: 3),
        CGPoint(x: 4, y: 3),
        CGPoint(x: 0, y: 4), CGPoint(x: 1, y: 4), CGPoint(x: 2, y: 4),
        CGPoint(x: 3, y: 4),
        CGPoint(x: 1, y: 5), CGPoint(x: 2, y: 5),
        CGPoint(x: 2, y: 6)
      ]

      for pixel in pixels {
        context.fill(
          Path(
            CGRect(
              x: pixel.x * unit,
              y: pixel.y * unit,
              width: unit,
              height: unit
            )
          ),
          with: .color(color)
        )
      }
    }
    .frame(width: size, height: size)
    .accessibilityHidden(true)
  }
}

struct RadioIndicatorDrawing95: View {
  let isSelected: Bool
  let isEnabled: Bool
  let colors: Colors95

  var body: some View {
    Canvas { context, size in
      let unit = min(size.width, size.height) / 12
      for (row, pixels) in pattern.enumerated() {
        for (column, role) in pixels.enumerated() where role != "." {
          context.fill(
            Path(
              CGRect(
                x: CGFloat(column) * unit,
                y: CGFloat(row) * unit,
                width: unit,
                height: unit
              )
            ),
            with: .color(color(for: role))
          )
        }
      }
    }
    .accessibilityHidden(true)
  }

  private var pattern: [[Character]] {
    let rows = isSelected ? Self.checkedPattern : Self.uncheckedPattern
    return rows.map(Array.init)
  }

  private func color(for role: Character) -> Color {
    switch role {
    case "d":
      colors.borderDark
    case "k":
      colors.borderDarkest
    case "i":
      isEnabled ? colors.inputBackground : colors.inputBackgroundDisabled
    case "l":
      colors.background
    case "w":
      colors.borderLightest
    case "m":
      isEnabled ? colors.text : colors.textDisabled
    default:
      .clear
    }
  }

  private static let uncheckedPattern = [
    "....dddd....",
    "..ddkkkkdd..",
    ".dkkiiiikkw.",
    ".dkiiiiiilw.",
    "dkiiiiiiiilw",
    "dkiiiiiiiilw",
    "dkiiiiiiiilw",
    "dkiiiiiiiilw",
    ".dkiiiiiilw.",
    ".dlliiiillw.",
    "..wwllllww..",
    "....wwww...."
  ]

  private static let checkedPattern = [
    "....dddd....",
    "..ddkkkkdd..",
    ".dkkiiiikkw.",
    ".dkiiiiiilw.",
    "dkiiimmiiilw",
    "dkiimmmmiilw",
    "dkiimmmmiilw",
    "dkiiimmiiilw",
    ".dkiiiiiilw.",
    ".dlliiiillw.",
    "..wwllllww..",
    "....wwww...."
  ]
}
