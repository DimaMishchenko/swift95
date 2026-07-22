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
  @State private var isMenuPresented = false

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
    HStack(spacing: Spacing95[4]) {
      startButtonTransform(AnyView(startButton))

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: Spacing95[4]) {
          ForEach(workspace.tasks) { task in
            taskButtonTransform(AnyView(taskButton(for: task)))
          }
        }
      }

      if !(Tray.self == EmptyView.self) {
        tray
          .padding(.horizontal, Spacing95[6])
          .frame(minHeight: 34)
          .bevel95(.sunken)
      }
    }
    .padding(.horizontal, horizontalSizeClass == .compact ? Spacing95[10] : Spacing95[4])
    .padding(.top, Spacing95[4])
    .padding(.bottom, horizontalSizeClass == .compact ? Spacing95[8] : Spacing95[4])
    .frame(minHeight: 44)
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
          .offset(y: -44)
          .transition(.opacity)
          .zIndex(1000)
      }
    }
    .animation(.easeOut(duration: 0.1), value: isMenuPresented)
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
      HStack(spacing: Spacing95[4]) {
        startIcon
          .frame(width: 22, height: 22)
        startTitle
          .font(theme.fonts.body.weight(.bold))
      }
      .padding(.horizontal, Spacing95[6])
      .frame(height: 34)
    }
    .buttonStyle(
      TaskBarButtonStyle(
        theme: theme,
        isSelected: isMenuPresented,
        usesTaskSelectionFill: false
      )
    )
    .accessibilityAddTraits(isMenuPresented ? .isSelected : [])
  }

  private func taskButton(for task: WorkspaceTaskContext) -> some View {
    Button {
      isMenuPresented = false
      workspace.toggleTask(task.id)
    } label: {
      HStack(spacing: Spacing95[4]) {
        task.icon
          .frame(width: 20, height: 20)
          .accessibilityHidden(true)
        task.title
          .font(theme.fonts.body.weight(task.isActive ? .bold : .regular))
          .lineLimit(1)
      }
      .padding(.horizontal, Spacing95[6])
      .frame(minWidth: 96, maxWidth: 190, minHeight: 34, alignment: .leading)
    }
    .buttonStyle(
      TaskBarButtonStyle(
        theme: theme,
        isSelected: task.isActive,
        usesTaskSelectionFill: true
      )
    )
    .accessibilityAddTraits(task.isActive ? .isSelected : [])
    .opacity(task.isMinimized ? 0.82 : 1)
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
      .offset(x: isPressed ? 1 : 0, y: isPressed ? 1 : 0)
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
