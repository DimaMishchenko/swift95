import SwiftUI

struct PixelCaret95: View {
  let color: Color

  var body: some View {
    Canvas { context, _ in
      for row in 0..<4 {
        let width = CGFloat(7 - row * 2)
        context.fill(
          Path(
            CGRect(
              x: CGFloat(row),
              y: CGFloat(row),
              width: width,
              height: 1
            )
          ),
          with: .color(color)
        )
      }
    }
    .frame(width: 7, height: 4)
    .accessibilityHidden(true)
  }
}
