#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Slider95SnapshotTests {
    @Test func sliderBoundaryStates() {
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 16) {
            Slider95(value: .constant(0.0), in: 0...1) { Text("Minimum") }
            Slider95(value: .constant(1.0), in: 0...1) { Text("Maximum") }
            Slider95(value: .constant(0.0), in: 0...0) { Text("Zero-length range") }
          }
        },
        as: snapshotImage(height: 230)
      )
    }
  }
#endif
