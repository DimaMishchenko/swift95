import Swift95
import SwiftUI

struct TextCatalogView95: View {
  var body: some View {
    CatalogPage95("Text95") {
      Text95("Body text")
      Text95("Native kerning")
        .swiftUI { text in
          text.kerning(1)
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
      HStack(spacing: 0) {
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
      .background(theme.colors.inputBackground)
      .clipped()
      .bevel95(.sunken)

      Text("Offset: \(contentOffset.formatted())")
        .font(theme.fonts.body)
    }
  }
}
