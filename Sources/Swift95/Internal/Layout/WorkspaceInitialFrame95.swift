import CoreGraphics

enum WorkspaceInitialFrame95 {
  static func frame(
    index: Int,
    workspaceSize: CGSize,
    configuration: WorkspaceConfiguration95
  ) -> CGRect {
    let width = min(
      max(
        workspaceSize.width * configuration.initialWindowWidthFraction,
        configuration.initialWindowMinimumSize.width
      ),
      configuration.initialWindowMaximumSize.width
    )
    let height = min(
      max(
        workspaceSize.height * configuration.initialWindowHeightFraction,
        configuration.initialWindowMinimumSize.height
      ),
      configuration.initialWindowMaximumSize.height
    )
    let cascade = CGFloat(index % configuration.cascadeCount) * configuration.cascadeStep
    let origin = CGPoint(
      x: max(
        configuration.minimumWindowOrigin.x,
        (workspaceSize.width - width) / 2
          + cascade + configuration.initialWindowCenterOffset.width
      ),
      y: max(
        configuration.minimumWindowOrigin.y,
        (workspaceSize.height - height) / 2
          + cascade + configuration.initialWindowCenterOffset.height
      )
    )
    return CGRect(origin: origin, size: CGSize(width: width, height: height))
  }
}
