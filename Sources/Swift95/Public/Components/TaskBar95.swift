import SwiftUI

/// A Windows 95-inspired taskbar bound to its enclosing ``Workspace95``.
///
/// Open windows become task buttons automatically. Activating an inactive task focuses it;
/// activating the current task minimizes it and reveals the next window or the desktop.
///
/// ```swift
/// TaskBar95("Start") {
///   Image95("start")
/// } menu: {
///   StartMenu95 {
///     WorkspaceLink95("Notes", value: App.notes)
///   }
/// } tray: {
///   Text95("12:30")
/// }
/// ```
public struct TaskBar95<StartIcon: View, Menu: View, Tray: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.workspaceContext) private var workspace
  @Environment(\.theme95) private var theme
  @Environment(\.strings95) private var strings
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isMenuPresented = false
  @State private var renderedHeight = CGFloat.zero

  private let startTitle: Text
  private let startIcon: StartIcon
  private let menu: Menu
  private let tray: Tray
  private let startButtonTransform: (AnyView) -> AnyView
  private let taskButtonTransform: (AnyView) -> AnyView

  /// Creates a taskbar with a localized Start title.
  public init(
    _ startTitleKey: LocalizedStringKey,
    @ViewBuilder icon: () -> StartIcon,
    @ViewBuilder menu: () -> Menu,
    @ViewBuilder tray: () -> Tray
  ) {
    startTitle = Text(startTitleKey)
    startIcon = icon()
    self.menu = menu()
    self.tray = tray()
    startButtonTransform = { $0 }
    taskButtonTransform = { $0 }
  }

  /// Creates a taskbar with an unlocalized Start title.
  public init<S: StringProtocol>(
    _ startTitle: S,
    @ViewBuilder icon: () -> StartIcon,
    @ViewBuilder menu: () -> Menu,
    @ViewBuilder tray: () -> Tray
  ) {
    self.startTitle = Text(verbatim: String(startTitle))
    startIcon = icon()
    self.menu = menu()
    self.tray = tray()
    startButtonTransform = { $0 }
    taskButtonTransform = { $0 }
  }

  private init(
    startTitle: Text,
    startIcon: StartIcon,
    menu: Menu,
    tray: Tray,
    startButtonTransform: @escaping (AnyView) -> AnyView,
    taskButtonTransform: @escaping (AnyView) -> AnyView
  ) {
    self.startTitle = startTitle
    self.startIcon = startIcon
    self.menu = menu
    self.tray = tray
    self.startButtonTransform = startButtonTransform
    self.taskButtonTransform = taskButtonTransform
  }

  /// The Start button, task strip, and tray.
  public var body: some View {
    HStack(spacing: theme.spacing.xxs) {
      startButtonTransform(AnyView(startButton))

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: theme.spacing.xxs) {
          ForEach(workspace.tasks) { task in
            taskButtonTransform(AnyView(taskButton(for: task)))
          }
        }
      }

      if !(Tray.self == EmptyView.self) {
        tray
          .padding(.horizontal, theme.spacing.s)
          .frame(minHeight: theme.metrics.taskbarItemHeight)
          .bevel95(.sunken)
      }
    }
    .padding(.horizontal, horizontalSizeClass == .compact ? theme.spacing.l : theme.spacing.xxs)
    .padding(.top, theme.spacing.xxs)
    .padding(.bottom, horizontalSizeClass == .compact ? theme.spacing.m : theme.spacing.xxs)
    .frame(minHeight: minimumHeight)
    .onGeometryChange(for: CGFloat.self) { geometry in
      geometry.size.height
    } action: { height in
      renderedHeight = height
    }
    .background(theme.colors.background.ignoresSafeArea(edges: .bottom))
    .overlay(alignment: .top) {
      Rectangle()
        .fill(theme.colors.borderLightest)
        .frame(height: 1)
    }
    .overlay(alignment: .bottomLeading) {
      if isMenuPresented {
        menu
          .environment(\.dismissStartMenu, { isMenuPresented = false })
          .offset(y: -resolvedHeight)
          .transition(.opacity)
          .zIndex(1000)
      }
    }
    .animation(
      reduceMotion ? nil : .easeOut(duration: theme.motion.quick),
      value: isMenuPresented
    )
    .onKeyPress(.escape) {
      guard isMenuPresented else { return .ignored }
      isMenuPresented = false
      return .handled
    }
  }

  /// Applies SwiftUI modifiers to the completed Start button.
  ///
  /// ```swift
  /// taskBar.swiftUIStartButton { button in
  ///   button.keyboardShortcut("s", modifiers: [.command, .shift])
  /// }
  /// ```
  public func swiftUIStartButton<ModifiedButton: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedButton
  ) -> TaskBar95 {
    TaskBar95(
      startTitle: startTitle,
      startIcon: startIcon,
      menu: menu,
      tray: tray,
      startButtonTransform: { button in
        AnyView(transform(self.startButtonTransform(button)))
      },
      taskButtonTransform: taskButtonTransform
    )
  }

  /// Applies SwiftUI modifiers to every completed task button.
  ///
  /// The transform receives each button after its workspace action, label, style, and selected
  /// state have been configured.
  public func swiftUITaskButton<ModifiedButton: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedButton
  ) -> TaskBar95 {
    TaskBar95(
      startTitle: startTitle,
      startIcon: startIcon,
      menu: menu,
      tray: tray,
      startButtonTransform: startButtonTransform,
      taskButtonTransform: { button in
        AnyView(transform(self.taskButtonTransform(button)))
      }
    )
  }

  private var startButton: some View {
    Button {
      isMenuPresented.toggle()
    } label: {
      HStack(spacing: theme.spacing.xxs) {
        startIcon
          .accessibilityRepresentation {
            EmptyView()
          }
          .frame(
            width: theme.metrics.taskbarStartIconSize,
            height: theme.metrics.taskbarStartIconSize
          )
        startTitle
          .font(theme.fonts.body.weight(.bold))
      }
      .padding(.horizontal, theme.spacing.s)
      .frame(height: theme.metrics.taskbarItemHeight)
    }
    .buttonStyle(
      TaskBarButtonStyle(
        theme: theme,
        isSelected: isMenuPresented,
        usesTaskSelectionFill: false
      )
    )
    .accessibilityAddTraits(isMenuPresented ? .isSelected : [])
    .accessibilityValue(Text(isMenuPresented ? strings.expanded : strings.collapsed))
  }

  private func taskButton(for task: WorkspaceTaskContext) -> some View {
    Button {
      isMenuPresented = false
      workspace.toggleTask(task.id)
    } label: {
      HStack(spacing: theme.spacing.xxs) {
        task.icon
          .accessibilityRepresentation {
            EmptyView()
          }
          .frame(width: theme.metrics.taskbarIconSize, height: theme.metrics.taskbarIconSize)
        task.title
          .font(theme.fonts.body.weight(task.isActive ? .bold : .regular))
          .lineLimit(1)
      }
      .padding(.horizontal, theme.spacing.s)
      .frame(
        minWidth: theme.metrics.taskbarButtonMinimumWidth,
        maxWidth: theme.metrics.taskbarButtonMaximumWidth,
        minHeight: theme.metrics.taskbarItemHeight,
        alignment: .leading
      )
    }
    .buttonStyle(
      TaskBarButtonStyle(
        theme: theme,
        isSelected: task.isActive,
        usesTaskSelectionFill: true
      )
    )
    .accessibilityAddTraits(task.isActive ? .isSelected : [])
    .modifier(
      TaskAccessibilityValue95(
        value: task.isMinimized ? strings.minimized : task.isActive ? strings.active : nil
      )
    )
    .opacity(task.isMinimized ? theme.metrics.taskbarMinimizedOpacity : 1)
  }

  private var minimumHeight: CGFloat {
    TaskBarGeometry95.height(
      minimumHeight: theme.metrics.taskbarHeight,
      itemHeight: theme.metrics.taskbarItemHeight,
      topPadding: theme.spacing.xxs,
      bottomPadding: horizontalSizeClass == .compact ? theme.spacing.m : theme.spacing.xxs
    )
  }

  private var resolvedHeight: CGFloat {
    renderedHeight > 0 ? renderedHeight : minimumHeight
  }
}

private struct TaskAccessibilityValue95: ViewModifier {
  let value: LocalizedStringResource?

  @ViewBuilder
  func body(content: Content) -> some View {
    if let value {
      content.accessibilityValue(Text(value))
    } else {
      content
    }
  }
}

enum TaskBarGeometry95 {
  static func height(
    minimumHeight: CGFloat,
    itemHeight: CGFloat,
    topPadding: CGFloat,
    bottomPadding: CGFloat
  ) -> CGFloat {
    max(minimumHeight, itemHeight + topPadding + bottomPadding)
  }
}

extension TaskBar95 where Tray == EmptyView {
  /// Creates a taskbar without tray content.
  public init(
    _ startTitleKey: LocalizedStringKey,
    @ViewBuilder icon: () -> StartIcon,
    @ViewBuilder menu: () -> Menu
  ) {
    self.init(startTitleKey, icon: icon, menu: menu) { EmptyView() }
  }

  /// Creates a taskbar without tray content and with an unlocalized Start title.
  public init<S: StringProtocol>(
    _ startTitle: S,
    @ViewBuilder icon: () -> StartIcon,
    @ViewBuilder menu: () -> Menu
  ) {
    self.init(startTitle, icon: icon, menu: menu) { EmptyView() }
  }
}

private struct TaskBarButtonStyle: ButtonStyle {
  let theme: Theme95
  let isSelected: Bool
  let usesTaskSelectionFill: Bool

  func makeBody(configuration: Configuration) -> some View {
    let isPressed = configuration.isPressed || isSelected
    let usesTaskSelection = isSelected && usesTaskSelectionFill

    configuration.label
      .foregroundStyle(theme.colors.text)
      .background {
        if usesTaskSelection {
          TaskSelectionFill(theme: theme)
        } else {
          theme.colors.background
        }
      }
      .offset(
        x: isPressed ? theme.metrics.pressedContentOffset : 0,
        y: isPressed ? theme.metrics.pressedContentOffset : 0
      )
      .bevel95(isPressed ? .sunken : .raised)
      .contentShape(.rect)
  }
}

private struct TaskSelectionFill: View {
  let theme: Theme95

  var body: some View {
    ZStack {
      theme.colors.background
      Checkerboard(colors: theme.colors)
        .padding(theme.metrics.bevelWidth)
    }
    .clipped()
    .allowsHitTesting(false)
  }
}
