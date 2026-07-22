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
