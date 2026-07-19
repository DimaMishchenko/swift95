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
  private let indicatorTransform: (AnyView) -> AnyView

  /// Creates a multiline editor bound to a string.
  ///
  /// - Parameter text: The editable multiline text value.
  public init(text: Binding<String>) where Editor == TextEditor {
    editor = TextEditor(text: text)
    indicatorTransform = { $0 }
  }

  /// Creates a multiline editor with a bindable native text selection.
  ///
  /// Use the selection binding to inspect or change the insertion point and
  /// selected ranges while preserving the Swift95 surface and scroll indicator.
  ///
  /// - Parameters:
  ///   - text: The editable multiline text value.
  ///   - selection: The native SwiftUI text selection.
  public init(
    text: Binding<String>,
    selection: Binding<TextSelection?>
  ) where Editor == TextEditor {
    editor = TextEditor(text: text, selection: selection)
    indicatorTransform = { $0 }
  }

  private init(
    editor: Editor,
    indicatorTransform: @escaping (AnyView) -> AnyView
  ) {
    self.editor = editor
    self.indicatorTransform = indicatorTransform
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

      indicatorTransform(
        AnyView(
          ScrollIndicator95(
            contentOffset: Binding(
              get: { scrollBridge.metrics.contentOffset },
              set: { scrollBridge.scroll(to: $0) }
            ),
            contentLength: scrollBridge.metrics.contentHeight,
            viewportLength: scrollBridge.metrics.containerHeight
          )
        )
      )
    }
    .bevel95(.input, background: inputBackground)
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
    TextEditor95<ModifiedEditor>(
      editor: transform(editor),
      indicatorTransform: indicatorTransform
    )
  }

  /// Applies SwiftUI modifiers to the connected classic scroll indicator.
  ///
  /// ```swift
  /// TextEditor95(text: $notes)
  ///   .swiftUIIndicator { indicator in
  ///     indicator.accessibilityIdentifier("notes-scrollbar")
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure that receives ``ScrollIndicator95``
  ///   after it has been connected to the editor's native scroll position.
  /// - Returns: An editor that applies the indicator transformation.
  public func swiftUIIndicator<ModifiedIndicator: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedIndicator
  ) -> TextEditor95<Editor> {
    TextEditor95<Editor>(
      editor: editor,
      indicatorTransform: { indicator in
        AnyView(transform(self.indicatorTransform(indicator)))
      }
    )
  }
}
