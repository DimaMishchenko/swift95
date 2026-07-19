import SwiftUI

/// A multiline text editor with a sunken Swift95 input surface and functional scroll indicator.
///
/// `TextEditor95` styles SwiftUI's native `TextEditor`, observes its real content and viewport
/// geometry, hides the system indicator, and synchronizes a ``ScrollIndicator95`` with touch,
/// keyboard, and programmatic scrolling. The indicator disables itself when all text is visible.
///
/// Give the editor a height just as you would a native multiline editor:
///
/// ```swift
/// @State private var notes = ""
///
/// TextEditor95(text: $notes)
///   .frame(height: 180)
/// ```
///
/// Native editor configuration remains available through ``swiftUI(_:)``:
///
/// ```swift
/// TextEditor95(text: $notes)
///   .swiftUI { editor in
///     editor
///       .autocorrectionDisabled()
///       .textInputAutocapitalization(.sentences)
///   }
///   .frame(height: 180)
/// ```
public struct TextEditor95<Editor: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme
  @State private var scrollBridge = TextEditorScrollBridge95()

  private let editor: Editor

  /// Creates a multiline editor bound to a string.
  ///
  /// - Parameter text: The editable multiline text value.
  public init(text: Binding<String>) where Editor == TextEditor {
    editor = TextEditor(text: text)
  }

  private init(editor: Editor) {
    self.editor = editor
  }

  /// The styled multiline editor.
  public var body: some View {
    let inputBackground =
      isEnabled ? theme.colors.inputBackground : theme.colors.inputBackgroundDisabled

    HStack(spacing: 0) {
      editor
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .font(theme.fonts.body)
        .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
        .background(TextEditorScrollProbe95(bridge: scrollBridge))
        .background(inputBackground)

      ScrollIndicator95(
        contentOffset: Binding(
          get: { scrollBridge.metrics.contentOffset },
          set: { scrollBridge.scroll(to: $0) }
        ),
        contentLength: scrollBridge.metrics.contentHeight,
        viewportLength: scrollBridge.metrics.containerHeight
      )
    }
    .background(inputBackground)
    .bevel95(.sunken)
  }

  /// Applies a transformation to the embedded SwiftUI text editor.
  ///
  /// The transformed native editor continues to receive Swift95 styling and scrollbar tracking.
  ///
  /// - Parameter transform: A closure that receives the embedded text editor.
  /// - Returns: An editor containing the transformed SwiftUI control.
  public func swiftUI<ModifiedEditor: View>(
    @ViewBuilder _ transform: (Editor) -> ModifiedEditor
  ) -> TextEditor95<ModifiedEditor> {
    TextEditor95<ModifiedEditor>(editor: transform(editor))
  }
}
