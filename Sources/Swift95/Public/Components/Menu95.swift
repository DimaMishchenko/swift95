import SwiftUI

/// An actionable command displayed in a ``Menu95``.
///
/// Add menu items inside a menu's content builder. Each item renders as a
/// native SwiftUI button with classic Swift95 styling, including disabled and
/// highlighted states.
///
/// ```swift
/// Menu95("File") {
///   MenuItem95("New") {
///     newDocument()
///   }
///   MenuItem95("Print", isEnabled: canPrint) {
///     printDocument()
///   }
/// }
/// ```
///
/// Use ``swiftUI(_:)`` when the completed command button needs a native
/// SwiftUI modifier such as an accessibility identifier or keyboard shortcut.
public struct MenuItem95 {
  let label: AnyView
  let action: () -> Void
  let isEnabled: Bool
  private let transform: (AnyView) -> AnyView

  /// Creates a menu command with a localized title.
  ///
  /// - Parameters:
  ///   - titleKey: The localized key used as the command's visible and
  ///     accessible title.
  ///   - isEnabled: A Boolean value that determines whether the command can be
  ///     highlighted and activated. The default is `true`.
  ///   - action: The action to perform when the user activates the command.
  public init(
    _ titleKey: LocalizedStringKey,
    isEnabled: Bool = true,
    action: @escaping () -> Void
  ) {
    label = AnyView(Text(titleKey))
    self.action = action
    self.isEnabled = isEnabled
    transform = { $0 }
  }

  /// Creates a menu command with an unlocalized title.
  ///
  /// Use this initializer for runtime strings that should be displayed
  /// verbatim.
  ///
  /// - Parameters:
  ///   - title: The command's visible and accessible title.
  ///   - isEnabled: A Boolean value that determines whether the command can be
  ///     highlighted and activated. The default is `true`.
  ///   - action: The action to perform when the user activates the command.
  public init<S: StringProtocol>(
    _ title: S,
    isEnabled: Bool = true,
    action: @escaping () -> Void
  ) {
    label = AnyView(Text(verbatim: String(title)))
    self.action = action
    self.isEnabled = isEnabled
    transform = { $0 }
  }

  /// Creates a menu command with custom SwiftUI label content.
  ///
  /// The label receives the menu's typography, foreground style, selection
  /// background, sizing, and interaction behavior.
  ///
  /// - Parameters:
  ///   - isEnabled: A Boolean value that determines whether the command can be
  ///     highlighted and activated. The default is `true`.
  ///   - action: The action to perform when the user activates the command.
  ///   - label: A view builder that creates the command's label.
  public init<Label: View>(
    isEnabled: Bool = true,
    action: @escaping () -> Void,
    @ViewBuilder label: () -> Label
  ) {
    self.label = AnyView(label())
    self.action = action
    self.isEnabled = isEnabled
    transform = { $0 }
  }

  private init(
    label: AnyView,
    action: @escaping () -> Void,
    isEnabled: Bool,
    transform: @escaping (AnyView) -> AnyView
  ) {
    self.label = label
    self.action = action
    self.isEnabled = isEnabled
    self.transform = transform
  }

  /// Applies SwiftUI modifiers to this command's completed button.
  ///
  /// Use this for command-specific accessibility identifiers, hints, focus,
  /// or keyboard shortcuts.
  ///
  /// ```swift
  /// MenuItem95("Save") {
  ///   saveDocument()
  /// }
  /// .swiftUI {
  ///   $0
  ///     .accessibilityIdentifier("file.save")
  ///     .keyboardShortcut("s", modifiers: .command)
  /// }
  /// ```
  ///
  /// Repeated calls compose in source order.
  ///
  /// - Parameter transform: A closure that receives the completed command
  ///   button and returns a modified view.
  /// - Returns: A copy of the menu item that applies the supplied transform.
  public func swiftUI<ModifiedItem: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedItem
  ) -> MenuItem95 {
    MenuItem95(
      label: label,
      action: action,
      isEnabled: isEnabled,
      transform: { item in
        AnyView(transform(self.transform(item)))
      }
    )
  }

  func transformed(_ item: AnyView) -> AnyView {
    transform(item)
  }
}

/// A visual separator between groups of commands in a ``Menu95``.
///
/// ```swift
/// Menu95("File") {
///   MenuItem95("Open") {}
///   MenuDivider95()
///   MenuItem95("Close") {}
/// }
/// ```
public struct MenuDivider95 {
  /// Creates a menu separator.
  public init() {}
}

/// An item or separator produced by ``MenuContentBuilder95``.
///
/// `MenuElement95` is the intermediate value used by the result builder.
/// Create elements through ``MenuItem95`` and ``MenuDivider95`` rather than
/// constructing this type directly.
public enum MenuElement95 {
  /// An actionable command.
  case item(MenuItem95)

  /// A visual separator between command groups.
  case divider
}

/// Builds the commands in a ``Menu95``.
///
/// Swift applies this result builder to every `Menu95` content closure. It
/// supports sequential commands, conditional commands, and commands produced
/// by loops.
@resultBuilder
public enum MenuContentBuilder95 {
  /// Adds a command to the menu content.
  ///
  /// - Parameter expression: The command to add.
  /// - Returns: A menu-element collection containing the command.
  public static func buildExpression(
    _ expression: MenuItem95
  ) -> [MenuElement95] {
    [.item(expression)]
  }

  /// Adds a divider to the menu content.
  ///
  /// - Parameter expression: The divider to add.
  /// - Returns: A menu-element collection containing the divider.
  public static func buildExpression(
    _ expression: MenuDivider95
  ) -> [MenuElement95] {
    [.divider]
  }

  /// Combines adjacent menu content.
  ///
  /// - Parameter components: The adjacent menu-element collections.
  /// - Returns: A flattened collection that preserves source order.
  public static func buildBlock(
    _ components: [MenuElement95]...
  ) -> [MenuElement95] {
    components.flatMap(\.self)
  }

  /// Supports conditional menu content without an `else` branch.
  ///
  /// - Parameter component: The conditionally produced menu elements.
  /// - Returns: The supplied elements, or an empty collection when the
  ///   condition is false.
  public static func buildOptional(
    _ component: [MenuElement95]?
  ) -> [MenuElement95] {
    component ?? []
  }

  /// Supports the first branch of conditional menu content.
  ///
  /// - Parameter component: The menu elements produced by the first branch.
  /// - Returns: The supplied menu elements.
  public static func buildEither(
    first component: [MenuElement95]
  ) -> [MenuElement95] {
    component
  }

  /// Supports the second branch of conditional menu content.
  ///
  /// - Parameter component: The menu elements produced by the second branch.
  /// - Returns: The supplied menu elements.
  public static func buildEither(
    second component: [MenuElement95]
  ) -> [MenuElement95] {
    component
  }

  /// Supports menu content produced by a loop.
  ///
  /// - Parameter components: The menu-element collections produced by each
  ///   loop iteration.
  /// - Returns: A flattened collection that preserves iteration order.
  public static func buildArray(
    _ components: [[MenuElement95]]
  ) -> [MenuElement95] {
    components.flatMap(\.self)
  }
}

/// A classic pull-down menu displayed below a workspace window's title bar.
///
/// Add menus to a ``WorkspaceWindow95`` with `menuBar95`. Menus are optional;
/// windows that don't use the modifier keep their existing content layout.
///
/// ```swift
/// WorkspaceWindow95("Untitled - Notepad", icon: {
///   Image(systemName: "note.text")
/// }) {
///   TextEditor95(text: $document)
/// }
/// .menuBar95 {
///   Menu95("File") {
///     MenuItem95("New") {
///       newDocument()
///     }
///     MenuItem95("Open…") {
///       openDocument()
///     }
///     MenuDivider95()
///     MenuItem95("Close") {
///       closeDocument()
///     }
///   }
///
///   Menu95("Edit") {
///     MenuItem95("Undo", isEnabled: canUndo) {
///       undo()
///     }
///   }
///
///   Menu95("Help") {
///     MenuItem95("About") {
///       showAbout()
///     }
///   }
/// }
/// ```
///
/// On pointer-based platforms, users can click commands and move between open
/// menus by hovering over their headers. On touch platforms, users can tap a
/// header or press it, drag through commands, and release over a highlighted
/// command to activate it.
public struct Menu95 {
  let label: AnyView
  let elements: [MenuElement95]
  private let transform: (AnyView) -> AnyView

  /// Creates a menu with a localized title.
  ///
  /// - Parameters:
  ///   - titleKey: The localized key used as the menu header's visible and
  ///     accessible title.
  ///   - content: A result-builder closure that creates the menu's commands
  ///     and dividers.
  public init(
    _ titleKey: LocalizedStringKey,
    @MenuContentBuilder95 content: () -> [MenuElement95]
  ) {
    label = AnyView(Text(titleKey))
    elements = content()
    transform = { $0 }
  }

  /// Creates a menu with an unlocalized title.
  ///
  /// Use this initializer for runtime strings that should be displayed
  /// verbatim.
  ///
  /// - Parameters:
  ///   - title: The menu header's visible and accessible title.
  ///   - content: A result-builder closure that creates the menu's commands
  ///     and dividers.
  public init<S: StringProtocol>(
    _ title: S,
    @MenuContentBuilder95 content: () -> [MenuElement95]
  ) {
    label = AnyView(Text(verbatim: String(title)))
    elements = content()
    transform = { $0 }
  }

  /// Creates a menu with custom SwiftUI header content.
  ///
  /// The label receives the menu bar's typography, foreground style,
  /// selection background, sizing, and interaction behavior.
  ///
  /// - Parameters:
  ///   - label: A view builder that creates the menu header's label.
  ///   - content: A result-builder closure that creates the menu's commands
  ///     and dividers.
  public init<Label: View>(
    @ViewBuilder label: () -> Label,
    @MenuContentBuilder95 content: () -> [MenuElement95]
  ) {
    self.label = AnyView(label())
    elements = content()
    transform = { $0 }
  }

  private init(
    label: AnyView,
    elements: [MenuElement95],
    transform: @escaping (AnyView) -> AnyView
  ) {
    self.label = label
    self.elements = elements
    self.transform = transform
  }

  /// Applies SwiftUI modifiers to this menu's completed header control.
  ///
  /// Use this for menu-specific accessibility identifiers, hints, focus,
  /// or keyboard shortcuts.
  ///
  /// ```swift
  /// Menu95("File") {
  ///   MenuItem95("New") {}
  /// }
  /// .swiftUI {
  ///   $0.accessibilityIdentifier("menu.file")
  /// }
  /// ```
  ///
  /// Repeated calls compose in source order.
  ///
  /// - Parameter transform: A closure that receives the completed menu header
  ///   control and returns a modified view.
  /// - Returns: A copy of the menu that applies the supplied transform.
  public func swiftUI<ModifiedMenu: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedMenu
  ) -> Menu95 {
    Menu95(
      label: label,
      elements: elements,
      transform: { menu in
        AnyView(transform(self.transform(menu)))
      }
    )
  }

  func transformed(_ menu: AnyView) -> AnyView {
    transform(menu)
  }
}

/// Builds the menus in a workspace window menu bar.
///
/// Swift applies this result builder to `menuBar95` content closures. It
/// supports sequential menus, conditional menus, and menus produced by loops.
@resultBuilder
public enum MenuBuilder95 {
  /// Adds a menu to the menu bar.
  ///
  /// - Parameter expression: The menu to add.
  /// - Returns: A menu collection containing the supplied menu.
  public static func buildExpression(
    _ expression: Menu95
  ) -> [Menu95] {
    [expression]
  }

  /// Combines adjacent menus.
  ///
  /// - Parameter components: The adjacent menu collections.
  /// - Returns: A flattened collection that preserves source order.
  public static func buildBlock(
    _ components: [Menu95]...
  ) -> [Menu95] {
    components.flatMap(\.self)
  }

  /// Supports a conditional menu without an `else` branch.
  ///
  /// - Parameter component: The conditionally produced menus.
  /// - Returns: The supplied menus, or an empty collection when the condition
  ///   is false.
  public static func buildOptional(
    _ component: [Menu95]?
  ) -> [Menu95] {
    component ?? []
  }

  /// Supports the first branch of a conditional menu.
  ///
  /// - Parameter component: The menus produced by the first branch.
  /// - Returns: The supplied menus.
  public static func buildEither(
    first component: [Menu95]
  ) -> [Menu95] {
    component
  }

  /// Supports the second branch of a conditional menu.
  ///
  /// - Parameter component: The menus produced by the second branch.
  /// - Returns: The supplied menus.
  public static func buildEither(
    second component: [Menu95]
  ) -> [Menu95] {
    component
  }

  /// Supports menus produced by a loop.
  ///
  /// - Parameter components: The menu collections produced by each loop
  ///   iteration.
  /// - Returns: A flattened collection that preserves iteration order.
  public static func buildArray(
    _ components: [[Menu95]]
  ) -> [Menu95] {
    components.flatMap(\.self)
  }
}
