import Swift95
import SwiftUI

enum MusicStyle {
  static let navy = Color(red: 0.055, green: 0.09, blue: 0.13)
  static let panel = Color(red: 0.085, green: 0.14, blue: 0.18)
  static let green = Color(red: 0.48, green: 0.95, blue: 0.58)
  static let muted = Color(red: 0.62, green: 0.71, blue: 0.72)
  static let fonts = Fonts95.classic

  static var darkTheme: Theme95 {
    var theme = Theme95.classic
    theme.colors.background = panel
    theme.colors.text = .white
    theme.colors.inputBackground = navy
    theme.colors.borderLightest = Color(white: 0.35)
    theme.colors.borderLighter = Color(white: 0.29)
    theme.colors.borderLight = Color(white: 0.24)
    theme.colors.borderDark = .black
    theme.colors.borderDarkest = .black
    return theme
  }
}

struct MusicArtwork: View {
  let variant: Int

  private var tint: Color {
    switch variant % 4 {
    case 1: Color(red: 0.96, green: 0.67, blue: 0.59)
    case 2: MusicStyle.green
    case 3: Color(red: 1, green: 0.77, blue: 0.32)
    default: Color(red: 0.65, green: 0.55, blue: 0.92)
    }
  }

  var body: some View {
    GeometryReader { geometry in
      let size = geometry.size.width
      ZStack {
        MusicStyle.navy
        Canvas { context, canvas in
          let unit = canvas.width / 24
          for row in 0..<24 {
            for column in 0..<24 {
              let isSky = row < 15
              let checker = (column + row) % 2 == 0
              let rect = CGRect(
                x: CGFloat(column) * unit, y: CGFloat(row) * unit, width: unit, height: unit)
              if isSky && checker {
                context.fill(Path(rect), with: .color(tint.opacity(0.09)))
              }
              if row >= 15 && row % 3 == 0 {
                context.fill(Path(rect), with: .color(tint.opacity(0.35)))
              }
              if variant % 4 == 2 && (column * 7 + row * 3) % 11 < 3 {
                context.fill(
                  Path(rect.insetBy(dx: unit / 4, dy: unit / 4)), with: .color(tint.opacity(0.5)))
              }
            }
          }
          let sun = CGRect(
            x: canvas.width * 0.24, y: canvas.height * 0.17, width: canvas.width * 0.52,
            height: canvas.height * 0.52)
          context.fill(Path(ellipseIn: sun), with: .color(tint))
          for stripe in 0..<6 {
            let y = sun.midY + CGFloat(stripe) * unit
            context.fill(
              Path(
                CGRect(
                  x: 0, y: y, width: canvas.width,
                  height: unit * 0.35 + CGFloat(stripe) * unit * 0.08)),
              with: .color(MusicStyle.navy))
          }
          var road = Path()
          road.move(to: CGPoint(x: canvas.width * 0.48, y: canvas.height * 0.68))
          road.addLine(to: CGPoint(x: canvas.width * 0.14, y: canvas.height))
          road.addLine(to: CGPoint(x: canvas.width * 0.88, y: canvas.height))
          road.addLine(to: CGPoint(x: canvas.width * 0.52, y: canvas.height * 0.68))
          road.closeSubpath()
          context.fill(road, with: .color(MusicStyle.navy))
          for index in 0..<4 {
            let y = canvas.height * (0.72 + Double(index) * 0.08)
            context.fill(
              Path(
                CGRect(
                  x: canvas.width * 0.495, y: y, width: max(1, Double(index) * 1.5),
                  height: Double(index + 1) * 2)), with: .color(tint))
          }
        }
        VStack {
          HStack {
            Text(["NIGHT / 01", "SOFT / 02", "DATA / 03", "SUN / 04"][variant % 4])
              .font(MusicStyle.fonts.font(size: max(7, size * 0.062)))
            Spacer(minLength: 0)
          }
          Spacer()
          HStack {
            Spacer(minLength: 0)
            Text("STEREO")
              .font(MusicStyle.fonts.font(size: max(6, size * 0.05)))
          }
        }
        .foregroundStyle(tint)
        .padding(size * 0.07)
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .clipped()
    .accessibilityHidden(true)
  }
}
