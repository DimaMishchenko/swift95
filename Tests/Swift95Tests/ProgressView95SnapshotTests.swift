#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct ProgressView95SnapshotTests {
    @Test func indeterminateProgressFixedPhase() {
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 12) {
            Text95("Indeterminate — fixed phase")
            IndeterminateProgressDrawing95(
              color: Theme95.classic.colors.accent,
              phase: 0.35
            )
            .frame(height: Theme95.classic.metrics.progressBarHeight)
            .bevel95(.input)
          }
        },
        as: snapshotImage(height: 130)
      )
    }
  }
#endif
