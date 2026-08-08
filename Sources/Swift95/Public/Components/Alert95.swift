import SwiftUI

#if os(macOS)
  import AppKit
#endif

private struct AlertModifier95<Icon: View, Actions: View, Message: View>: ViewModifier {
  @Binding var isPresented: Bool

  let title: Text
  let isCloseButtonEnabled: Bool
  let icon: () -> Icon
  let actions: () -> Actions
  let message: () -> Message

  func body(content: Content) -> some View {
    #if os(iOS)
      content
        .fullScreenCover(isPresented: $isPresented) {
          presentation
            .presentationBackground(.clear)
            .interactiveDismissDisabled()
        }
        .transaction(value: isPresented) { transaction in
          transaction.disablesAnimations = true
        }
    #elseif os(macOS)
      content
        .background {
          MacAlertWindowPresenter95(isPresented: $isPresented) {
            presentation
          }
          .frame(width: 0, height: 0)
        }
        .transaction(value: isPresented) { transaction in
          transaction.disablesAnimations = true
        }
    #endif
  }

  private var presentation: some View {
    AlertPresentation95(
      title: title,
      isPresented: $isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: icon,
      actions: actions,
      message: message
    )
  }
}

#if os(macOS)
  private struct MacAlertWindowPresenter95<Content: View>: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.controlSize) private var controlSize
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.font) private var font
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.legibilityWeight) private var legibilityWeight
    @Environment(\.locale) private var locale
    @Environment(\.strings95) private var strings
    @Environment(\.theme95) private var theme
    @Environment(\.timeZone) private var timeZone

    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
      MacAlertPanelPresenter95(isPresented: $isPresented) {
        content()
          .environment(\.calendar, calendar)
          .environment(\.colorScheme, colorScheme)
          .environment(\.controlSize, controlSize)
          .environment(\.dynamicTypeSize, dynamicTypeSize)
          .environment(\.font, font)
          .environment(\.isEnabled, isEnabled)
          .environment(\.layoutDirection, layoutDirection)
          .environment(\.legibilityWeight, legibilityWeight)
          .environment(\.locale, locale)
          .environment(\.timeZone, timeZone)
          .strings95(strings)
          .theme95(theme)
      }
    }
  }

  private struct MacAlertPanelPresenter95<Content: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> AlertPresentationAnchorView95 {
      let anchor = AlertPresentationAnchorView95()
      anchor.windowDidChange = { [weak coordinator = context.coordinator, weak anchor] in
        guard let coordinator, let anchor else { return }
        coordinator.presentIfNeeded(from: anchor)
      }
      return anchor
    }

    func updateNSView(_ anchor: AlertPresentationAnchorView95, context: Context) {
      context.coordinator.update(
        isPresented: isPresented,
        rootView: AnyView(content()),
        from: anchor
      )
    }

    static func dismantleNSView(
      _ nsView: AlertPresentationAnchorView95,
      coordinator: Coordinator
    ) {
      coordinator.dismiss()
    }

    @MainActor
    final class Coordinator {
      private weak var anchor: NSView?
      private weak var parentWindow: NSWindow?
      private weak var previousFirstResponder: NSResponder?
      private var eventMonitor: Any?
      private var host: NSHostingView<AnyView>?
      private var panel: AlertPanelWindow95?
      private var isPresented = false
      private var rootView: AnyView?

      func update(
        isPresented: Bool,
        rootView: AnyView,
        from anchor: NSView
      ) {
        self.anchor = anchor
        self.isPresented = isPresented
        self.rootView = rootView

        if isPresented {
          presentIfNeeded(from: anchor)
        } else {
          dismiss()
        }
      }

      func presentIfNeeded(from anchor: NSView) {
        guard isPresented, let rootView, let parentWindow = anchor.window else { return }

        if let panel, let host {
          host.rootView = rootView
          resizeAndCenter(panel, host: host, over: parentWindow)
          return
        }

        let host = NSHostingView(rootView: rootView)
        host.setAccessibilityModal(true)

        let panel = AlertPanelWindow95(
          contentRect: .zero,
          styleMask: [.borderless],
          backing: .buffered,
          defer: false
        )
        panel.animationBehavior = .none
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isOpaque = false
        panel.isReleasedWhenClosed = false
        panel.contentView = host

        self.host = host
        self.panel = panel
        self.parentWindow = parentWindow
        previousFirstResponder = parentWindow.firstResponder

        resizeAndCenter(panel, host: host, over: parentWindow)
        parentWindow.addChildWindow(panel, ordered: .above)
        installEventMonitor(parentWindow: parentWindow, panel: panel)
        panel.makeKeyAndOrderFront(nil)
        NSAccessibility.post(element: host, notification: .focusedUIElementChanged)
      }

      func dismiss() {
        guard let panel else { return }

        let parentWindow = self.parentWindow
        panel.parent?.removeChildWindow(panel)
        panel.orderOut(nil)
        removeEventMonitor()
        self.panel = nil
        host = nil

        if let parentWindow {
          parentWindow.makeKey()
          if let previousFirstResponder {
            parentWindow.makeFirstResponder(previousFirstResponder)
          }
          if let contentView = parentWindow.contentView {
            NSAccessibility.post(
              element: contentView,
              notification: .focusedUIElementChanged
            )
          }
        }
        previousFirstResponder = nil
      }

      private func resizeAndCenter(
        _ panel: NSPanel,
        host: NSHostingView<AnyView>,
        over parentWindow: NSWindow
      ) {
        host.layoutSubtreeIfNeeded()
        let size = host.fittingSize
        let parentFrame = parentWindow.frame
        panel.setFrame(
          CGRect(
            x: parentFrame.midX - size.width / 2,
            y: parentFrame.midY - size.height / 2,
            width: size.width,
            height: size.height
          ),
          display: true
        )
      }

      private func installEventMonitor(parentWindow: NSWindow, panel: NSPanel) {
        eventMonitor = NSEvent.addLocalMonitorForEvents(
          matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]
        ) { event in
          guard event.window === parentWindow else { return event }
          return event.window === panel ? event : nil
        }
      }

      private func removeEventMonitor() {
        if let eventMonitor {
          NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
      }

    }
  }

  private final class AlertPanelWindow95: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
  }

  private final class AlertPresentationAnchorView95: NSView {
    var windowDidChange: (() -> Void)?

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      windowDidChange?()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
      nil
    }
  }
#endif

struct AlertPresentation95<Icon: View, Actions: View, Message: View>: View {
  @Environment(\.theme95) private var theme
  @Binding private var isPresented: Bool

  private let title: Text
  private let isCloseButtonEnabled: Bool
  private let icon: Icon
  private let actions: Actions
  private let message: Message

  init(
    title: Text,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder icon: () -> Icon,
    @ViewBuilder actions: () -> Actions,
    @ViewBuilder message: () -> Message
  ) {
    self.title = title
    _isPresented = isPresented
    self.isCloseButtonEnabled = isCloseButtonEnabled
    self.icon = icon()
    self.actions = actions()
    self.message = message()
  }

  var body: some View {
    Group {
      #if os(iOS)
        GeometryReader { geometry in
          ZStack {
            Color.black
              .opacity(0.001)
              .ignoresSafeArea()

            alert
              .frame(width: min(max(geometry.size.width - theme.spacing.xxl * 2, 0), 560))
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
          minWidth: 320,
          idealWidth: 520,
          minHeight: 220,
          idealHeight: 320
        )
      #elseif os(macOS)
        alert
          .frame(minWidth: 320, idealWidth: 520, maxWidth: 560)
      #endif
    }
    .background(Color.clear)
    .onKeyPress(.escape) {
      guard isCloseButtonEnabled else {
        return .ignored
      }
      dismiss()
      return .handled
    }
  }

  private var alert: some View {
    VStack(spacing: 0) {
      WorkspaceTitleBar(
        title: title,
        icon: nil,
        isActive: true,
        isCompact: false,
        minimize: nil,
        maximize: nil,
        isMaximized: false,
        isCloseButtonEnabled: isCloseButtonEnabled,
        closeAccessibilityIdentifier: "swift95.alert.close",
        close: dismiss
      )
      .padding(theme.spacing.xxs)
      .padding(.bottom, 0)

      VStack(spacing: theme.spacing.xl) {
        messageContent

        HStack(spacing: theme.spacing.m) {
          actions
        }
        .buttonStyle(
          AlertButtonStyle95(
            dismiss: dismiss
          )
        )
      }
      .padding(.horizontal, theme.spacing.xxl)
      .padding(.top, theme.spacing.xl)
      .padding(.bottom, theme.spacing.xxl)
    }
    .background(theme.colors.background)
    .bevel95(.raised)
    .fixedSize(horizontal: false, vertical: true)
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private var messageContent: some View {
    if Icon.self == EmptyView.self {
      message
        .font(theme.fonts.body)
        .foregroundStyle(theme.colors.text)
        .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      HStack(alignment: .top, spacing: theme.spacing.xxl) {
        icon
          .accessibilityHidden(true)

        message
          .font(theme.fonts.body)
          .foregroundStyle(theme.colors.text)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }

  private func dismiss() {
    isPresented = false
  }
}

private struct AlertButtonStyle95: PrimitiveButtonStyle {
  let dismiss: () -> Void

  func makeBody(configuration: Configuration) -> some View {
    let activate = {
      configuration.trigger()
      dismiss()
    }

    return Button95(role: configuration.role, action: activate) {
      configuration.label
    }
    .accessibilityAction(named: Text("Activate"), activate)
  }
}

public extension View {
  /// Presents a Swift95 alert with a localized title and custom icon.
  ///
  /// This modifier follows SwiftUI's native alert structure while drawing its modal presentation
  /// with the closest ``Theme95``. By default, the title-bar close control and Escape dismiss the
  /// alert by setting `isPresented` to `false`. Set `isCloseButtonEnabled` to `false` to leave the
  /// close control visible but disabled and require an explicit alert action.
  ///
  /// On macOS, the alert appears in a borderless child panel without a dimming cover or presentation
  /// animation. The panel blocks interaction with its parent window until the alert is dismissed.
  ///
  /// Use native SwiftUI `Button` values in `actions`, rather than ``Button95``. The alert intercepts
  /// each native button action, renders its label through `Button95`, preserves its semantic role,
  /// enabled state, keyboard shortcuts, and accessibility modifiers, and dismisses after the action
  /// runs. Apply native SwiftUI configuration directly to those buttons; an additional `.swiftUI`
  /// escape hatch is not needed.
  ///
  /// The icon can be any SwiftUI view. Alert icons are treated as decorative and hidden from the
  /// accessibility tree, so the title and message should communicate the alert's meaning. The
  /// Swift95 target does not depend on an icon package.
  ///
  /// ```swift
  /// ContentView()
  ///   .alert95(
  ///     "Printer",
  ///     isPresented: $showsPrinterAlert,
  ///     icon: {
  ///       Image("printer-warning")
  ///     }
  ///   ) {
  ///     Button("Retry") {
  ///       retryPrinting()
  ///     }
  ///     .keyboardShortcut(.defaultAction)
  ///
  ///     Button("Cancel", role: .cancel) {}
  ///       .keyboardShortcut(.cancelAction)
  ///   } message: {
  ///     Text("There is no default printer.")
  ///   }
  /// ```
  ///
  /// - Parameters:
  ///   - titleKey: The localized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - icon: Decorative SwiftUI content displayed beside the message.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  ///   - message: Supporting content displayed in the body of the alert.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<Icon: View, Actions: View, Message: View>(
    _ titleKey: LocalizedStringKey,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder icon: @escaping () -> Icon,
    @ViewBuilder actions: @escaping () -> Actions,
    @ViewBuilder message: @escaping () -> Message
  ) -> some View {
    modifier(
      AlertModifier95(
        isPresented: isPresented,
        title: Text(titleKey),
        isCloseButtonEnabled: isCloseButtonEnabled,
        icon: icon,
        actions: actions,
        message: message
      )
    )
  }

  /// Presents a Swift95 alert with an unlocalized title and custom icon.
  ///
  /// This overload creates the title with `Text(verbatim:)`. Use it for user-generated or otherwise
  /// unlocalized titles. Supply native SwiftUI `Button` values in `actions`; Alert95 renders them
  /// through ``Button95`` and dismisses after an action runs. The icon is decorative and hidden from
  /// the accessibility tree.
  ///
  /// - Parameters:
  ///   - title: The unlocalized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - icon: Decorative SwiftUI content displayed beside the message.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  ///   - message: Supporting content displayed in the body of the alert.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<S: StringProtocol, Icon: View, Actions: View, Message: View>(
    _ title: S,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder icon: @escaping () -> Icon,
    @ViewBuilder actions: @escaping () -> Actions,
    @ViewBuilder message: @escaping () -> Message
  ) -> some View {
    modifier(
      AlertModifier95(
        isPresented: isPresented,
        title: Text(verbatim: String(title)),
        isCloseButtonEnabled: isCloseButtonEnabled,
        icon: icon,
        actions: actions,
        message: message
      )
    )
  }

  /// Presents a Swift95 alert with a localized title and no icon.
  ///
  /// Use this overload for text-only alerts. Supply native SwiftUI `Button` values in `actions`;
  /// Alert95 preserves their native configuration, renders them through ``Button95``, and dismisses
  /// after an action runs.
  ///
  /// - Parameters:
  ///   - titleKey: The localized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  ///   - message: Supporting content displayed in the body of the alert.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<Actions: View, Message: View>(
    _ titleKey: LocalizedStringKey,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder actions: @escaping () -> Actions,
    @ViewBuilder message: @escaping () -> Message
  ) -> some View {
    alert95(
      titleKey,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: { EmptyView() },
      actions: actions,
      message: message
    )
  }

  /// Presents a Swift95 alert with an unlocalized title and no icon.
  ///
  /// This overload creates a text-only title with `Text(verbatim:)`. Supply native SwiftUI `Button`
  /// values in `actions`; Alert95 preserves their native configuration, renders them through
  /// ``Button95``, and dismisses after an action runs.
  ///
  /// - Parameters:
  ///   - title: The unlocalized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  ///   - message: Supporting content displayed in the body of the alert.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<S: StringProtocol, Actions: View, Message: View>(
    _ title: S,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder actions: @escaping () -> Actions,
    @ViewBuilder message: @escaping () -> Message
  ) -> some View {
    alert95(
      title,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: { EmptyView() },
      actions: actions,
      message: message
    )
  }

  /// Presents a Swift95 alert with a localized title, custom icon, and no message.
  ///
  /// Use this overload when the alert's title and actions communicate all necessary information.
  ///
  /// - Parameters:
  ///   - titleKey: The localized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - icon: Decorative SwiftUI content displayed in the alert body.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<Icon: View, Actions: View>(
    _ titleKey: LocalizedStringKey,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder icon: @escaping () -> Icon,
    @ViewBuilder actions: @escaping () -> Actions
  ) -> some View {
    alert95(
      titleKey,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: icon,
      actions: actions,
      message: { EmptyView() }
    )
  }

  /// Presents a Swift95 alert with an unlocalized title, custom icon, and no message.
  ///
  /// - Parameters:
  ///   - title: The unlocalized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - icon: Decorative SwiftUI content displayed in the alert body.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<S: StringProtocol, Icon: View, Actions: View>(
    _ title: S,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder icon: @escaping () -> Icon,
    @ViewBuilder actions: @escaping () -> Actions
  ) -> some View {
    alert95(
      title,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: icon,
      actions: actions,
      message: { EmptyView() }
    )
  }

  /// Presents a Swift95 alert with a localized title and actions.
  ///
  /// Use this overload when the alert does not need an icon or supporting message.
  ///
  /// - Parameters:
  ///   - titleKey: The localized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<Actions: View>(
    _ titleKey: LocalizedStringKey,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder actions: @escaping () -> Actions
  ) -> some View {
    alert95(
      titleKey,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: { EmptyView() },
      actions: actions,
      message: { EmptyView() }
    )
  }

  /// Presents a Swift95 alert with an unlocalized title and actions.
  ///
  /// - Parameters:
  ///   - title: The unlocalized title displayed in the alert title bar.
  ///   - isPresented: A binding that controls whether the alert is visible.
  ///   - isCloseButtonEnabled: Whether the title-bar close control and Escape can dismiss the alert.
  ///   - actions: Native SwiftUI buttons rendered as `Button95` controls along the bottom edge.
  /// - Returns: A view that presents the alert when `isPresented` is `true`.
  func alert95<S: StringProtocol, Actions: View>(
    _ title: S,
    isPresented: Binding<Bool>,
    isCloseButtonEnabled: Bool = true,
    @ViewBuilder actions: @escaping () -> Actions
  ) -> some View {
    alert95(
      title,
      isPresented: isPresented,
      isCloseButtonEnabled: isCloseButtonEnabled,
      icon: { EmptyView() },
      actions: actions,
      message: { EmptyView() }
    )
  }
}
