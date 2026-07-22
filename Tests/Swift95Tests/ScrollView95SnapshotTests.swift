#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct ScrollView95SnapshotTests {
    @Test func scrollIndicator95() {
      assertSnapshot(
        of: snapshotCanvas {
          HStack(alignment: .top, spacing: 24) {
            ScrollIndicator95(
              contentOffset: .constant(240),
              contentLength: 720,
              viewportLength: 180,
              lineIncrement: 24
            )
            .frame(height: 180)

            ScrollIndicator95(
              contentOffset: .constant(0),
              contentLength: 100,
              viewportLength: 180
            )
            .frame(height: 180)
          }
        },
        as: snapshotImage(height: 230)
      )
    }

    @Test func scrollView95() {
      assertSnapshot(
        of: snapshotCanvas {
          HStack(alignment: .top, spacing: 16) {
            ScrollView95(lineIncrement: 28) {
              LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(1...10, id: \.self) { line in
                  Text95("Line \(line)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 28)
                }
              }
            }
            .frame(height: 150)

            ScrollView95 {
              Text95("Content fits")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            .frame(height: 80)
          }
        },
        as: snapshotImage(height: 210)
      )
    }
  }
#endif
