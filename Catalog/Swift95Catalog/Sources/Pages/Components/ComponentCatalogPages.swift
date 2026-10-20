import Swift95
import Swift95Icons
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
        HStack {
          Icon95(.filePencil, size: .small)
            .accessibilityHidden(true)
          Text("Custom label")
        }
      }
      .swiftUI { button in
        button.accessibilityHint("A custom SwiftUI label")
      }
    }
  }
}

struct AlertCatalogView95: View {
  @State private var showsWarning = false
  @State private var showsInformation = false
  @State private var showsQuestion = false

  var body: some View {
    CatalogPage95("Alert95") {
      CatalogExample95("Traditional icons") {
        Button95("Warning") {
          showsWarning = true
        }

        Button95("Information") {
          showsInformation = true
        }

        Button95("Question") {
          showsQuestion = true
        }
      }

      Text95(
        """
        The icon builder accepts any SwiftUI view; these examples use traditional artwork from \
        Swift95Icons. Put native SwiftUI Buttons in the action builder. Alert95 adapts each action \
        to Button95 styling and dismisses automatically after activation.
        """
      )
    }
    .alert95(
      "Printer",
      isPresented: $showsWarning,
      icon: {
        Icon95(.warning)
      }
    ) {
      Button("OK") {}
        .keyboardShortcut(.defaultAction)
    } message: {
      Text("There is no default printer.")
    }
    .alert95(
      "Setup complete",
      isPresented: $showsInformation,
      icon: {
        Icon95(.infoBubble)
      }
    ) {
      Button("Continue") {}
        .keyboardShortcut(.defaultAction)
    }
    .alert95(
      "Replace file?",
      isPresented: $showsQuestion,
      isCloseButtonEnabled: false,
      icon: {
        Icon95(.questionBubble)
      }
    ) {
      Button("Replace", role: .destructive) {}
        .keyboardShortcut(.defaultAction)
      Button("Cancel", role: .cancel) {}
        .keyboardShortcut(.cancelAction)
    } message: {
      Text("A file with this name already exists.")
    }
  }
}

struct ImageCatalogView95: View {
  @Environment(\.catalogLaunchConfiguration) private var launchConfiguration
  @Environment(\.theme95) private var theme

  private let remoteImageURL = URL(
    string: "https://picsum.photos/id/119/640/480"
  )

  var body: some View {
    CatalogPage95("Image95") {
      CatalogExample95("Metal pixelation") {
        HStack(alignment: .top, spacing: theme.spacing.xl) {
          shaderExample("Enabled", isPixelated: true)
          shaderExample("Disabled", isPixelated: false)
        }
      }

      Text95(
        "Pixelation is enabled by default. Set isPixelated to false to preserve the original image."
      )

      CatalogExample95("Async image") {
        AsyncImage95(url: launchConfiguration.isUITesting ? nil : remoteImageURL) { phase in
          AsyncImageCatalogContent95(phase: phase)
        }
        .swiftUI { image in
          image
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipped()
        }
        .frame(maxWidth: 360)
      }
    }
  }

  private func shaderExample(
    _ title: String,
    isPixelated: Bool
  ) -> some View {
    VStack(alignment: .leading, spacing: theme.spacing.s) {
      Text95(title)

      Image95(isPixelated: isPixelated) {
        ImageShaderSample95()
      }
      .frame(maxWidth: .infinity)
      .aspectRatio(4 / 3, contentMode: .fit)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct ImageShaderSample95: View {
  var body: some View {
    Canvas { context, size in
      context.fill(
        Path(CGRect(origin: .zero, size: size)),
        with: .linearGradient(
          Gradient(colors: [.cyan, .blue, .purple, .orange]),
          startPoint: .zero,
          endPoint: CGPoint(x: size.width, y: size.height)
        )
      )

      let stripeWidth = max(size.width / 48, 1)
      for index in 0..<24 {
        let x = CGFloat(index) * stripeWidth * 2
        var stripe = Path()
        stripe.move(to: CGPoint(x: x, y: 0))
        stripe.addLine(to: CGPoint(x: x + size.height * 0.55, y: size.height))
        context.stroke(
          stripe,
          with: .color(index.isMultiple(of: 2) ? .white : .black),
          lineWidth: stripeWidth
        )
      }

      let inset = min(size.width, size.height) * 0.18
      context.fill(
        Path(
          ellipseIn: CGRect(
            x: inset,
            y: inset,
            width: size.width - inset * 2,
            height: size.height - inset * 2
          )),
        with: .color(.yellow.opacity(0.82))
      )

      context.draw(
        Text("95")
          .font(.system(size: min(size.width, size.height) * 0.38, weight: .black))
          .foregroundStyle(.black),
        at: CGPoint(x: size.width / 2, y: size.height / 2)
      )
    }
  }
}

private struct AsyncImageCatalogContent95: View {
  @Environment(\.theme95) private var theme

  let phase: AsyncImagePhase

  var body: some View {
    if let image = phase.image {
      image
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    } else if phase.error != nil {
      placeholder(icon: .warning, label: "Image unavailable")
    } else {
      placeholder(icon: .time, label: "Loading image")
    }
  }

  private func placeholder(icon: Icon95.Name, label: String) -> some View {
    VStack(spacing: theme.spacing.m) {
      Icon95(icon, size: .large)
        .accessibilityHidden(true)
      Text95(label)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme95.classic.colors.background)
  }
}

struct SliderCatalogView95: View {
  @State private var volume = 45.0
  @State private var brightness = 6.0
  @State private var disabledVolume = 35.0

  var body: some View {
    CatalogPage95("Slider95") {
      CatalogExample95("Continuous") {
        Slider95(value: $volume, in: 0...100) {
          Text("Volume: \(Int(volume))")
        }
        .accessibilityIdentifier("catalog.slider.continuous")
      }

      CatalogExample95("Stepped") {
        Slider95(value: $brightness, in: 0...10, step: 1) {
          Text("Brightness: \(Int(brightness))")
        }
        .accessibilityIdentifier("catalog.slider.stepped")
      }

      CatalogExample95("Disabled") {
        Slider95(value: $disabledVolume, in: 0...100)
          .disabled(true)
          .accessibilityIdentifier("catalog.slider.disabled")
      }

      CatalogExample95("Right-to-left") {
        Slider95(value: $volume, in: 0...100) {
          Text("Volume: \(Int(volume))")
        }
        .environment(\.layoutDirection, .rightToLeft)
        .accessibilityIdentifier("catalog.slider.rtl")
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
          #if os(iOS)
            field.textInputAutocapitalization(.words)
          #else
            field
          #endif
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
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("ScrollView95") {
      CatalogExample95("Scrollable") {
        ScrollView95(lineIncrement: 32) {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(1...24, id: \.self) { line in
              Text95("Line \(line)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, theme.spacing.s)
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
            .padding(theme.spacing.s)
        }
        .frame(height: 80)
      }
    }
  }
}

struct ListCatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var example = ListCatalogExample.largeIcon
  @State private var selectedItem: CatalogListItem.ID? = CatalogListItem.documents.id
  @State private var selectedActions: Set<CatalogListItem.ID> = [
    CatalogListItem.view.id,
    CatalogListItem.refresh.id
  ]

  var body: some View {
    CatalogPage95("List95") {
      Picker95(
        "Example",
        selection: $example,
        options: ListCatalogExample.options
      )

      CatalogExample95(example.title) {
        exampleContent
      }
    }
  }

  @ViewBuilder
  private var exampleContent: some View {
    switch example {
    case .largeIcon:
      List95(CatalogListItem.largeItems, style: .largeIcon) { item in
        Row95 {
          Icon95(item.icon)
            .accessibilityHidden(true)
        } label: {
          Text95(item.title)
        } accessory: {
          item.hasChildren
        }
      }
      .frame(height: 400)

    case .compact:
      List95(CatalogListItem.actions, style: .compact) { item in
        Row95 { Text95(item.title) }
      }
      .frame(height: 260)

    case .selected:
      VStack(alignment: .leading, spacing: theme.spacing.m) {
        List95(
          CatalogListItem.largeItems,
          selection: $selectedItem,
          style: .largeIcon
        ) { item in
          Row95 {
            Icon95(item.icon)
              .accessibilityHidden(true)
          } label: {
            Text95(item.title)
          }
        }
        .frame(height: 360)

        Text95("Selected: \(selectedItem?.rawValue ?? "None")")
      }

    case .multipleSelection:
      List95(
        CatalogListItem.actions,
        selection: $selectedActions,
        style: .compact
      ) { item in
        Row95 { Text95(item.title) }
      }
      .frame(height: 300)

    case .disabled:
      List95(CatalogListItem.largeItems, style: .largeIcon) { item in
        Row95 {
          Icon95(item.icon)
            .accessibilityHidden(true)
        } label: {
          Text95(item.title)
        }
      }
      .disabled(true)
      .frame(height: 360)

    case .separators:
      List95(CatalogListItem.actions, style: .compact) { item in
        Row95 { Text95(item.title) }
          .separator(item.hasSeparatorAfter)
      }
      .frame(height: 260)

    case .childrenAndAccessories:
      List95(CatalogListItem.accessoryItems, style: .largeIcon) { item in
        if item.hasChildren {
          Row95 {
            Icon95(item.icon)
              .accessibilityHidden(true)
          } label: {
            Text95(item.title)
          } accessory: {
            true
          }
        } else {
          Row95 {
            Icon95(item.icon)
              .accessibilityHidden(true)
          } label: {
            Text95(item.title)
          } accessory: {
            Icon95(.tick, size: .small)
              .accessibilityHidden(true)
          }
        }
      }
      .frame(height: 280)

    case .overflowing:
      List95(CatalogListItem.overflowItems, style: .compact) { item in
        Row95 { Text95(item.title) }
      }
      .frame(height: 400)
    }
  }
}

struct DividerCatalogView95: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    CatalogPage95("Divider95") {
      CatalogExample95("Horizontal") {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
          Text95("Above")
          Divider95()
          Text95("Below")
        }
      }

      CatalogExample95("Vertical") {
        HStack(spacing: theme.spacing.m) {
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
  @Environment(\.theme95) private var theme

  @State private var selection = RadioSelection95.automatic

  var body: some View {
    CatalogPage95("RadioButton95") {
      VStack(alignment: .leading, spacing: theme.spacing.l) {
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

      CatalogExample95("Right-to-left") {
        Picker95(
          "Sort by",
          selection: $sortOrder,
          options: SortOrder95.options.map { option in
            option.swiftUI { row in
              row.accessibilityIdentifier("catalog.picker.rtl.\(option.value.title)")
            }
          }
        )
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
        .accessibilityIdentifier("catalog.picker.rtl")
      }

      Text95("Selection: \(sortOrder.title)")
        .accessibilityIdentifier("catalog.picker.selection")
    }
  }
}

struct TabsCatalogView95: View {
  @Environment(\.theme95) private var theme

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
        VStack(alignment: .leading, spacing: theme.spacing.m) {
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

private enum ListCatalogExample: String, CaseIterable, Identifiable {
  case largeIcon
  case compact
  case selected
  case multipleSelection
  case disabled
  case separators
  case childrenAndAccessories
  case overflowing

  var id: Self { self }

  static var options: [PickerOption95<Self, Text>] {
    allCases.map { PickerOption95($0.title, value: $0) }
  }

  var title: String {
    switch self {
    case .largeIcon: "Large icon"
    case .compact: "Compact"
    case .selected: "Selected"
    case .multipleSelection: "Multiple selection"
    case .disabled: "Disabled"
    case .separators: "Separators"
    case .childrenAndAccessories: "Children and accessories"
    case .overflowing: "Overflowing"
    }
  }
}

private struct CatalogListItem: Identifiable {
  struct ID: Hashable, RawRepresentable {
    let rawValue: String
  }

  let id: ID
  let title: String
  let icon: Icon95.Name
  let hasChildren: Bool
  let hasSeparatorAfter: Bool

  static let programs = item("Programs", icon: .shellProgramsFolder, hasChildren: true)
  static let documents = item("Documents", icon: .shellDocumentsFolder, hasChildren: true)
  static let settings = item("Settings", icon: .shellSettings, hasChildren: true)
  static let find = item("Find", icon: .shellFind)
  static let help = item("Help", icon: .shellHelp)
  static let run = item("Run", icon: .shellRun)
  static let view = item("View", hasSeparatorAfter: true)
  static let customize = item("Customize this folder", hasSeparatorAfter: true)
  static let arrange = item("Arrange Icons")
  static let lineUp = item("Line Up Icons")
  static let refresh = item("Refresh", hasSeparatorAfter: true)
  static let paste = item("Paste")
  static let pasteShortcut = item("Paste shortcut")
  static let undoCopy = item("Undo Copy")
  static let new = item("New", hasSeparatorAfter: true)
  static let properties = item("Properties")

  static let largeItems = [programs, documents, settings, find, help, run]
  static let actions = [
    view,
    customize,
    arrange,
    lineUp,
    refresh,
    paste,
    pasteShortcut,
    undoCopy,
    new,
    properties
  ]
  static let accessoryItems = [programs, settings, refresh]
  static let overflowItems = (1...40).map { item("List item \($0)") }

  private static func item(
    _ title: String,
    icon: Icon95.Name = .document,
    hasChildren: Bool = false,
    hasSeparatorAfter: Bool = false
  ) -> CatalogListItem {
    CatalogListItem(
      id: ID(rawValue: title),
      title: title,
      icon: icon,
      hasChildren: hasChildren,
      hasSeparatorAfter: hasSeparatorAfter
    )
  }
}
