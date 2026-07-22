import SwiftUI

/// A desktop icon that opens or focuses a workspace window route.
///
/// Place shortcuts inside ``Desktop95`` and use the same route values handled by the enclosing
/// ``Workspace95``.
///
/// ```swift
/// DesktopShortcut95("Notes", value: App.notes) {
///   Image95("notes")
/// }
/// ```
public struct DesktopShortcut95<Route: Hashable, Icon: View>: View {
  @State private var dragTranslation = CGSize.zero
  @State private var isDragging = false

  @Environment(\.desktopContext) private var desktop
  @Environment(\.dismissStartMenu) private var dismissStartMenu
  @Environment(\.openWorkspaceWindow95) private var openWindow
  @Environment(\.theme95) private var theme

  private let title: Text
  private let value: Route
  private let icon: Icon

  /// Creates a desktop shortcut with a localized title.
  public init(
    _ titleKey: LocalizedStringKey,
    value: Route,
    @ViewBuilder icon: () -> Icon
  ) {
    title = Text(titleKey)
    self.value = value
    self.icon = icon()
  }

  /// Creates a desktop shortcut with an unlocalized title.
  public init<S: StringProtocol>(
    _ title: S,
    value: Route,
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = Text(verbatim: String(title))
    self.value = value
    self.icon = icon()
  }

  /// The icon and title button.
  public var body: some View {
    let id = AnyHashable(value)
    let isSelected = desktop.isSelected(id) || isDragging

    shortcutLabel(isSelected: isSelected)
      .overlay {
        if isDragging {
          shortcutLabel(isSelected: false)
            .opacity(0.62)
            .offset(dragTranslation)
            .allowsHitTesting(false)
        }
      }
      .onTapGesture(count: 2) {
        guard desktop.shortcutActivation == .doubleClick else { return }
        desktop.select(id)
        openShortcut()
      }
      .onTapGesture {
        desktop.select(id)
        if desktop.shortcutActivation == .singleClick {
          openShortcut()
        }
      }
      .onLongPressGesture(
        minimumDuration: 0,
        maximumDistance: .infinity,
        pressing: { isPressing in
          guard isPressing else { return }
          desktop.select(id)
        },
        perform: {}
      )
      .offset(desktop.offset(id))
      .background {
        GeometryReader { geometry in
          Color.clear.preference(
            key: DesktopShortcutFramesPreferenceKey.self,
            value: [id: geometry.frame(in: .named(DesktopCoordinateSpace.name))]
          )
        }
      }
      .simultaneousGesture(shortcutDragGesture(id: id))
      .zIndex(isDragging || isSelected ? 1 : 0)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isButton)
      .accessibilityAddTraits(isSelected ? .isSelected : [])
      .accessibilityAction {
        desktop.select(id)
        openShortcut()
      }
  }

  private func shortcutLabel(isSelected: Bool) -> some View {
    VStack(spacing: Spacing95[4]) {
      icon
        .frame(width: 42, height: 42)
        .overlay {
          if isSelected {
            DesktopIconSelection(color: theme.colors.accent)
              .mask { icon.frame(width: 42, height: 42) }
          }
        }

      title
        .font(theme.fonts.body)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .foregroundStyle(theme.colors.accentText)
        .padding(.horizontal, Spacing95[2])
        .background(isSelected ? theme.colors.accent : Color.clear)
        .overlay {
          if isSelected { DesktopSelectionOutline() }
        }
        .shadow(
          color: isSelected ? .clear : theme.colors.borderDarkest,
          radius: 0,
          x: 1,
          y: 1
        )
    }
    .frame(width: 88)
    .padding(.vertical, Spacing95[4])
    .contentShape(.rect)
  }

  private func shortcutDragGesture(id: AnyHashable) -> some Gesture {
    DragGesture(minimumDistance: 6, coordinateSpace: .named(DesktopCoordinateSpace.name))
      .onChanged { value in
        guard desktop.allowsShortcutMovement else { return }
        if !isDragging {
          isDragging = true
          desktop.select(id)
        }
        dragTranslation = desktop.boundedTranslation(id, value.translation)
      }
      .onEnded { value in
        guard desktop.allowsShortcutMovement else { return }
        let translation = desktop.resolvedTranslation(id, value.translation)
        desktop.settle(id, translation)
        dragTranslation = .zero
        isDragging = false
      }
  }

  private func openShortcut() {
    openWindow(value)
    dismissStartMenu()
  }
}

private struct DesktopIconSelection: View {
  let color: Color

  var body: some View {
    Canvas { context, size in
      let tileSize = CGFloat(2)
      let columns = Int(ceil(size.width / tileSize))
      let rows = Int(ceil(size.height / tileSize))

      for row in 0..<rows {
        for column in 0..<columns where (row + column).isMultiple(of: 2) {
          context.fill(
            Path(
              CGRect(
                x: CGFloat(column) * tileSize,
                y: CGFloat(row) * tileSize,
                width: tileSize,
                height: tileSize
              )
            ),
            with: .color(color)
          )
        }
      }
    }
    .allowsHitTesting(false)
  }
}

private struct DesktopSelectionOutline: View {
  var body: some View {
    Rectangle()
      .strokeBorder(
        Color(.sRGB, red: 1, green: 1, blue: 0, opacity: 1),
        style: StrokeStyle(lineWidth: 1, dash: [1, 1])
      )
      .allowsHitTesting(false)
  }
}
