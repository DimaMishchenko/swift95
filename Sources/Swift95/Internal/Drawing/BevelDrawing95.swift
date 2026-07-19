import SwiftUI

struct BevelDrawing95: View {
  let colors: Colors95
  let style: Bevel95Style

  var body: some View {
    Canvas { context, size in
      let outerTopLeading: Color
      let innerTopLeading: Color
      let outerBottomTrailing: Color
      let innerBottomTrailing: Color

      switch style {
      case .raised:
        outerTopLeading = colors.borderLightest
        innerTopLeading = colors.borderLight
        outerBottomTrailing = colors.borderDarkest
        innerBottomTrailing = colors.borderDark
      case .sunken:
        outerTopLeading = colors.borderDarkest
        innerTopLeading = colors.borderDark
        outerBottomTrailing = colors.borderLightest
        innerBottomTrailing = colors.borderLight
      }

      strokeTopLeading(
        in: &context,
        size: size,
        inset: 0.5,
        color: outerTopLeading
      )
      strokeTopLeading(
        in: &context,
        size: size,
        inset: 1.5,
        color: innerTopLeading
      )
      strokeBottomTrailing(
        in: &context,
        size: size,
        inset: 0.5,
        color: outerBottomTrailing
      )
      strokeBottomTrailing(
        in: &context,
        size: size,
        inset: 1.5,
        color: innerBottomTrailing
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func strokeTopLeading(
    in context: inout GraphicsContext,
    size: CGSize,
    inset: CGFloat,
    color: Color
  ) {
    var path = Path()
    path.move(to: CGPoint(x: inset, y: size.height - inset))
    path.addLine(to: CGPoint(x: inset, y: inset))
    path.addLine(to: CGPoint(x: size.width - inset, y: inset))
    context.stroke(path, with: .color(color), lineWidth: 1)
  }

  private func strokeBottomTrailing(
    in context: inout GraphicsContext,
    size: CGSize,
    inset: CGFloat,
    color: Color
  ) {
    var path = Path()
    path.move(to: CGPoint(x: inset, y: size.height - inset))
    path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
    path.addLine(to: CGPoint(x: size.width - inset, y: inset))
    context.stroke(path, with: .color(color), lineWidth: 1)
  }
}
