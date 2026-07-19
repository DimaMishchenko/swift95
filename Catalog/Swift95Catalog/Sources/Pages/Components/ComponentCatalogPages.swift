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
