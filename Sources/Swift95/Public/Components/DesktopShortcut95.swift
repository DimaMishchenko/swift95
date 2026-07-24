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

    activationGestures(
      shortcutLabel(isSelected: isSelected)
        .overlay {
          if isDragging {
            shortcutLabel(isSelected: false)
              .opacity(theme.metrics.desktopDragPreviewOpacity)
              .offset(dragTranslation)
              .allowsHitTesting(false)
          }
        },
      id: id
    )
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
    .modifier(
      DesktopShortcutKeyboardActivation95 {
        desktop.select(id)
        openShortcut()
      }
    )
  }

  @ViewBuilder
  private func activationGestures<Content: View>(
    _ content: Content,
    id: AnyHashable
  ) -> some View {
    if desktop.shortcutActivation == .doubleClick {
      content
        .onTapGesture(count: 2) {
          desktop.select(id)
          openShortcut()
        }
        .onTapGesture {
          desktop.select(id)
        }
    } else {
      content
        .onTapGesture {
          desktop.select(id)
          openShortcut()
        }
    }
  }

  private func shortcutLabel(isSelected: Bool) -> some View {
    VStack(spacing: theme.spacing.xxs) {
      icon
        .frame(width: theme.metrics.desktopIconSize, height: theme.metrics.desktopIconSize)
        .overlay {
          if isSelected {
            DesktopIconSelection(color: theme.colors.accent)
              .mask {
                icon.frame(
                  width: theme.metrics.desktopIconSize, height: theme.metrics.desktopIconSize)
              }
          }
        }

      title
        .font(theme.fonts.body)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .foregroundStyle(isSelected ? theme.colors.accentText : theme.colors.desktopText)
        .padding(.horizontal, theme.spacing.xxxs)
        .background(isSelected ? theme.colors.accent : Color.clear)
        .overlay {
          if isSelected {
            DesktopSelectionOutline(color: theme.colors.desktopSelectionOutline)
          }
        }
        .shadow(
          color: isSelected ? .clear : theme.colors.desktopTextShadow,
          radius: 0,
          x: 1,
          y: 1
        )
    }
    .frame(width: theme.metrics.desktopShortcutWidth)
    .padding(.vertical, theme.spacing.xxs)
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

private struct DesktopShortcutKeyboardActivation95: ViewModifier {
  let activate: () -> Void

  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(macOS)
      content
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(keys: [.return, .space]) { _ in
          activate()
          return .handled
        }
    #else
      content
    #endif
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
  let color: Color

  var body: some View {
    Rectangle()
      .strokeBorder(
        color,
        style: StrokeStyle(lineWidth: 1, dash: [1, 1])
      )
      .allowsHitTesting(false)
  }
}
