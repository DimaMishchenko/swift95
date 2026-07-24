#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Picker95SnapshotTests {
    @Test func pickerDisabledAndOptionStates() {
      let picker = snapshotPicker(selection: .name)
      let longPicker = Picker95(
        "Long picker",
        selection: .constant(SnapshotPickerChoice.option1),
        options: SnapshotPickerChoice.longOptions
      )

      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 16) {
            picker.disabled(true)
            picker.snapshotOptionList95(selection: .name, theme: .classic)
              .frame(width: 240)
            longPicker.snapshotOptionList95(selection: .option1, theme: .classic)
              .frame(width: 240, height: 280)
          }
        },
        as: snapshotImage(height: 500)
      )
    }

    @Test func pickerPresentationBelowAndAbove() {
      let options = snapshotPicker(selection: .dateModified)
        .snapshotOptionList95(selection: .dateModified, theme: .classic)

      assertSnapshot95(
        of: snapshotCanvas {
          ZStack(alignment: .topLeading) {
            PickerOptionPresentationLayout95(
              triggerFrame: CGRect(x: 20, y: 30, width: 220, height: 32),
              overlap: 2
            ) {
              options
            }
          }
          .frame(width: 342, height: 360)
        },
        as: snapshotImage(height: 420),
        named: "below"
      )

      assertSnapshot95(
        of: snapshotCanvas {
          ZStack(alignment: .topLeading) {
            PickerOptionPresentationLayout95(
              triggerFrame: CGRect(x: 20, y: 310, width: 220, height: 32),
              overlap: 2
            ) {
              options
            }
          }
          .frame(width: 342, height: 360)
        },
        as: snapshotImage(height: 420),
        named: "above"
      )
    }

    private func snapshotPicker(
      selection: SnapshotPickerChoice
    ) -> Picker95<SnapshotPickerChoice, Text, AnyView> {
      Picker95(
        "Sort by",
        selection: .constant(selection),
        options: SnapshotPickerChoice.options
      )
    }
  }

  private enum SnapshotPickerChoice: Int, Hashable, CaseIterable {
    case name
    case dateModified
    case size
    case option1
    case option2
    case option3
    case option4
    case option5
    case option6
    case option7
    case option8
    case option9

    static var options: [PickerOption95<SnapshotPickerChoice, Text>] {
      [
        PickerOption95("Name", value: .name),
        PickerOption95("Date modified", value: .dateModified),
        PickerOption95("Size", value: .size)
      ]
    }

    static var longOptions: [PickerOption95<SnapshotPickerChoice, Text>] {
      (option1.rawValue...option9.rawValue).compactMap(Self.init(rawValue:))
        .enumerated()
        .map { offset, value in
          PickerOption95("Option \(offset + 1)", value: value)
        }
    }
  }
#endif
