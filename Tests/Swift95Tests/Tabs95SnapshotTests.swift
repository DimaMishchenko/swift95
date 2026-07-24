#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Tabs95SnapshotTests {
    @Test func tabsDisabledAndOverflowing() {
      let tabs = (1...8).map { Tab95("Tab \($0)", value: $0) }
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 16) {
            Tabs95(selection: .constant(1), tabs: tabs) { value in
              Text95("Selected tab \(value)")
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
            }
            Tabs95(selection: .constant(2), tabs: Array(tabs.prefix(3))) { value in
              Text95("Disabled tab \(value)")
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
            }
            .disabled(true)
          }
        },
        as: snapshotImage(height: 330)
      )
    }
  }
#endif
