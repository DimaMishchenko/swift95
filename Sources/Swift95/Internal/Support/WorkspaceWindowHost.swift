import SwiftUI

struct WorkspaceWindowHost: View {
  @Environment(\.theme95) private var theme
  @Environment(\.strings95) private var strings
  @GestureState private var windowDragTranslation = CGSize.zero
  @GestureState private var windowResizeTranslation = CGSize.zero
  @State private var isDraggingWindow = false
  @State private var isResizingWindow = false
  @State private var restoredFrame: CGRect?
  @State private var presentedMenu: Int?

  let window: WorkspaceWindow95
  let isActive: Bool
  let presentation: WorkspacePresentation95
  let workspaceSize: CGSize
  @Binding var frame: CGRect
  let activate: () -> Void
  let minimize: () -> Void
  let close: () -> Void
  let configuration: WorkspaceConfiguration95

  var body: some View {
    let capabilities = window.configuration.capabilities
    let actions = WorkspaceWindowActions95(
      close: capabilities.contains(.close) ? close : {},
      minimize: capabilities.contains(.minimize) ? minimize : {}
    )
    let maximizeAction: (() -> Void)? =
      presentation == .windowed && capabilities.contains(.maximize)
      ? { toggleMaximized() } : nil

    VStack(spacing: 0) {
      WorkspaceTitleBar(
        title: window.title,
        icon: window.titleBarIcon,
        isActive: isActive,
        isCompact: presentation == .compact,
        minimize: capabilities.contains(.minimize) ? minimize : nil,
        maximize: maximizeAction,
        isMaximized: isMaximized,
        close: capabilities.contains(.close) ? close : nil
      )
      .padding(.horizontal, titleBarInset)
      .padding(.top, titleBarInset)
      .contentShape(.rect)
      .simultaneousGesture(windowDragGesture)

      if window.menus.isEmpty {
        windowContent(actions: actions)
      } else {
        ZStack(alignment: .topLeading) {
          VStack(spacing: 0) {
            Color.clear.frame(height: menuBarHeight)
            windowContent(actions: actions)
          }

          MenuBar95(
            presentedMenu: $presentedMenu,
            menus: window.menus
          )
        }
      }

      if showsStatusBar {
        WorkspaceWindowStatusBar(
          content: window.statusBar,
          resizeHandle: canResize
            ? AnyView(
              WindowResizeHandle()
                .gesture(windowResizeGesture)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(strings.resizeWindow)
                .accessibilityAdjustableAction(resizeAccessibilityAction)
                .minimumInteractionTarget95()
            )
            : nil
        )
      }
    }
    .background(theme.colors.background)
    .modifier(WindowFrameModifier(presentation: presentation, frame: displayedFrame))
    .contentShape(.rect)
    .simultaneousGesture(TapGesture().onEnded(activate))
    .offset(windowPlacementOffset)
    .onChange(of: workspaceSize, initial: true) { _, _ in
      normalizeRetainedGeometry()
    }
    .onChange(of: presentation) { _, _ in
      normalizeRetainedGeometry()
    }
    .onChange(of: frame) { _, _ in
      normalizeRetainedGeometry()
    }
    .modifier(
      WorkspaceWindowAccessibilityActions(
        moveLabel: Text(strings.moveWindow),
        resizeLabel: Text(strings.resizeWindow),
        canMove: canMove,
        canResize: canResize,
        moveStep: configuration.accessibilityMoveStep,
        resizeStep: configuration.accessibilityResizeStep,
        move: moveAccessibilityAction,
        resize: resize
      )
    )
  }

  private var isMaximized: Bool {
    restoredFrame != nil
  }

  private var menuBarHeight: CGFloat {
    max(theme.metrics.titleBarHeight, 30)
  }

  private func windowContent(actions: WorkspaceWindowActions95) -> some View {
    window.makeContent()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(theme.colors.background)
      .environment(\.workspaceWindow95, actions)
      .simultaneousGesture(
        TapGesture()
          .onEnded {
            presentedMenu = nil
          }
      )
  }

  private var titleBarInset: CGFloat {
    presentation == .windowed ? theme.spacing.xxs : 0
  }

  private var displayedFrame: CGRect {
    guard !isMaximized else { return CGRect(origin: .zero, size: workspaceSize) }
    var preview = constrainedFrame(frame)
    preview.size = constrainedSize(
      CGSize(
        width: preview.width + windowResizeTranslation.width,
        height: preview.height + windowResizeTranslation.height
      ),
      origin: preview.origin
    )
    return preview
  }

  private var showsStatusBar: Bool {
    window.statusBar != nil || canResize
  }

  private var resolvedResizeControl: WorkspaceWindowResizeControl95 {
    switch window.resizeControl {
    case .automatic:
      presentation == .windowed ? .statusBar : .hidden
    case .statusBar, .hidden:
      window.resizeControl
    }
  }

  private var canResize: Bool {
    presentation == .windowed
      && window.configuration.capabilities.contains(.resize)
      && resolvedResizeControl == .statusBar && !isMaximized
  }

  private var canMove: Bool {
    presentation == .windowed
      && window.configuration.capabilities.contains(.move)
      && !isMaximized
  }

  private var windowDragOffset: CGSize {
    guard canMove else { return .zero }
    let normalizedFrame = constrainedFrame(frame)
    let origin = constrainedOrigin(
      CGPoint(
        x: normalizedFrame.origin.x + windowDragTranslation.width,
        y: normalizedFrame.origin.y + windowDragTranslation.height
      ),
      size: normalizedFrame.size
    )
    return CGSize(
      width: origin.x - normalizedFrame.origin.x,
      height: origin.y - normalizedFrame.origin.y
    )
  }

  private var windowPlacementOffset: CGSize {
    guard presentation == .windowed else { return .zero }
    return CGSize(
      width: displayedFrame.minX + windowDragOffset.width,
      height: displayedFrame.minY + windowDragOffset.height
    )
  }

  private var windowDragGesture: some Gesture {
    DragGesture(
      minimumDistance: canMove ? 3 : .infinity,
      coordinateSpace: .global
    )
    .updating($windowDragTranslation) { value, translation, _ in
      guard canMove else { return }
      translation = value.translation
    }
    .onChanged { _ in
      guard canMove else { return }
      if !isDraggingWindow {
        isDraggingWindow = true
        activate()
      }
    }
    .onEnded { value in
      defer { isDraggingWindow = false }
      guard canMove else { return }
      var normalizedFrame = constrainedFrame(frame)
      normalizedFrame.origin = constrainedOrigin(
        CGPoint(
          x: normalizedFrame.origin.x + value.translation.width,
          y: normalizedFrame.origin.y + value.translation.height
        ),
        size: normalizedFrame.size
      )
      frame = normalizedFrame
    }
  }

  private func toggleMaximized() {
    activate()
    if let restoredFrame {
      frame = constrainedFrame(restoredFrame)
      self.restoredFrame = nil
    } else {
      restoredFrame = constrainedFrame(frame)
    }
  }

  private var windowResizeGesture: some Gesture {
    DragGesture(minimumDistance: 2, coordinateSpace: .global)
      .updating($windowResizeTranslation) { value, translation, _ in
        guard canResize else { return }
        translation = value.translation
      }
      .onChanged { _ in
        guard canResize else { return }
        if !isResizingWindow {
          isResizingWindow = true
          activate()
        }
      }
      .onEnded { value in
        defer { isResizingWindow = false }
        guard canResize else { return }
        var normalizedFrame = constrainedFrame(frame)
        normalizedFrame.size = constrainedSize(
          CGSize(
            width: normalizedFrame.width + value.translation.width,
            height: normalizedFrame.height + value.translation.height
          ),
          origin: normalizedFrame.origin
        )
        frame = normalizedFrame
      }
  }

  private func constrainedFrame(_ frame: CGRect) -> CGRect {
    WorkspaceWindowGeometry.normalizedFrame(
      frame,
      workspaceSize: workspaceSize,
      minimumSize: window.configuration.minimumSize
    )
  }

  private func normalizeRetainedGeometry() {
    guard presentation == .windowed else { return }
    let normalizedFrame = constrainedFrame(frame)
    if normalizedFrame != frame {
      frame = normalizedFrame
    }
    if let restoredFrame {
      self.restoredFrame = constrainedFrame(restoredFrame)
    }
  }

  private func constrainedSize(_ size: CGSize, origin: CGPoint) -> CGSize {
    WorkspaceWindowGeometry.constrainedResizeSize(
      size,
      origin: origin,
      workspaceSize: workspaceSize,
      minimumSize: window.configuration.minimumSize
    )
  }

  private func constrainedOrigin(_ origin: CGPoint, size: CGSize) -> CGPoint {
    constrainedFrame(CGRect(origin: origin, size: size)).origin
  }

  private func resizeAccessibilityAction(_ direction: AccessibilityAdjustmentDirection) {
    switch direction {
    case .increment:
      resize(by: configuration.accessibilityResizeStep)
    case .decrement:
      resize(by: -configuration.accessibilityResizeStep)
    @unknown default:
      break
    }
  }

  private func moveAccessibilityAction(by offset: CGSize) {
    var moved = constrainedFrame(frame)
    moved.origin.x += offset.width
    moved.origin.y += offset.height
    frame = constrainedFrame(moved)
    activate()
  }

  private func resize(by amount: CGFloat) {
    guard canResize else { return }
    var resized = constrainedFrame(frame)
    resized.size = constrainedSize(
      CGSize(width: resized.width + amount, height: resized.height + amount),
      origin: resized.origin
    )
    frame = resized
    activate()
  }
}

private struct WorkspaceWindowAccessibilityActions: ViewModifier {
  let moveLabel: Text
  let resizeLabel: Text
  let canMove: Bool
  let canResize: Bool
  let moveStep: CGFloat
  let resizeStep: CGFloat
  let move: (CGSize) -> Void
  let resize: (CGFloat) -> Void

  @ViewBuilder
  func body(content: Content) -> some View {
    if canMove && canResize {
      content
        .modifier(MoveWindowAccessibilityActions(label: moveLabel, step: moveStep, move: move))
        .modifier(
          ResizeWindowAccessibilityActions(label: resizeLabel, step: resizeStep, resize: resize)
        )
    } else if canMove {
      content.modifier(
        MoveWindowAccessibilityActions(label: moveLabel, step: moveStep, move: move)
      )
    } else if canResize {
      content.modifier(
        ResizeWindowAccessibilityActions(label: resizeLabel, step: resizeStep, resize: resize)
      )
    } else {
      content
    }
  }
}

private struct MoveWindowAccessibilityActions: ViewModifier {
  let label: Text
  let step: CGFloat
  let move: (CGSize) -> Void

  func body(content: Content) -> some View {
    content
      .accessibilityAction(named: Text("← ") + label) {
        move(CGSize(width: -step, height: 0))
      }
      .accessibilityAction(named: Text("→ ") + label) {
        move(CGSize(width: step, height: 0))
      }
      .accessibilityAction(named: Text("↑ ") + label) {
        move(CGSize(width: 0, height: -step))
      }
      .accessibilityAction(named: Text("↓ ") + label) {
        move(CGSize(width: 0, height: step))
      }
  }
}

private struct ResizeWindowAccessibilityActions: ViewModifier {
  let label: Text
  let step: CGFloat
  let resize: (CGFloat) -> Void

  func body(content: Content) -> some View {
    content
      .accessibilityAction(named: Text("+ ") + label) {
        resize(step)
      }
      .accessibilityAction(named: Text("− ") + label) {
        resize(-step)
      }
  }
}

private struct WindowFrameModifier: ViewModifier {
  let presentation: WorkspacePresentation95
  let frame: CGRect

  @ViewBuilder
  func body(content: Content) -> some View {
    if presentation == .compact {
      content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      content
        .frame(width: frame.width, height: frame.height)
        .clipped()
        .bevel95(.raised)
    }
  }
}

private struct WorkspaceTitleBar: View {
  @Environment(\.theme95) private var theme
  @Environment(\.strings95) private var strings

  let title: Text
  let icon: AnyView
  let isActive: Bool
  let isCompact: Bool
  let minimize: (() -> Void)?
  let maximize: (() -> Void)?
  let isMaximized: Bool
  let close: (() -> Void)?

  var body: some View {
    let height =
      isCompact
      ? theme.metrics.compactTitleBarHeight
      : theme.metrics.titleBarHeight

    HStack(spacing: theme.spacing.s) {
      icon
        .frame(
          width: isCompact
            ? theme.metrics.compactTitleBarIconSize : theme.metrics.titleBarIconSize,
          height: isCompact
            ? theme.metrics.compactTitleBarIconSize : theme.metrics.titleBarIconSize
        )
        .accessibilityHidden(true)

      title
        .font(theme.fonts.body.weight(.bold))
        .lineLimit(1)
        .truncationMode(.tail)
        .foregroundStyle(isActive ? theme.colors.accentText : theme.colors.inactiveText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityRespondsToUserInteraction(false)

      if let minimize {
        WindowControlButton(
          label: Text(strings.minimize),
          glyph: .minimize,
          height: height,
          action: minimize
        )
      }
      if let maximize {
        WindowControlButton(
          label: Text(isMaximized ? strings.restore : strings.maximize),
          glyph: isMaximized ? .restore : .maximize,
          height: height,
          action: maximize
        )
      }
      if let close {
        WindowControlButton(
          label: Text(strings.close),
          glyph: .close,
          height: height,
          action: close
        )
      }
    }
    .padding(.horizontal, theme.spacing.xxs)
    .frame(height: height)
    .background(isActive ? theme.colors.accent : theme.colors.inactiveBackground)
  }

}

private struct WindowControlButton: View {
  @Environment(\.theme95) private var theme

  let label: Text
  let glyph: WindowControlGlyph
  let height: CGFloat
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      WindowControlGlyphDrawing(glyph: glyph)
        .frame(
          width: theme.metrics.windowControlWidth,
          height: theme.metrics.windowControlHeight
        )
        .bevel95(.raised)
    }
    .buttonStyle(WindowControlButtonStyle(height: height))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(label)
    .minimumInteractionTarget95()
  }
}

private enum WindowControlGlyph {
  case minimize
  case maximize
  case restore
  case close
}

private struct WindowControlGlyphDrawing: View {
  @Environment(\.theme95) private var theme

  let glyph: WindowControlGlyph

  var body: some View {
    Canvas { context, _ in
      switch glyph {
      case .minimize:
        fill(CGRect(x: 5, y: 15, width: 14, height: 3), in: &context)
      case .maximize:
        drawWindow(CGRect(x: 4, y: 3, width: 16, height: 16), in: &context)
      case .restore:
        drawWindow(CGRect(x: 8, y: 3, width: 12, height: 12), in: &context)
        drawWindow(CGRect(x: 4, y: 7, width: 12, height: 12), in: &context)
      case .close:
        for index in 0..<6 {
          let offset = CGFloat(index * 2)
          fill(CGRect(x: 5 + offset, y: 4 + offset, width: 3, height: 3), in: &context)
          fill(CGRect(x: 5 + offset, y: 14 - offset, width: 3, height: 3), in: &context)
        }
      }
    }
    .accessibilityHidden(true)
  }

  private func drawWindow(_ rect: CGRect, in context: inout GraphicsContext) {
    fill(rect, in: &context)
    context.fill(
      Path(rect.insetBy(dx: 2, dy: 3).offsetBy(dx: 0, dy: 1)),
      with: .color(theme.colors.background)
    )
  }

  private func fill(_ rect: CGRect, in context: inout GraphicsContext) {
    context.fill(Path(rect), with: .color(theme.colors.text))
  }
}

private struct WindowControlButtonStyle: ButtonStyle {
  @Environment(\.theme95) private var theme
  let height: CGFloat

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .offset(
        x: configuration.isPressed ? theme.metrics.pressedContentOffset : 0,
        y: configuration.isPressed ? theme.metrics.pressedContentOffset : 0
      )
      .overlay {
        if configuration.isPressed {
          Color.clear.bevel95(.sunken, background: Color.clear)
        }
      }
      .frame(minWidth: theme.metrics.windowControlMinimumWidth)
      .frame(height: height)
      .contentShape(.rect)
  }
}

private struct WorkspaceWindowStatusBar: View {
  @Environment(\.theme95) private var theme

  let content: AnyView?
  let resizeHandle: AnyView?

  var body: some View {
    HStack(spacing: theme.spacing.xxxs) {
      Group {
        if let content {
          content
        } else {
          Color.clear
        }
      }
      .padding(.horizontal, theme.spacing.xxs)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .bevel95(.sunken)

      if let resizeHandle {
        resizeHandle
      }
    }
    .padding(theme.spacing.xxxs)
    .frame(height: theme.metrics.statusBarHeight)
    .background(theme.colors.background)
  }
}

private struct WindowResizeHandle: View {
  @Environment(\.theme95) private var theme

  var body: some View {
    Canvas { context, size in
      let corner = CGPoint(x: size.width - 3, y: size.height - 3)

      for length in [CGFloat(5), 10, 15] {
        let start = CGPoint(x: corner.x - length, y: corner.y)
        let end = CGPoint(x: corner.x, y: corner.y - length)

        var dark = Path()
        dark.move(to: start)
        dark.addLine(to: end)
        context.stroke(dark, with: .color(theme.colors.borderDarkest), lineWidth: 1)

        var light = Path()
        light.move(to: CGPoint(x: start.x, y: start.y - 1))
        light.addLine(to: CGPoint(x: end.x - 1, y: end.y))
        context.stroke(light, with: .color(theme.colors.borderLightest), lineWidth: 1)
      }
    }
    .frame(width: theme.metrics.resizeHandleSize, height: theme.metrics.resizeHandleSize)
    .contentShape(.rect)
  }
}
