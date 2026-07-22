#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct List95SnapshotTests {
    @Test func list95RowRenderingBranches() {
      assertSnapshot(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 8) {
            Row95 { Text95("Normal compact row") }
              .snapshotState95(style: .compact)
            Row95 { Text95("Highlighted selected row") }
              .snapshotState95(style: .compact, isHighlighted: true, isSelected: true)
            Row95 { Text95("Pressed row") }
              .snapshotState95(style: .compact, isPressed: true)
            Row95 { Text95("Checked multiple row") }
              .snapshotState95(
                style: .compact,
                isSelected: true,
                showsSelectionMark: true
              )
            Row95 { Text95("Unchecked multiple row") }
              .snapshotState95(style: .compact, showsSelectionMark: true)
          }
        },
        as: snapshotImage(height: 230)
      )
    }
  }
#endif
