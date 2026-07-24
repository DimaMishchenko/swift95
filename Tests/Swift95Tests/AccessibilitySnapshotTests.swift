#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct AccessibilitySnapshotTests {
    @Test func accessibilityDynamicTypeMatrix() {
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 18) {
            Text95("Accessibility text")
            Button95("Accessibility button") {}
            Checkbox95("Accessibility checkbox", isOn: .constant(true))
            RadioButton95("Accessibility radio", value: 1, selection: .constant(1))
            Slider95(value: .constant(0.5)) { Text("Accessibility slider") }
            TextField95("Field", text: .constant("Accessibility field"))
            snapshotPicker(selection: .name)
            Tabs95(
              selection: .constant(SnapshotTab.general),
              tabs: [
                Tab95("General", value: .general),
                Tab95("Advanced settings", value: .advanced)
              ]
            ) { value in
              Text95(value.title)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
            }
          }
          .dynamicTypeSize(.accessibility5)
        },
        as: snapshotImage(height: 1000)
      )
    }

    @Test func rightToLeftAndLongContent() {
      assertSnapshot95(
        of: snapshotCanvas {
          VStack(alignment: .leading, spacing: 14) {
            Button95("A long localized button title") {}
            Checkbox95("A long localized checkbox label", isOn: .constant(true))
            RadioButton95(
              "A long localized radio-button label",
              value: 1,
              selection: .constant(1)
            )
            snapshotPicker(selection: .dateModified)
            TextField95("Localized field", text: .constant("Long localized content"))
          }
          .environment(\.layoutDirection, .rightToLeft)
        },
        as: snapshotImage(height: 330)
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

  private enum SnapshotTab: Hashable {
    case general
    case advanced

    var title: String {
      switch self {
      case .general: "General"
      case .advanced: "Advanced settings"
      }
    }
  }

  private enum SnapshotPickerChoice: Hashable {
    case name
    case dateModified

    static var options: [PickerOption95<SnapshotPickerChoice, Text>] {
      [
        PickerOption95("Name", value: .name),
        PickerOption95("Date modified", value: .dateModified)
      ]
    }
  }
#endif
