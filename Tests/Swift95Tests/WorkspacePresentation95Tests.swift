import CoreGraphics
import Testing

@testable import Swift95

@Test func automaticWorkspacePresentationRequiresRoomForWindowChrome() {
  #expect(
    WorkspacePresentation95.automatic.resolved(for: CGSize(width: 599, height: 800)) == .compact
  )
  #expect(
    WorkspacePresentation95.automatic.resolved(for: CGSize(width: 800, height: 479)) == .compact
  )
  #expect(
    WorkspacePresentation95.automatic.resolved(for: CGSize(width: 600, height: 480)) == .windowed
  )
}
