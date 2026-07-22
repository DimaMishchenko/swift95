import CoreGraphics

enum WorkspaceWindowGeometry {
  static func normalizedFrame(
    _ frame: CGRect,
    workspaceSize: CGSize,
    minimumSize: CGSize = CGSize(width: 280, height: 200)
  ) -> CGRect {
    let availableWidth = max(0, workspaceSize.width)
    let availableHeight = max(0, workspaceSize.height)
    let minimumWidth = min(minimumSize.width, availableWidth)
    let minimumHeight = min(minimumSize.height, availableHeight)
    let width = min(max(minimumWidth, frame.width), availableWidth)
    let height = min(max(minimumHeight, frame.height), availableHeight)
    let origin = CGPoint(
      x: min(max(frame.minX, 0), max(0, availableWidth - width)),
      y: min(max(frame.minY, 0), max(0, availableHeight - height))
    )

    return CGRect(origin: origin, size: CGSize(width: width, height: height))
  }

  static func constrainedResizeSize(
    _ size: CGSize,
    origin: CGPoint,
    workspaceSize: CGSize,
    minimumSize: CGSize = CGSize(width: 280, height: 200)
  ) -> CGSize {
    let boundedOrigin = CGPoint(
      x: min(max(origin.x, 0), max(0, workspaceSize.width)),
      y: min(max(origin.y, 0), max(0, workspaceSize.height))
    )
    let availableWidth = max(0, workspaceSize.width - boundedOrigin.x)
    let availableHeight = max(0, workspaceSize.height - boundedOrigin.y)
    let minimumWidth = min(minimumSize.width, availableWidth)
    let minimumHeight = min(minimumSize.height, availableHeight)

    return CGSize(
      width: min(max(minimumWidth, size.width), availableWidth),
      height: min(max(minimumHeight, size.height), availableHeight)
    )
  }
}
