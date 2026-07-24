#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct PressedControlSnapshotTests {
    @Test func deterministicPressedStates() {
      let theme = Theme95.classic
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 14) {
            Button("Pressed button") {}
              .buttonStyle(
                ButtonStyle95(
                  theme: theme,
                  contentInsets: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
                  forcedPressed: true
                )
              )

            Button("Pressed picker") {}
              .buttonStyle(PickerTriggerButtonStyle95(theme: theme, forcedPressed: true))

            Button("Pressed option") {}
              .buttonStyle(
                PickerOptionButtonStyle95(
                  pressedOption: .constant(Optional<Int>.none),
                  isSelected: false,
                  value: 1,
                  theme: theme,
                  forcedPressed: true
                )
              )

            Button("Pressed tab") {}
              .buttonStyle(
                TabButtonStyle95(
                  isSelected: false,
                  theme: theme,
                  contentInsets: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
                  forcedPressed: true
                )
              )
          }
        },
        as: snapshotImage(height: 280)
      )
    }
  }
#endif
