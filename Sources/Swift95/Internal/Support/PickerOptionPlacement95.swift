import CoreGraphics

struct PickerOptionPlacement95 {
  static func frame(
    triggerFrame: CGRect,
    contentSize: CGSize,
    bounds: CGRect,
    minimumWidth: CGFloat,
    overlap: CGFloat
  ) -> CGRect {
    let width = min(max(triggerFrame.width, minimumWidth), bounds.width)
    let x = min(max(triggerFrame.minX, bounds.minX), bounds.maxX - width)
    let below = triggerFrame.maxY - overlap
    let above = triggerFrame.minY + overlap - contentSize.height
    let y =
      contentSize.height <= bounds.maxY - below
      ? below
      : max(bounds.minY, above)

    return CGRect(
      x: x,
      y: y,
      width: width,
      height: contentSize.height
    )
  }
}
