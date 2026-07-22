import SwiftUI

struct WorkspaceWindowHost: View {
  @Environment(\.theme95) private var theme
  @GestureState private var windowDragTranslation = CGSize.zero
  @GestureState private var windowResizeTranslation = CGSize.zero
  @State private var isDraggingWindow = false
  @State private var isResizingWindow = false
  @State private var restoredFrame: CGRect?

  let window: WorkspaceWindow95
  let isActive: Bool
  let presentation: WorkspacePresentation95
  let workspaceSize: CGSize
  @Binding var frame: CGRect
  let activate: () -> Void
  let minimize: () -> Void
  let close: () -> Void

  var body: some View {
    let actions = WorkspaceWindowActions95(close: close, minimize: minimize)
    let maximizeAction: (() -> Void)? =
      presentation == .windowed ? { toggleMaximized() } : nil

    VStack(spacing: 0) {
      WorkspaceTitleBar(
        title: window.title,
        icon: window.titleBarIcon,
        isActive: isActive,
        isCompact: presentation == .compact,
        minimize: minimize,
        maximize: maximizeAction,
        isMaximized: isMaximized,
        close: close
      )
      .padding(.horizontal, titleBarInset)
      .padding(.top, titleBarInset)
      .contentShape(.rect)
      .simultaneousGesture(windowDragGesture)

      window.makeContent()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
        .environment(\.workspaceWindow95, actions)

      if showsStatusBar {
        WorkspaceWindowStatusBar(
          content: window.statusBar,
          resizeHandle: canResize
            ? AnyView(WindowResizeHandle().gesture(windowResizeGesture))
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
  }

  private var isMaximized: Bool {
    restoredFrame != nil
  }

  private var titleBarInset: CGFloat {
    presentation == .windowed ? Spacing95[4] : 0
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
    window.statusBar != nil || resolvedResizeControl == .statusBar
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
    presentation == .windowed && resolvedResizeControl == .statusBar && !isMaximized
  }

  private var windowDragOffset: CGSize {
    guard presentation == .windowed, !isMaximized else { return .zero }
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
      minimumDistance: presentation == .windowed ? 3 : .infinity,
      coordinateSpace: .global
    )
    .updating($windowDragTranslation) { value, translation, _ in
      guard presentation == .windowed, restoredFrame == nil else { return }
      translation = value.translation
    }
    .onChanged { _ in
      guard presentation == .windowed, restoredFrame == nil else { return }
      if !isDraggingWindow {
        isDraggingWindow = true
        activate()
      }
    }
    .onEnded { value in
      defer { isDraggingWindow = false }
      guard presentation == .windowed, restoredFrame == nil else { return }
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
    WorkspaceWindowGeometry.normalizedFrame(frame, workspaceSize: workspaceSize)
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
      workspaceSize: workspaceSize
    )
  }

  private func constrainedOrigin(_ origin: CGPoint, size: CGSize) -> CGPoint {
    constrainedFrame(CGRect(origin: origin, size: size)).origin
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

  let title: Text
  let icon: AnyView
  let isActive: Bool
  let isCompact: Bool
  let minimize: () -> Void
  let maximize: (() -> Void)?
  let isMaximized: Bool
  let close: () -> Void

  var body: some View {
    HStack(spacing: Spacing95[6]) {
      icon
        .frame(width: isCompact ? 24 : 18, height: isCompact ? 24 : 18)
        .accessibilityHidden(true)

      title
        .font(theme.fonts.body.weight(.bold))
        .lineLimit(1)
        .foregroundStyle(isActive ? theme.colors.accentText : theme.colors.inactiveText)
        .frame(maxWidth: .infinity, alignment: .leading)

      WindowControlButton(label: "Minimize", glyph: .minimize, action: minimize)
      if let maximize {
        WindowControlButton(
          label: isMaximized ? "Restore" : "Maximize",
          glyph: isMaximized ? .restore : .maximize,
          action: maximize
        )
      }
      WindowControlButton(label: "Close", glyph: .close, action: close)
    }
    .padding(.horizontal, Spacing95[4])
    .frame(height: isCompact ? 44 : 30)
    .background(isActive ? theme.colors.accent : theme.colors.inactiveBackground)
  }
}

private struct WindowControlButton: View {
  let label: LocalizedStringKey
  let glyph: WindowControlGlyph
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      WindowControlGlyphDrawing(glyph: glyph)
        .frame(width: 24, height: 22)
        .bevel95(.raised)
    }
    .buttonStyle(WindowControlButtonStyle())
    .accessibilityLabel(Text(label))
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
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .offset(x: configuration.isPressed ? 1 : 0, y: configuration.isPressed ? 1 : 0)
      .overlay {
        if configuration.isPressed {
          Color.clear.bevel95(.sunken, background: Color.clear)
        }
      }
      .frame(minWidth: 32, minHeight: 30)
      .contentShape(.rect)
  }
}

private struct WorkspaceWindowStatusBar: View {
  @Environment(\.theme95) private var theme

  let content: AnyView?
  let resizeHandle: AnyView?

  var body: some View {
    HStack(spacing: Spacing95[2]) {
      Group {
        if let content {
          content
        } else {
          Color.clear
        }
      }
      .padding(.horizontal, Spacing95[4])
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .bevel95(.sunken)

      if let resizeHandle {
        resizeHandle
      }
    }
    .padding(Spacing95[2])
    .frame(height: 28)
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
    .frame(width: 24, height: 24)
    .contentShape(.rect)
    .accessibilityHidden(true)
  }
}
