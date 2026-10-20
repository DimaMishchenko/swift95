import Swift95
import SwiftUI

struct TestLabAccessibilityView95: View {
  @State private var checkbox = true
  @State private var radio = TestRadio.automatic
  @State private var slider = 0.5
  @State private var scrollOffset = CGFloat.zero

  var body: some View {
    CatalogPage95("Accessibility") {
      Text95("Deterministic accessibility fixtures")
        .swiftUI { $0.accessibilityAddTraits(.isHeader) }

      Button95("Run action") {}
        .swiftUI { $0.accessibilityIdentifier("ui.button") }

      Checkbox95("Enable sound", isOn: $checkbox)
        .swiftUI { $0.accessibilityIdentifier("ui.checkbox") }

      RadioButton95("Automatic", value: TestRadio.automatic, selection: $radio)
        .swiftUI { $0.accessibilityIdentifier("ui.radio.automatic") }

      Slider95(value: $slider) {
        Text("Volume")
      }
      .swiftUI { $0.accessibilityIdentifier("ui.slider") }

      ScrollIndicator95(
        contentOffset: $scrollOffset,
        contentLength: 600,
        viewportLength: 200
      )
      .frame(height: 160)
      .accessibilityIdentifier("ui.scroll-indicator")
    }
    .accessibilityIdentifier("test-lab.accessibility")
  }
}

struct TestLabInteractionsView95: View {
  @State private var count = 0
  @State private var checkbox = false
  @State private var radio = TestRadio.automatic
  @State private var slider = 0.25
  @State private var text = ""
  @State private var sortOrder = TestSortOrder.name
  @State private var selectedItem: TestListItem.ID?
  @State private var selectedTab = TestTab.general
  @State private var showsAlert = false
  @State private var alertResult = "None"

  private let items = [
    TestListItem(id: "documents", title: "Documents"),
    TestListItem(id: "settings", title: "Settings")
  ]

  var body: some View {
    CatalogPage95("Interactions") {
      CatalogExample95("Actions") {
        Button95("Increment") {
          count += 1
        }
        .swiftUI { $0.accessibilityIdentifier("interaction.button") }

        Text95("Button count: \(count)")
          .accessibilityIdentifier("interaction.button.output")

        Checkbox95("Sound", isOn: $checkbox)
          .swiftUI { $0.accessibilityIdentifier("interaction.checkbox") }

        Text95("Checkbox: \(checkbox ? "On" : "Off")")
          .accessibilityIdentifier("interaction.checkbox.output")

        HStack {
          RadioButton95("Automatic", value: TestRadio.automatic, selection: $radio)
            .swiftUI { $0.accessibilityIdentifier("interaction.radio.automatic") }
          RadioButton95("Manual", value: TestRadio.manual, selection: $radio)
            .swiftUI { $0.accessibilityIdentifier("interaction.radio.manual") }
        }

        Text95("Radio: \(radio.title)")
          .accessibilityIdentifier("interaction.radio.output")
      }

      CatalogExample95("Input") {
        TextField95("Computer name", text: $text)
          .swiftUI { $0.accessibilityIdentifier("interaction.text-field") }

        Text95("Text: \(text)")
          .accessibilityIdentifier("interaction.text.output")

        Slider95(value: $slider) {
          Text("Brightness")
        }
        .swiftUI { $0.accessibilityIdentifier("interaction.slider") }

        Text95("Slider: \(Int((slider * 100).rounded()))")
          .accessibilityIdentifier("interaction.slider.output")
      }

      CatalogExample95("Selection") {
        Picker95(
          "Sort order",
          selection: $sortOrder,
          options: [
            PickerOption95("Name", value: TestSortOrder.name)
              .swiftUI { $0.accessibilityIdentifier("interaction.picker.name") },
            PickerOption95("Date modified", value: TestSortOrder.dateModified)
              .swiftUI { $0.accessibilityIdentifier("interaction.picker.date") }
          ]
        )
        .swiftUITrigger { $0.accessibilityIdentifier("interaction.picker") }

        Text95("Picker: \(sortOrder.title)")
          .accessibilityIdentifier("interaction.picker.output")

        List95(
          items,
          selection: $selectedItem,
          style: .compact,
          showsIndicator: false
        ) { item in
          Row95 {
            Text95(item.title)
          }
          .swiftUI { $0.accessibilityIdentifier("interaction.list.\(item.id)") }
        }
        .frame(height: 92)
        .accessibilityIdentifier("interaction.list")

        Text95("List: \(selectedItem ?? "None")")
          .accessibilityIdentifier("interaction.list.output")

        Tabs95(
          selection: $selectedTab,
          tabs: [
            Tab95("General", value: TestTab.general)
              .swiftUI { $0.accessibilityIdentifier("interaction.tab.general") },
            Tab95("Display", value: TestTab.display)
              .swiftUI { $0.accessibilityIdentifier("interaction.tab.display") }
          ]
        ) { tab in
          Text95("\(tab.title) settings")
            .accessibilityIdentifier("interaction.tab.content")
        }
      }

      CatalogExample95("Presentation") {
        Button95("Show alert") {
          showsAlert = true
        }
        .swiftUI { $0.accessibilityIdentifier("interaction.alert.show") }
        .alert95(
          "Confirm action",
          isPresented: $showsAlert,
          isCloseButtonEnabled: false,
          icon: {
            Image(systemName: "exclamationmark.triangle")
          }
        ) {
          Button("Confirm") {
            alertResult = "Confirmed"
          }
          .accessibilityIdentifier("interaction.alert.confirm")
          Button("Cancel", role: .cancel) {
            alertResult = "Cancelled"
          }
          .accessibilityIdentifier("interaction.alert.cancel")
        } message: {
          Text("This alert verifies modal interaction and dismissal.")
            .accessibilityIdentifier("interaction.alert.message")
        }

        Text95("Alert result: \(alertResult)")
          .accessibilityIdentifier("interaction.alert.output")
      }
    }
    .accessibilityIdentifier("test-lab.interactions")
  }
}

struct TestLabRTLControlsView95: View {
  @State private var volume = 45.0
  @State private var brightness = 6.0
  @State private var disabledVolume = 35.0
  @State private var rtlVolume = 45.0
  @State private var sortOrder = TestSortOrder.name

  var body: some View {
    CatalogPage95("RTL Controls") {
      VStack(alignment: .leading, spacing: 12) {
        Slider95(value: $volume, in: 0...100) {
          Text("Continuous: \(Int(volume))")
        }
        .accessibilityIdentifier("catalog.slider.continuous")

        Slider95(value: $brightness, in: 0...10, step: 1) {
          Text("Stepped: \(Int(brightness))")
        }
        .accessibilityIdentifier("catalog.slider.stepped")

        Slider95(value: $disabledVolume, in: 0...100) {
          Text("Disabled")
        }
        .disabled(true)
        .accessibilityIdentifier("catalog.slider.disabled")

        Slider95(value: $rtlVolume, in: 0...100) {
          Text("RTL volume: \(Int(rtlVolume))")
        }
        .environment(\.layoutDirection, .rightToLeft)
        .accessibilityIdentifier("catalog.slider.rtl")

        Picker95(
          "Sort by",
          selection: $sortOrder,
          options: [TestSortOrder.name, .dateModified, .size]
            .map { value in
              PickerOption95(value.title, value: value)
                .swiftUI { row in
                  row.accessibilityIdentifier("catalog.picker.rtl.\(value.title)")
                }
            }
        )
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
        .accessibilityIdentifier("catalog.picker.rtl")

        Text95("Selection: \(sortOrder.title)")
          .accessibilityIdentifier("catalog.picker.selection")
      }
      .frame(maxWidth: 360, alignment: .leading)
    }
    .accessibilityIdentifier("test-lab.rtl-controls")
  }
}

struct TestLabOverridesView95: View {
  @State private var scrollOffset = CGFloat.zero

  var body: some View {
    CatalogPage95("Overrides") {
      Text95("Custom library-owned strings")

      ScrollIndicator95(
        contentOffset: $scrollOffset,
        contentLength: 600,
        viewportLength: 200
      )
      .frame(height: 180)
      .accessibilityIdentifier("override.scroll-indicator")
    }
    .strings95(customStrings)
    .accessibilityIdentifier("test-lab.overrides")
  }

  private var customStrings: Strings95 {
    var strings = Strings95.localized
    strings.scrollUp = "Custom scroll up"
    strings.scrollDown = "Custom scroll down"
    strings.scrollPosition = "Custom scroll position"
    return strings
  }
}

struct TestLabWorkspaceView95: View {
  var body: some View {
    Text95("Accessible workspace content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .accessibilityIdentifier("workspace.content")
      .accessibilityRespondsToUserInteraction(false)
  }
}

struct TestLabMenuView95: View {
  let activation: String

  var body: some View {
    Text95("Menu activation: \(activation)")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .accessibilityIdentifier("menu.output")
      .accessibilityRespondsToUserInteraction(false)
  }
}

private enum TestRadio: Hashable {
  case automatic
  case manual

  var title: String {
    switch self {
    case .automatic: "Automatic"
    case .manual: "Manual"
    }
  }
}

private enum TestSortOrder: Hashable {
  case name
  case dateModified
  case size

  var title: String {
    switch self {
    case .name: "Name"
    case .dateModified: "Date modified"
    case .size: "Size"
    }
  }
}

private enum TestTab: Hashable {
  case general
  case display

  var title: String {
    switch self {
    case .general: "General"
    case .display: "Display"
    }
  }
}

private struct TestListItem: Identifiable {
  let id: String
  let title: String
}
