import SwiftUI

/// A native SwiftUI list with Windows 95-inspired rows and scroll indicator.
///
/// `List95` is backed by `SwiftUI.List`, retaining lazy row creation, sections,
/// and accessibility. Selection rows use bound buttons and toggles so selection
/// remains available without exposing modern platform selection chrome.
/// Multiple-selection rows use
/// bound toggles so their checked state remains available without exposing
/// modern edit-mode chrome. The list replaces the native background,
/// separators, and scroll indicator with Swift95 styling.
///
/// ```swift
///   List95(items, selection: $selection, style: .largeIcon) { item in
///     Row95 {
///       Image(item.icon)
///     } label: {
///       Text95(item.title)
///     } accessory: {
///       item.hasChildren
///     }
///   }
/// ```
public struct List95: View {
  /// The visual treatment applied to a list and its ``Row95`` values.
  public enum Style: Equatable, Sendable {
    /// A tall, touch-friendly row with room for a prominent leading view.
    case largeIcon

    /// A short, text-focused row suitable for menus and action lists.
    case compact

  }

  /// A typed section supplied to a list.
  public struct Section<ID: Hashable, SectionItem>: Identifiable {
    /// The stable identity of the section.
    public let id: ID

    /// The ordered items displayed in the section.
    public let items: [SectionItem]

    /// Creates a section from any random-access collection.
    ///
    /// - Parameters:
    ///   - id: The section's stable identity.
    ///   - items: The items displayed in the section.
    public init<Items: RandomAccessCollection>(id: ID, items: Items)
    where Items.Element == SectionItem {
      self.id = id
      self.items = Array(items)
    }
  }

  private typealias Transform = (AnyView) -> AnyView
  private struct Transforms {
    let list: Transform
    let indicator: Transform
  }

  private let makeContent: (Transforms) -> AnyView
  private let listTransform: Transform
  private let indicatorTransform: Transform

  /// Creates a list with no selection binding.
  ///
  /// - Parameters:
  ///   - items: The identifiable items displayed by the list.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95`` between
  ///     adjacent rows. This value has no effect on large-icon rows.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - rowContent: A styled row generated for each item.
  public init<Data: RandomAccessCollection, RowContent: View>(
    _ items: Data,
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) where Data.Element: Identifiable {
    let storedItems = Array(items)
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: [ListSectionStorage(id: AnyHashable(0), items: storedItems, header: nil)],
          isSectioned: false,
          selection: .none,
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// Creates a list with single selection.
  ///
  /// - Parameters:
  ///   - items: The identifiable items displayed by the list.
  ///   - selection: The selected item identity, or `nil` for no selection.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95``.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - rowContent: A styled row generated for each item.
  public init<Data: RandomAccessCollection, RowContent: View>(
    _ items: Data,
    selection: Binding<Data.Element.ID?>,
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) where Data.Element: Identifiable {
    let storedItems = Array(items)
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: [ListSectionStorage(id: AnyHashable(0), items: storedItems, header: nil)],
          isSectioned: false,
          selection: .single(selection),
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// Creates a list with accessible, always-available multiple selection.
  ///
  /// - Parameters:
  ///   - items: The identifiable items displayed by the list.
  ///   - selection: The set of selected item identities.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95``.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - rowContent: A styled row generated for each item.
  public init<Data: RandomAccessCollection, RowContent: View>(
    _ items: Data,
    selection: Binding<Set<Data.Element.ID>>,
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
  ) where Data.Element: Identifiable {
    let storedItems = Array(items)
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: [ListSectionStorage(id: AnyHashable(0), items: storedItems, header: nil)],
          isSectioned: false,
          selection: .multiple(selection),
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// Creates a sectioned list with no selection binding.
  ///
  /// ```swift
  ///   List95(sections, style: .compact) { section in
  ///     Text95(section.id)
  ///   } rowContent: { item in
  ///     Row95 { Text95(item.title) }
  ///   }
  /// ```
  ///
  /// - Parameters:
  ///   - sections: The typed sections and their items.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95``.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - header: SwiftUI content generated for each section header.
  ///   - rowContent: A styled row generated for each item.
  public init<SectionID: Hashable, Item: Identifiable, Header: View, RowContent: View>(
    _ sections: [Section<SectionID, Item>],
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder header: (Section<SectionID, Item>) -> Header,
    @ViewBuilder rowContent: @escaping (Item) -> RowContent
  ) {
    let storedSections = sections.map { section in
      ListSectionStorage(
        id: AnyHashable(section.id),
        items: section.items,
        header: AnyView(header(section))
      )
    }
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: storedSections,
          isSectioned: true,
          selection: .none,
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// Creates a sectioned list with single selection.
  ///
  /// - Parameters:
  ///   - sections: The typed sections and their items.
  ///   - selection: The selected item identity, or `nil` for no selection.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95``.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - header: SwiftUI content generated for each section header.
  ///   - rowContent: A styled row generated for each item.
  public init<SectionID: Hashable, Item: Identifiable, Header: View, RowContent: View>(
    _ sections: [Section<SectionID, Item>],
    selection: Binding<Item.ID?>,
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder header: (Section<SectionID, Item>) -> Header,
    @ViewBuilder rowContent: @escaping (Item) -> RowContent
  ) {
    let storedSections = sections.map { section in
      ListSectionStorage(
        id: AnyHashable(section.id),
        items: section.items,
        header: AnyView(header(section))
      )
    }
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: storedSections,
          isSectioned: true,
          selection: .single(selection),
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// Creates a sectioned list with accessible, always-available multiple selection.
  ///
  /// - Parameters:
  ///   - sections: The typed sections and their items.
  ///   - selection: The set of selected item identities.
  ///   - style: The row layout and spacing treatment.
  ///   - showsSeparators: Whether compact rows display ``Divider95``.
  ///   - showsIndicator: Whether to display the classic scroll indicator.
  ///   - showsBevel: Whether to draw the raised border around the list.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - header: SwiftUI content generated for each section header.
  ///   - rowContent: A styled row generated for each item.
  public init<SectionID: Hashable, Item: Identifiable, Header: View, RowContent: View>(
    _ sections: [Section<SectionID, Item>],
    selection: Binding<Set<Item.ID>>,
    style: Style = .largeIcon,
    showsSeparators: Bool = false,
    showsIndicator: Bool = true,
    showsBevel: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder header: (Section<SectionID, Item>) -> Header,
    @ViewBuilder rowContent: @escaping (Item) -> RowContent
  ) {
    let storedSections = sections.map { section in
      ListSectionStorage(
        id: AnyHashable(section.id),
        items: section.items,
        header: AnyView(header(section))
      )
    }
    makeContent = { transforms in
      AnyView(
        ListContent(
          sections: storedSections,
          isSectioned: true,
          selection: .multiple(selection),
          style: style,
          showsSeparators: showsSeparators,
          showsIndicator: showsIndicator,
          showsBevel: showsBevel,
          lineIncrement: lineIncrement,
          rowContent: rowContent,
          listTransform: transforms.list,
          indicatorTransform: transforms.indicator
        )
      )
    }
    listTransform = { $0 }
    indicatorTransform = { $0 }
  }

  /// The styled native list and classic scroll indicator.
  public var body: some View {
    makeContent(Transforms(list: listTransform, indicator: indicatorTransform))
  }

  /// Applies SwiftUI modifiers to the completed native `List`.
  ///
  /// ```swift
  ///   List95(items) { item in
  ///     Row95 { Text95(item.title) }
  ///   }
  ///   .swiftUI { list in
  ///     list.refreshable { await reload() }
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure receiving the configured native list.
  /// - Returns: A list that applies the transformation.
  public func swiftUI<ModifiedList: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedList
  ) -> List95 {
    List95(
      makeContent: makeContent,
      listTransform: { list in AnyView(transform(self.listTransform(list))) },
      indicatorTransform: indicatorTransform
    )
  }

  /// Applies SwiftUI modifiers to the completed classic scroll indicator.
  ///
  /// - Parameter transform: A closure receiving the connected indicator.
  /// - Returns: A list that applies the transformation.
  public func swiftUIIndicator<ModifiedIndicator: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedIndicator
  ) -> List95 {
    List95(
      makeContent: makeContent,
      listTransform: listTransform,
      indicatorTransform: { indicator in
        AnyView(transform(self.indicatorTransform(indicator)))
      }
    )
  }

  private init(
    makeContent: @escaping (Transforms) -> AnyView,
    listTransform: @escaping Transform,
    indicatorTransform: @escaping Transform
  ) {
    self.makeContent = makeContent
    self.listTransform = listTransform
    self.indicatorTransform = indicatorTransform
  }
}

private struct ListContent<Item: Identifiable, RowContent: View>: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.theme95) private var theme
  @State private var pressedID: Item.ID?

  let sections: [ListSectionStorage<Item>]
  let isSectioned: Bool
  let selection: ListSelection<Item.ID>
  let style: List95.Style
  let showsSeparators: Bool
  let showsIndicator: Bool
  let showsBevel: Bool
  let lineIncrement: CGFloat?
  let rowContent: (Item) -> RowContent
  let listTransform: (AnyView) -> AnyView
  let indicatorTransform: (AnyView) -> AnyView

  var body: some View {
    NativeVerticalScrollContainer(
      scroll: listTransform(AnyView(nativeList)),
      showsIndicator: showsIndicator,
      lineIncrement: lineIncrement,
      bevelStyle: showsBevel ? .raised : nil,
      indicatorTransform: indicatorTransform
    )
  }

  @ViewBuilder
  private var nativeList: some View {
    switch selection {
    case .none:
      styled(List { listContent })
    case .single:
      styled(List { listContent })
    case .multiple:
      styled(List { listContent })
    }
  }

  private func styled<Content: View>(_ list: Content) -> some View {
    list
      .listStyle(.plain)
      .environment(\.defaultMinListRowHeight, minimumListRowHeight)
      .scrollContentBackground(.hidden)
      .scrollIndicators(.hidden)
      .background(theme.colors.background)
  }

  private var minimumListRowHeight: CGFloat {
    #if os(macOS)
      1
    #else
      0
    #endif
  }

  @ViewBuilder
  private var listContent: some View {
    if isSectioned {
      ForEach(sections) { section in
        SwiftUI.Section {
          if let header = section.header {
            scrollingHeader(header)
          }
          rows(in: section)
        }
      }
    } else if let section = sections.first {
      rows(in: section)
    }
  }

  private func scrollingHeader(_ header: AnyView) -> some View {
    header
      .font(theme.fonts.body)
      .foregroundStyle(theme.colors.text)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, style == .largeIcon ? theme.spacing.m : theme.spacing.s)
      .padding(.vertical, theme.spacing.m)
      .background(theme.colors.background)
      .accessibilityAddTraits(.isHeader)
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
  }

  @ViewBuilder
  private func rows(in section: ListSectionStorage<Item>) -> some View {
    ForEach(section.items) { item in
      let isLast = item.id == section.items.last?.id
      switch selection {
      case .none:
        configuredRow(item, isLast: isLast)
          .buttonStyle(ListRowInteractionButtonStyle(id: item.id, pressedID: $pressedID))
          .listRowInsets(EdgeInsets())
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
      case .single:
        Button {
          selection.select(item.id)
        } label: {
          configuredRow(item, isLast: isLast)
        }
        .buttonStyle(ListRowInteractionButtonStyle(id: item.id, pressedID: $pressedID))
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .accessibilityAddTraits(selection.contains(item.id) ? .isSelected : [])
      case .multiple:
        Toggle(isOn: selection.binding(for: item.id)) {
          configuredRow(item, isLast: isLast)
        }
        .toggleStyle(ListRowSelectionToggleStyle(id: item.id, pressedID: $pressedID))
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
    }
  }

  private func configuredRow(_ item: Item, isLast: Bool) -> some View {
    rowContent(item)
      .environment(\.list95Style, style)
      .environment(\.list95ShowsSelectionMark, selection.isMultiple)
      .environment(\.list95IsSelected, selection.contains(item.id))
      .environment(\.list95IsPressed, pressedID == item.id)
      .environment(
        \.list95IsHighlighted,
        isHighlighted(item.id)
      )
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(.rect)
      .background(isHighlighted(item.id) ? theme.colors.accent : theme.colors.background)
      .animation(
        reduceMotion ? nil : .easeOut(duration: theme.motion.feedback),
        value: isHighlighted(item.id)
      )
      .overlay(alignment: .bottom) {
        if style == .compact, showsSeparators, !isLast {
          Divider95()
        }
      }
  }

  private func isHighlighted(_ id: Item.ID) -> Bool {
    ListSelectionHighlight.isHighlighted(
      id: id,
      selected: selection.highlightsSelectedRows && selection.contains(id),
      pressedID: pressedID
    )
  }
}

/// A styled row for ``List95`` with optional leading and accessory regions.
public struct Row95<Label: View>: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.list95IsHighlighted) private var isHighlighted
  @Environment(\.list95IsPressed) private var isPressed
  @Environment(\.list95IsSelected) private var isSelected
  @Environment(\.list95ShowsSelectionMark) private var showsSelectionMark
  @Environment(\.list95Style) private var style
  @Environment(\.theme95) private var theme

  private let leading: AnyView?
  private let label: Label
  private let accessory: AnyView?
  private let rowTransform: (AnyView) -> AnyView

  /// Creates a row with arbitrary leading, label, and accessory content.
  ///
  /// - Parameters:
  ///   - leading: Optional content displayed before the primary label.
  ///   - label: The row's primary content.
  ///   - accessory: Optional content displayed after the primary label.
  public init<Leading: View, Accessory: View>(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder label: () -> Label,
    @ViewBuilder accessory: () -> Accessory
  ) {
    self.leading = AnyView(leading())
    self.label = label()
    self.accessory = AnyView(accessory())
    rowTransform = { $0 }
  }

  /// Creates a row with a Boolean disclosure accessory.
  ///
  /// - Parameters:
  ///   - leading: Optional content displayed before the primary label.
  ///   - label: The row's primary content.
  ///   - accessory: Whether to show the classic disclosure arrow.
  public init<Leading: View>(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder label: () -> Label,
    accessory: () -> Bool
  ) {
    self.leading = AnyView(leading())
    self.label = label()
    self.accessory = accessory() ? AnyView(ListDisclosure()) : nil
    rowTransform = { $0 }
  }

  /// Creates a row without leading content and with an arbitrary accessory.
  ///
  /// - Parameters:
  ///   - label: The row's primary content.
  ///   - accessory: Content displayed after the primary label.
  public init<Accessory: View>(
    @ViewBuilder label: () -> Label,
    @ViewBuilder accessory: () -> Accessory
  ) {
    leading = nil
    self.label = label()
    self.accessory = AnyView(accessory())
    rowTransform = { $0 }
  }

  /// Creates a row without leading content and with a Boolean disclosure accessory.
  ///
  /// - Parameters:
  ///   - label: The row's primary content.
  ///   - accessory: Whether to show the classic disclosure arrow.
  public init(
    @ViewBuilder label: () -> Label,
    accessory: () -> Bool
  ) {
    leading = nil
    self.label = label()
    self.accessory = accessory() ? AnyView(ListDisclosure()) : nil
    rowTransform = { $0 }
  }

  /// Creates a row with arbitrary leading content and no accessory.
  ///
  /// - Parameters:
  ///   - leading: Content displayed before the primary label.
  ///   - label: The row's primary content.
  public init<Leading: View>(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder label: () -> Label
  ) {
    self.leading = AnyView(leading())
    self.label = label()
    accessory = nil
    rowTransform = { $0 }
  }

  /// Creates a text-focused row without leading or accessory content.
  ///
  /// - Parameter label: The row's primary content.
  public init(@ViewBuilder label: () -> Label) {
    leading = nil
    self.label = label()
    accessory = nil
    rowTransform = { $0 }
  }

  /// The completed styled row.
  public var body: some View {
    rowTransform(AnyView(styledRow))
  }

  /// Applies SwiftUI modifiers to the completed styled row.
  ///
  /// ```swift
  ///   Row95 { Text95("Open") }
  ///     .swiftUI { row in
  ///       row.accessibilityHint("Opens the selected document")
  ///     }
  /// ```
  ///
  /// - Parameter transform: A closure receiving the styled row.
  /// - Returns: A row that applies the transformation.
  public func swiftUI<ModifiedRow: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedRow
  ) -> Row95<Label> {
    Row95<Label>(
      leading: leading,
      label: label,
      accessory: accessory,
      rowTransform: { row in AnyView(transform(self.rowTransform(row))) }
    )
  }

  /// Adds an etched ``Divider95`` below a compact row.
  ///
  /// Use separators to divide related menu actions instead of drawing a line
  /// after every compact row.
  ///
  /// ```swift
  ///   Row95 { Text95("Refresh") }
  ///     .separator()
  /// ```
  ///
  /// - Parameter isVisible: Whether the separator is displayed.
  /// - Returns: A row with an optional compact separator.
  public func separator(_ isVisible: Bool = true) -> Row95<Label> {
    Row95<Label>(
      leading: leading,
      label: label,
      accessory: accessory,
      rowTransform: { row in
        AnyView(
          self.rowTransform(row)
            .overlay(alignment: .bottom) {
              if isVisible {
                ListRowSeparator()
              }
            }
        )
      }
    )
  }

  private init(
    leading: AnyView?,
    label: Label,
    accessory: AnyView?,
    rowTransform: @escaping (AnyView) -> AnyView
  ) {
    self.leading = leading
    self.label = label
    self.accessory = accessory
    self.rowTransform = rowTransform
  }

  private var styledRow: some View {
    HStack(spacing: style == .largeIcon ? theme.spacing.m : theme.spacing.s) {
      if showsSelectionMark {
        CheckmarkDrawing95(
          color: foregroundColor,
          size: style == .largeIcon
            ? theme.metrics.listLargeSelectionMarkSize
            : theme.metrics.listCompactSelectionMarkSize
        )
        .opacity(isSelected ? 1 : 0)
        .frame(
          width: style == .largeIcon
            ? theme.metrics.listLargeSelectionMarkSize
            : theme.metrics.listCompactSelectionMarkSize
        )
      }

      if let leading {
        leading
          .frame(
            width: style == .largeIcon
              ? theme.metrics.listLargeIconSize : theme.metrics.listCompactIconSize,
            height: style == .largeIcon
              ? theme.metrics.listLargeIconSize : theme.metrics.listCompactIconSize
          )
      }

      label
        .frame(maxWidth: .infinity, alignment: .leading)

      if let accessory {
        accessory
      }
    }
    .font(theme.fonts.body)
    .foregroundStyle(foregroundColor)
    .environment(\.foregroundColor95, foregroundColor)
    .padding(.horizontal, style == .largeIcon ? theme.spacing.m : theme.spacing.s)
    .padding(.vertical, style == .largeIcon ? theme.spacing.s : theme.spacing.xxxs)
    .frame(
      minHeight: style == .largeIcon
        ? theme.metrics.listLargeRowHeight : theme.metrics.listCompactRowHeight
    )
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(isHighlighted ? theme.colors.accent : theme.colors.background)
    .contentShape(.rect)
  }

  private var foregroundColor: Color {
    if !isEnabled {
      return theme.colors.textDisabled
    }
    return isHighlighted ? theme.colors.accentText : theme.colors.text
  }
}

private struct ListSectionStorage<Item>: Identifiable {
  let id: AnyHashable
  let items: [Item]
  let header: AnyView?
}

enum ListSelection<ID: Hashable> {
  case none
  case single(Binding<ID?>)
  case multiple(Binding<Set<ID>>)

  var isMultiple: Bool {
    if case .multiple = self { return true }
    return false
  }

  var highlightsSelectedRows: Bool {
    if case .single = self { return true }
    return false
  }

  func contains(_ id: ID) -> Bool {
    switch self {
    case .none: false
    case let .single(selection): selection.wrappedValue == id
    case let .multiple(selection): selection.wrappedValue.contains(id)
    }
  }

  func binding(for id: ID) -> Binding<Bool> {
    guard case let .multiple(selection) = self else {
      return .constant(false)
    }

    let box = ListSelectionBindingBox(selection: selection, id: id)

    return Binding(
      get: { box.value },
      set: { box.value = $0 }
    )
  }

  func select(_ id: ID) {
    guard case let .single(selection) = self else { return }
    selection.wrappedValue = id
  }
}

private final class ListSelectionBindingBox: @unchecked Sendable {
  private let getValue: () -> Bool
  private let setValue: (Bool) -> Void

  init<ID: Hashable>(selection: Binding<Set<ID>>, id: ID) {
    getValue = { selection.wrappedValue.contains(id) }
    setValue = { isSelected in
      var values = selection.wrappedValue
      if isSelected {
        values.insert(id)
      } else {
        values.remove(id)
      }
      selection.wrappedValue = values
    }
  }

  var value: Bool {
    get { getValue() }
    set { setValue(newValue) }
  }
}

private struct ListRowSelectionToggleStyle<ID: Hashable>: ToggleStyle {
  let id: ID
  @Binding var pressedID: ID?

  func makeBody(configuration: Configuration) -> some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      configuration.label
    }
    .buttonStyle(ListRowInteractionButtonStyle(id: id, pressedID: $pressedID))
  }
}

private struct ListRowInteractionButtonStyle<ID: Hashable>: ButtonStyle {
  let id: ID
  @Binding var pressedID: ID?

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .onChange(of: configuration.isPressed) { _, isPressed in
        updatePressedState(isPressed)
      }
      .onDisappear { updatePressedState(false) }
  }

  private func updatePressedState(_ isPressed: Bool) {
    if isPressed {
      pressedID = id
    } else if pressedID == id {
      pressedID = nil
    }
  }
}

struct ListSelectionHighlight {
  static func isHighlighted<ID: Hashable>(
    id: ID,
    selected: Bool,
    pressedID: ID?
  ) -> Bool {
    if let pressedID {
      return id == pressedID
    }
    return selected
  }
}

private struct ListStyleKey: EnvironmentKey {
  static let defaultValue = List95.Style.largeIcon
}

private struct ListIsHighlightedKey: EnvironmentKey {
  static let defaultValue = false
}

private struct ListIsSelectedKey: EnvironmentKey {
  static let defaultValue = false
}

private struct ListIsPressedKey: EnvironmentKey {
  static let defaultValue = false
}

private struct ListShowsSelectionMarkKey: EnvironmentKey {
  static let defaultValue = false
}

private extension EnvironmentValues {
  var list95Style: List95.Style {
    get { self[ListStyleKey.self] }
    set { self[ListStyleKey.self] = newValue }
  }

  var list95IsHighlighted: Bool {
    get { self[ListIsHighlightedKey.self] }
    set { self[ListIsHighlightedKey.self] = newValue }
  }

  var list95IsSelected: Bool {
    get { self[ListIsSelectedKey.self] }
    set { self[ListIsSelectedKey.self] = newValue }
  }

  var list95IsPressed: Bool {
    get { self[ListIsPressedKey.self] }
    set { self[ListIsPressedKey.self] = newValue }
  }

  var list95ShowsSelectionMark: Bool {
    get { self[ListShowsSelectionMarkKey.self] }
    set { self[ListShowsSelectionMarkKey.self] = newValue }
  }
}

extension Row95 {
  func snapshotState95(
    style: List95.Style,
    isHighlighted: Bool = false,
    isSelected: Bool = false,
    isPressed: Bool = false,
    showsSelectionMark: Bool = false
  ) -> some View {
    environment(\.list95Style, style)
      .environment(\.list95IsHighlighted, isHighlighted)
      .environment(\.list95IsSelected, isSelected)
      .environment(\.list95IsPressed, isPressed)
      .environment(\.list95ShowsSelectionMark, showsSelectionMark)
  }
}

private struct ListDisclosure: View {
  @Environment(\.list95IsHighlighted) private var isHighlighted
  @Environment(\.theme95) private var theme

  var body: some View {
    Canvas { context, _ in
      for column in 0..<4 {
        let height = CGFloat(column * 2 + 1)
        context.fill(
          Path(
            CGRect(
              x: CGFloat(3 - column),
              y: (7 - height) / 2,
              width: 1,
              height: height
            )
          ),
          with: .color(isHighlighted ? theme.colors.accentText : theme.colors.text)
        )
      }
    }
    .frame(width: 4, height: 7)
    .accessibilityHidden(true)
  }
}

private struct ListRowSeparator: View {
  @Environment(\.list95Style) private var style

  var body: some View {
    if style == .compact {
      Divider95()
    }
  }
}
