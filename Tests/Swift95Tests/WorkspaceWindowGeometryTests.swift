import CoreGraphics
import Testing

@testable import Swift95

@Test func retainedWindowFrameIsNormalizedWhenTheWorkspaceShrinks() {
  let frame = WorkspaceWindowGeometry.normalizedFrame(
    CGRect(x: 700, y: 500, width: 620, height: 520),
    workspaceSize: CGSize(width: 500, height: 400)
  )

  #expect(frame == CGRect(x: 0, y: 0, width: 500, height: 400))
}

@Test func windowResizeIsLimitedByRemainingWorkspaceSpace() {
  let size = WorkspaceWindowGeometry.constrainedResizeSize(
    CGSize(width: 500, height: 500),
    origin: CGPoint(x: 300, y: 250),
    workspaceSize: CGSize(width: 600, height: 500)
  )

  #expect(size == CGSize(width: 300, height: 250))
}

@Test func windowGeometryUsesPerWindowMinimumSize() {
  let minimum = CGSize(width: 410, height: 330)

  let frame = WorkspaceWindowGeometry.normalizedFrame(
    CGRect(x: 20, y: 30, width: 100, height: 100),
    workspaceSize: CGSize(width: 800, height: 600),
    minimumSize: minimum
  )

  #expect(frame == CGRect(x: 20, y: 30, width: 410, height: 330))
}

@Test func initialWindowPlacementUsesWorkspaceConfiguration() {
  let configuration = WorkspaceConfiguration95(
    initialWindowWidthFraction: 0.5,
    initialWindowHeightFraction: 0.5,
    initialWindowMinimumSize: CGSize(width: 100, height: 100),
    initialWindowMaximumSize: CGSize(width: 1_000, height: 1_000),
    cascadeCount: 3,
    cascadeStep: 10,
    initialWindowCenterOffset: .zero,
    minimumWindowOrigin: .zero
  )

  let frame = WorkspaceInitialFrame95.frame(
    index: 2,
    workspaceSize: CGSize(width: 800, height: 600),
    configuration: configuration
  )

  #expect(frame == CGRect(x: 220, y: 170, width: 400, height: 300))
}
