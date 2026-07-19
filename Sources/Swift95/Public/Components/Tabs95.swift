import SwiftUI

/// A typed description of one tab in ``Tabs95``.
public struct Tab95<Value: Hashable, Label: View>: Identifiable {
  /// The value selected when the tab is activated.
  public let value: Value
  /// The tab's SwiftUI label.
  public let label: Label

  /// The value also serves as the tab's stable identity.
  public var id: Value { value }

  private let transform: (AnyView) -> AnyView

  /// Creates a tab with a custom SwiftUI label.
  public init(value: Value, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
    transform = { $0 }
  }

  private init(
    value: Value,
    label: Label,
    transform: @escaping (AnyView) -> AnyView
  ) {
    self.value = value
    self.label = label
    self.transform = transform
  }

  /// Applies SwiftUI modifiers to this tab's completed button.
  ///
  /// Use this escape hatch for per-tab accessibility, focus, identification,
  /// and keyboard configuration.
  ///
  /// ```swift
  /// Tab95("Advanced", value: Section.advanced)
  ///   .swiftUI { tab in
  ///     tab.keyboardShortcut("2", modifiers: .command)
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure that receives the styled tab button.
  /// - Returns: A tab that applies the transformation when displayed.
  public func swiftUI<ModifiedTab: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedTab
  ) -> Tab95<Value, Label> {
    Tab95<Value, Label>(
      value: value,
      label: label,
      transform: { tab in
        AnyView(transform(self.transform(tab)))
      }
    )
  }

  func transformed(_ tab: AnyView) -> AnyView {
    transform(tab)
  }
}

extension Tab95 where Label == Text {
  /// Creates a tab with a localized text label.
  public init(_ titleKey: LocalizedStringKey, value: Value) {
    self.init(value: value) {
      Text(titleKey)
    }
  }

  /// Creates a tab with an unlocalized text label.
  public init<S>(_ title: S, value: Value) where S: StringProtocol {
    self.init(value: value) {
      Text(verbatim: String(title))
    }
  }
}

/// A classic tab strip and content panel driven by a typed selection binding.
///
/// ```swift
/// Tabs95(
///   selection: $section,
///   tabs: [
///     Tab95("General", value: .general),
///     Tab95("Advanced", value: .advanced)
///   ]
/// ) { section in
///   settingsView(for: section)
/// }
/// ```
public struct Tabs95<Value: Hashable, Label: View, Content: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.theme95) private var theme
  @Binding private var selection: Value

  private let tabs: [Tab95<Value, Label>]
  private let content: (Value) -> Content

  /// Creates a tab container.
  ///
  /// - Parameters:
  ///   - selection: The currently selected tab value.
  ///   - tabs: The ordered tab descriptions.
  ///   - content: Content for the current selection.
  public init(
    selection: Binding<Value>,
    tabs: [Tab95<Value, Label>],
    @ViewBuilder content: @escaping (Value) -> Content
  ) {
    _selection = selection
    self.tabs = tabs
    self.content = content
  }

  /// The classic tab strip and selected content.
  public var body: some View {
    VStack(alignment: .leading, spacing: -2) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .bottom, spacing: Spacing95[2]) {
          ForEach(tabs) { tab in
            tabButton(tab)
          }
        }
        .padding(.horizontal, Spacing95[4])
        .padding(.top, Spacing95[2])
      }
      .scrollClipDisabled()
      .zIndex(1)

      content(selection)
        .padding(Spacing95[12])
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .bevel95(.raised)
        .zIndex(0)
    }
  }

  private func tabButton(_ tab: Tab95<Value, Label>) -> some View {
    let isSelected = selection == tab.value

    let button = Button(action: { selection = tab.value }) {
      tab.label
    }
    .buttonStyle(
      TabButtonStyle95(
        isSelected: isSelected,
        theme: theme,
        contentInsets: EdgeInsets(
          top: isSelected ? Spacing95[8] : Spacing95[6],
          leading: Spacing95[12],
          bottom: Spacing95[6],
          trailing: Spacing95[12]
        )
      )
    )
    .disabled(!isEnabled)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .zIndex(isSelected ? 1 : 0)

    return tab.transformed(AnyView(button))
  }
}

private struct TabButtonStyle95: ButtonStyle {
  let isSelected: Bool
  let theme: Theme95
  let contentInsets: EdgeInsets

  func makeBody(configuration: Configuration) -> some View {
    TabButtonStyleContent95(
      configuration: configuration,
      isSelected: isSelected,
      theme: theme,
      contentInsets: contentInsets
    )
  }
}

private struct TabButtonStyleContent95: View {
  @Environment(\.isEnabled) private var isEnabled

  let configuration: TabButtonStyle95.Configuration
  let isSelected: Bool
  let theme: Theme95
  let contentInsets: EdgeInsets

  var body: some View {
    configuration.label
      .font(theme.fonts.body)
      .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
      .padding(contentInsets)
      .background(theme.colors.background)
      .contentShape(.rect)
      .offset(x: configuration.isPressed ? 1 : 0, y: configuration.isPressed ? 1 : 0)
      .overlay {
        if configuration.isPressed {
          BevelDrawing95(colors: theme.colors, style: .sunken)
        } else if isSelected {
          ConnectedTabBevel95(colors: theme.colors)
        } else {
          BevelDrawing95(colors: theme.colors, style: .raised)
        }
      }
  }
}

private struct ConnectedTabBevel95: View {
  let colors: Colors95

  var body: some View {
    Canvas { context, size in
      strokeOpenEdge(
        in: &context,
        size: size,
        inset: 0.5,
        topLeading: colors.borderLightest,
        trailing: colors.borderDarkest
      )
      strokeOpenEdge(
        in: &context,
        size: size,
        inset: 1.5,
        topLeading: colors.borderLight,
        trailing: colors.borderDark
      )
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }

  private func strokeOpenEdge(
    in context: inout GraphicsContext,
    size: CGSize,
    inset: CGFloat,
    topLeading: Color,
    trailing: Color
  ) {
    var topLeadingPath = Path()
    topLeadingPath.move(to: CGPoint(x: inset, y: size.height))
    topLeadingPath.addLine(to: CGPoint(x: inset, y: inset))
    topLeadingPath.addLine(to: CGPoint(x: size.width - inset, y: inset))
    context.stroke(topLeadingPath, with: .color(topLeading), lineWidth: 1)

    var trailingPath = Path()
    trailingPath.move(to: CGPoint(x: size.width - inset, y: size.height))
    trailingPath.addLine(to: CGPoint(x: size.width - inset, y: inset))
    context.stroke(trailingPath, with: .color(trailing), lineWidth: 1)
  }
}
