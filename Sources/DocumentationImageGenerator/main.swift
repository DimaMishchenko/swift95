import AppKit
import Swift95
import SwiftUI

@main
@MainActor
struct DocumentationImageGenerator {
  static func main() throws {
    let arguments = CommandLine.arguments
    guard arguments.count == 2 else {
      throw GeneratorError.usage
    }

    let outputDirectory = URL(fileURLWithPath: arguments[1], isDirectory: true)
    try FileManager.default.createDirectory(
      at: outputDirectory,
      withIntermediateDirectories: true
    )

    try render(
      "radiobutton95-group-macos.png",
      size: CGSize(width: 360, height: 146),
      to: outputDirectory
    ) {
      VStack(alignment: .leading, spacing: 6) {
        RadioButton95("Automatic", value: RadioChoice.automatic, selection: .constant(.automatic))
        RadioButton95("Manual", value: RadioChoice.manual, selection: .constant(.automatic))
        RadioButton95("Ask every time", value: RadioChoice.ask, selection: .constant(.automatic))
      }
    }

    try render(
      "checkbox95-states-macos.png",
      size: CGSize(width: 360, height: 146),
      to: outputDirectory
    ) {
      VStack(alignment: .leading, spacing: 6) {
        Checkbox95("Show hidden files", isOn: .constant(true))
        Checkbox95("Confirm before deleting", isOn: .constant(false))
        Checkbox95("Unavailable option", isOn: .constant(true))
          .disabled(true)
      }
    }

    try render(
      "textfield95-compact-macos.png",
      size: CGSize(width: 420, height: 76),
      to: outputDirectory
    ) {
      TextField95("Name", text: .constant("Jane Doe"))
        .frame(width: 380)
    }

    try render(
      "securefield95-compact-macos.png",
      size: CGSize(width: 420, height: 76),
      to: outputDirectory
    ) {
      SecureField95("Password", text: .constant("windows95"))
        .frame(width: 380)
    }

    try render(
      "picker95-compact-macos.png",
      size: CGSize(width: 420, height: 78),
      to: outputDirectory
    ) {
      Picker95(
        "Sort by",
        selection: .constant(SortOrder.name),
        options: [
          PickerOption95("Name", value: SortOrder.name),
          PickerOption95("Date modified", value: SortOrder.dateModified)
        ]
      )
      .frame(width: 380)
    }

    try render(
      "progressview95-variants-macos.png",
      size: CGSize(width: 420, height: 216),
      to: outputDirectory
    ) {
      VStack(alignment: .leading, spacing: 14) {
        ProgressView95("Continuous", value: 0.42)
        ProgressView95("Segmented", value: 0.68, barStyle: .segmented)
        ProgressView95("Searching…")
      }
      .frame(width: 380)
    }

    try render(
      "text95-states-macos.png",
      size: CGSize(width: 320, height: 104),
      to: outputDirectory
    ) {
      VStack(alignment: .leading, spacing: 10) {
        Text95("Ready")
        Text95("Unavailable")
          .disabled(true)
      }
    }

    try render(
      "list95-compact-macos.png",
      size: CGSize(width: 420, height: 252),
      to: outputDirectory
    ) {
      List95(
        (1...12).map { ListItem(id: $0, title: "Item \($0)") },
        selection: .constant(Set([2, 4])),
        style: .compact
      ) { item in
        Row95 { Text95(item.title) }
      }
      .frame(width: 380, height: 212)
    }

    try render(
      "tabs95-compact-macos.png",
      size: CGSize(width: 460, height: 184),
      to: outputDirectory
    ) {
      Tabs95(
        selection: .constant(TabSection.general),
        tabs: [
          Tab95("General", value: TabSection.general),
          Tab95("Display", value: TabSection.display),
          Tab95("Advanced", value: TabSection.advanced)
        ]
      ) { selected in
        Text95(selected.title)
          .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
      }
      .frame(width: 420)
    }

    try render(
      "divider95-context-macos.png",
      size: CGSize(width: 460, height: 104),
      to: outputDirectory
    ) {
      VStack(alignment: .leading, spacing: 10) {
        Text95("General")
        Divider95()
        Text95("Advanced")
      }
      .frame(width: 420)
    }

    try render(
      "image95-symbol-macos.png",
      size: CGSize(width: 160, height: 130),
      to: outputDirectory
    ) {
      Image95(
        Image(systemName: "photo").resizable(),
        isPixelated: false
      )
      .scaledToFit()
      .padding(18)
      .frame(width: 120, height: 90)
    }
  }

  private static func render<Content: View>(
    _ name: String,
    size: CGSize,
    to outputDirectory: URL,
    @ViewBuilder content: () -> Content
  ) throws {
    let view = content()
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: .topLeading
      )
      .padding(20)
      .background(Theme95.classic.colors.background)
      .theme95(.classic)
      .environment(\.locale, Locale(identifier: "en_US_POSIX"))
      .environment(\.colorScheme, .light)
      .environment(\.layoutDirection, .leftToRight)
      .transaction { transaction in
        transaction.disablesAnimations = true
      }
      .frame(width: size.width, height: size.height)

    let hostingView = NSHostingView(rootView: view)
    hostingView.frame = CGRect(origin: .zero, size: size)

    guard
      let representation = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
      )
    else {
      throw GeneratorError.render(name)
    }

    let window = NSWindow(
      contentRect: hostingView.frame,
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    window.isReleasedWhenClosed = false
    window.contentView = hostingView
    hostingView.layoutSubtreeIfNeeded()
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
    hostingView.layoutSubtreeIfNeeded()

    representation.size = size
    hostingView.cacheDisplay(in: hostingView.bounds, to: representation)

    guard let data = representation.representation(using: .png, properties: [:]) else {
      throw GeneratorError.render(name)
    }

    let destination = outputDirectory.appendingPathComponent(name)
    try data.write(to: destination, options: .atomic)
    window.contentView = nil
    print("\(name): \(Int(size.width))×\(Int(size.height))")
  }
}

private enum RadioChoice: Hashable {
  case automatic
  case manual
  case ask
}

private enum SortOrder: Hashable {
  case name
  case dateModified
}

private struct ListItem: Identifiable {
  let id: Int
  let title: String
}

private enum TabSection: String, Hashable {
  case general = "General"
  case display = "Display"
  case advanced = "Advanced"

  var title: String { rawValue }
}

private enum GeneratorError: Error, CustomStringConvertible {
  case render(String)
  case usage

  var description: String {
    switch self {
    case let .render(name):
      "Could not render \(name)"
    case .usage:
      "Usage: DocumentationImageGenerator <output-directory>"
    }
  }
}
