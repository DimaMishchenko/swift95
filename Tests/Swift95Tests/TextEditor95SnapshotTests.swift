#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct TextEditor95SnapshotTests {
    @Test func textEditorContentFitAndOverflow() {
      assertSnapshot(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 12) {
            TextEditor95(text: .constant("Content fits without scrolling"))
              .frame(height: 90)
            TextEditor95(
              text: .constant((1...20).map { "Overflow line \($0)" }.joined(separator: "\n"))
            )
            .frame(height: 130)
          }
        },
        as: snapshotImage(height: 290)
      )
    }
  }
#endif
