import Swift95
import SwiftUI

struct TextCatalogView95: View {
  var body: some View {
    CatalogPage95("Text95") {
      Text95("Body text")
      Text95("Underlined through SwiftUI")
        .swiftUI { text in
          text.underline()
        }
      Text95("Disabled text")
        .disabled(true)
    }
  }
}

struct ButtonCatalogView95: View {
  @State private var count = 0

  var body: some View {
    CatalogPage95("Button95") {
      Button95("Clicked \(count) times") {
        count += 1
      }

      Button95("Disabled") {}
        .disabled(true)

      Button95(action: {}) {
        Label("Custom label", systemImage: "square.and.pencil")
      }
      .swiftUI { button in
        button.accessibilityHint("A custom SwiftUI label")
      }
    }
  }
}

struct SliderCatalogView95: View {
  @State private var volume = 45.0
  @State private var brightness = 6.0

  var body: some View {
    CatalogPage95("Slider95") {
      CatalogExample95("Continuous") {
        Slider95(value: $volume, in: 0...100) {
          Text("Volume: \(Int(volume))")
        }
      }

      CatalogExample95("Stepped") {
        Slider95(value: $brightness, in: 0...10, step: 1) {
          Text("Brightness: \(Int(brightness))")
        }
      }

      CatalogExample95("Disabled") {
        Slider95(value: .constant(35.0), in: 0...100)
          .disabled(true)
      }
    }
  }
}

struct TextFieldCatalogView95: View {
  @State private var name = "Jane Doe"

  var body: some View {
    CatalogPage95("TextField95") {
      TextField95("Name", text: $name)
        .swiftUI { field in
          field.textInputAutocapitalization(.words)
        }

      TextField95("Disabled field", text: .constant("Read only"))
        .disabled(true)
    }
  }
}

struct SecureFieldCatalogView95: View {
  @State private var password = "windows95"

  var body: some View {
    CatalogPage95("SecureField95") {
      SecureField95("Password", text: $password)
        .swiftUI { field in
          field.textContentType(.password)
        }

      SecureField95("Disabled password", text: .constant("windows95"))
        .disabled(true)
    }
  }
}

struct TextEditorCatalogView95: View {
  @State private var notes = (1...20).map { "Line \($0)" }.joined(separator: "\n")
  @State private var shortNotes = "Content fits without scrolling"

  var body: some View {
    CatalogPage95("TextEditor95") {
      CatalogExample95("Scrollable") {
        TextEditor95(text: $notes)
          .swiftUI { editor in
            editor.autocorrectionDisabled()
          }
          .frame(height: 140)
      }

      CatalogExample95("Content fits") {
        TextEditor95(text: $shortNotes)
          .frame(height: 140)
      }
    }
  }
}

struct ScrollIndicatorCatalogView95: View {
  @Environment(\.theme95) private var theme
  @State private var contentOffset = CGFloat.zero

  private let contentLength = CGFloat(720)
  private let viewportLength = CGFloat(180)

  var body: some View {
    CatalogPage95("ScrollIndicator95") {
      HStack(alignment: .top, spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(1...30, id: \.self) { line in
            Text("Line \(line)")
              .font(theme.fonts.body)
              .frame(height: 24)
          }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .offset(y: -contentOffset)

        ScrollIndicator95(
          contentOffset: $contentOffset,
          contentLength: contentLength,
          viewportLength: viewportLength,
          lineIncrement: 24
        )
      }
      .frame(height: viewportLength, alignment: .top)
      .clipped()
      .bevel95(.input)

      Text("Offset: \(contentOffset.formatted())")
        .font(theme.fonts.body)
    }
  }
}

struct ScrollViewCatalogView95: View {
  var body: some View {
    CatalogPage95("ScrollView95") {
      CatalogExample95("Scrollable") {
        ScrollView95(lineIncrement: 32) {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(1...24, id: \.self) { line in
              Text95("Line \(line)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing95[6])
                .frame(height: 32)
            }
          }
        }
        .frame(height: 200)
      }

      CatalogExample95("Content fits") {
        ScrollView95 {
          Text95("No scrolling required")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing95[6])
        }
        .frame(height: 80)
      }
    }
  }
}

struct DividerCatalogView95: View {
  var body: some View {
    CatalogPage95("Divider95") {
      CatalogExample95("Horizontal") {
        VStack(alignment: .leading, spacing: Spacing95[8]) {
          Text95("Above")
          Divider95()
          Text95("Below")
        }
      }

      CatalogExample95("Vertical") {
        HStack(spacing: Spacing95[8]) {
          Text95("Leading")
          Divider95(.vertical)
          Text95("Trailing")
        }
        .frame(height: 48)
      }
    }
  }
}

struct CheckboxCatalogView95: View {
  @State private var isChecked = true
  @State private var acceptsUpdates = false

  var body: some View {
    CatalogPage95("Checkbox95") {
      Checkbox95("Checked", isOn: $isChecked)

      Checkbox95("Accept automatic updates", isOn: $acceptsUpdates)
        .swiftUI { toggle in
          toggle.accessibilityHint("Downloads updates automatically")
        }

      Checkbox95("Disabled checked", isOn: .constant(true))
        .disabled(true)

      Checkbox95("Disabled unchecked", isOn: .constant(false))
        .disabled(true)
    }
  }
}

struct RadioButtonCatalogView95: View {
  @State private var selection = RadioSelection95.automatic

  var body: some View {
    CatalogPage95("RadioButton95") {
      VStack(alignment: .leading, spacing: Spacing95[10]) {
        RadioButton95("Automatic", value: .automatic, selection: $selection)
        RadioButton95("Manual", value: .manual, selection: $selection)
        RadioButton95("Custom", value: .custom, selection: $selection)

        RadioButton95(
          "Disabled selected",
          value: RadioSelection95.unavailable,
          selection: .constant(RadioSelection95.unavailable)
        )
        .disabled(true)

        RadioButton95(
          "Disabled unselected",
          value: RadioSelection95.unavailable,
          selection: .constant(RadioSelection95.automatic)
        )
        .disabled(true)
      }

      Text95("Selection: \(selection.title)")
    }
  }
}

struct ProgressViewCatalogView95: View {
  var body: some View {
    CatalogPage95("ProgressView95") {
      CatalogExample95("Determinate") {
        ProgressView95("Installing", value: 42, total: 100)
      }

      CatalogExample95("Determinate segmented") {
        ProgressView95(
          "Copying files",
          value: 60,
          total: 100,
          barStyle: .segmented
        )
      }

      CatalogExample95("Complete") {
        ProgressView95(value: 1)
      }

      CatalogExample95("Indeterminate") {
        ProgressView95("Searching")
      }

      CatalogExample95("Disabled") {
        ProgressView95("Installing", value: 65, total: 100)
          .disabled(true)
      }
    }
  }
}

struct PickerCatalogView95: View {
  @State private var sortOrder = SortOrder95.name

  var body: some View {
    CatalogPage95("Picker95") {
      CatalogExample95("Picker95") {
        Picker95(
          "Sort by",
          selection: $sortOrder,
          options: SortOrder95.options
        )
      }

      CatalogExample95("Disabled") {
        Picker95(
          "Disabled",
          selection: .constant(SortOrder95.name),
          options: SortOrder95.options
        )
        .disabled(true)
      }

      Text95("Selection: \(sortOrder.title)")
    }
  }
}

struct TabsCatalogView95: View {
  @State private var selection = SettingsTab95.general

  var body: some View {
    CatalogPage95("Tabs95") {
      Tabs95(
        selection: $selection,
        tabs: [
          Tab95("General", value: SettingsTab95.general),
          Tab95("Display", value: SettingsTab95.display),
          Tab95("Advanced", value: SettingsTab95.advanced)
        ]
      ) { tab in
        VStack(alignment: .leading, spacing: Spacing95[8]) {
          Text95(tab.title)
          Text95(tab.description)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
      }
    }
  }
}

private enum SortOrder95: Hashable {
  case name
  case dateModified
  case size

  static var options: [PickerOption95<SortOrder95, Text>] {
    [
      PickerOption95("Name", value: SortOrder95.name),
      PickerOption95("Date modified", value: SortOrder95.dateModified),
      PickerOption95("Size", value: SortOrder95.size)
    ]
  }

  var title: String {
    switch self {
    case .name: "Name"
    case .dateModified: "Date modified"
    case .size: "Size"
    }
  }
}

private enum SettingsTab95: Hashable {
  case general
  case display
  case advanced

  var title: String {
    switch self {
    case .general: "General"
    case .display: "Display"
    case .advanced: "Advanced"
    }
  }

  var description: String {
    switch self {
    case .general: "Common application settings."
    case .display: "Appearance and layout settings."
    case .advanced: "Settings for experienced users."
    }
  }
}

private enum RadioSelection95: Hashable {
  case automatic
  case manual
  case custom
  case unavailable

  var title: String {
    switch self {
    case .automatic: "Automatic"
    case .manual: "Manual"
    case .custom: "Custom"
    case .unavailable: "Unavailable"
    }
  }
}
