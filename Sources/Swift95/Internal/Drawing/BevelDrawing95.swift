import SwiftUI

struct BevelDrawing95: View {
  let colors: Colors95
  let style: Bevel95Style

  var body: some View {
    Canvas { context, size in
      switch style {
      case .raised:
        drawEdges(
          in: &context,
          size: size,
          inset: 0.5,
          topLeading: colors.borderLightest,
          bottomTrailing: colors.borderDarkest
        )
        drawEdges(
          in: &context,
          size: size,
          inset: 1.5,
          topLeading: colors.borderLight,
          bottomTrailing: colors.borderDark
        )
      case .sunken:
        drawEdges(
          in: &context,
          size: size,
          inset: 0.5,
          topLeading: colors.borderDark,
          bottomTrailing: colors.borderLightest
        )
      case .input:
        drawEdges(
          in: &context,
          size: size,
          inset: 0.5,
          topLeading: colors.borderDarkest,
          bottomTrailing: colors.borderLightest
        )
        drawEdges(
          in: &context,
          size: size,
          inset: 1.5,
          topLeading: colors.borderDark,
          bottomTrailing: colors.borderLight
        )
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func drawEdges(
    in context: inout GraphicsContext,
    size: CGSize,
    inset: CGFloat,
    topLeading: Color,
    bottomTrailing: Color
  ) {
    strokeTopLeading(
      in: &context,
      size: size,
      inset: inset,
      color: topLeading
    )
    strokeBottomTrailing(
      in: &context,
      size: size,
      inset: inset,
      color: bottomTrailing
    )
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
