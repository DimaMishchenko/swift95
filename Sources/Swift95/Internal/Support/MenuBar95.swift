import SwiftUI

struct MenuBar95: View {
  @Environment(\.theme95) private var theme
  @Environment(\.strings95) private var strings
  @Binding var presentedMenu: Int?
  @State private var headerFrames: [Int: CGRect] = [:]
  @State private var itemFrames: [MenuItemKey95: CGRect] = [:]
  @State private var hoveredItem: MenuItemKey95?
  @State private var dragHighlightedItem: MenuItemKey95?
  @State private var dragStartedWithPresentedMenu = false
  @State private var isTrackingDrag = false

  let menus: [Menu95]
  private let rendersPresentedMenu: Bool

  init(
    presentedMenu: Binding<Int?>,
    menus: [Menu95],
    snapshotHighlightedItem: (menu: Int, element: Int)? = nil,
    rendersPresentedMenu: Bool = true
  ) {
    _presentedMenu = presentedMenu
    self.menus = menus
    self.rendersPresentedMenu = rendersPresentedMenu
    _dragHighlightedItem = State(
      initialValue: snapshotHighlightedItem.map {
        MenuItemKey95(menu: $0.menu, element: $0.element)
      }
    )
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      HStack(spacing: 0) {
        ForEach(menus.indices, id: \.self) { menuIndex in
          menuHeader(at: menuIndex)
        }

        Spacer(minLength: 0)
      }
      .frame(height: barHeight)
      .background(theme.colors.background)

      if rendersPresentedMenu,
        let presentedMenu,
        menus.indices.contains(presentedMenu)
      {
        menuPanel(at: presentedMenu)
          .offset(
            x: panelOffsetX(for: presentedMenu),
            y: barHeight - theme.metrics.bevelWidth
          )
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .onPreferenceChange(MenuHeaderFramePreference95.self) {
      headerFrames = $0
    }
    .onPreferenceChange(MenuItemFramePreference95.self) {
      itemFrames = $0
    }
    .onKeyPress(.escape) {
      guard presentedMenu != nil else { return .ignored }
      dismiss()
      return .handled
    }
  }

  private var barHeight: CGFloat {
    max(theme.metrics.titleBarHeight, 30)
  }

  private func panelOffsetX(for menuIndex: Int) -> CGFloat {
    guard let menuMinX = headerFrames[menuIndex]?.minX,
      let barMinX = headerFrames.values.map(\.minX).min()
    else {
      return 0
    }
    return menuMinX - barMinX
  }

  private func menuHeader(at menuIndex: Int) -> some View {
    let isPresented = presentedMenu == menuIndex

    let header = menus[menuIndex].label
      .font(theme.fonts.body)
      .foregroundStyle(isPresented ? theme.colors.accentText : theme.colors.text)
      .padding(.horizontal, theme.spacing.m)
      .frame(height: barHeight)
      .background(isPresented ? theme.colors.accent : Color.clear)
      .contentShape(.rect)
      .background {
        GeometryReader { geometry in
          Color.clear.preference(
            key: MenuHeaderFramePreference95.self,
            value: [menuIndex: geometry.frame(in: .global)]
          )
        }
      }
      .onHover { isHovering in
        guard isHovering, presentedMenu != nil, !isTrackingDrag else { return }
        presentedMenu = menuIndex
        hoveredItem = nil
      }
      .highPriorityGesture(menuTrackingGesture(startingAt: menuIndex))
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isButton)
      .accessibilityAddTraits(isPresented ? .isSelected : [])
      .accessibilityValue(Text(isPresented ? strings.expanded : strings.collapsed))
      .accessibilityAction {
        if isPresented {
          dismiss()
        } else {
          presentedMenu = menuIndex
        }
      }

    return menus[menuIndex].transformed(AnyView(header))
  }

  private func menuTrackingGesture(startingAt menuIndex: Int) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .onChanged { value in
        if !isTrackingDrag {
          isTrackingDrag = true
          dragStartedWithPresentedMenu = presentedMenu == menuIndex
          presentedMenu = menuIndex
        }

        updateDragSelection(at: value.location)
      }
      .onEnded { value in
        let selectedItem = enabledItem(at: value.location)
        let shouldCloseHeader =
          selectedItem == nil
          && dragStartedWithPresentedMenu
          && headerFrames[menuIndex]?.contains(value.location) == true

        isTrackingDrag = false
        dragStartedWithPresentedMenu = false
        dragHighlightedItem = nil

        if let selectedItem {
          let item = item(for: selectedItem)
          dismiss()
          item?.action()
        } else if shouldCloseHeader {
          dismiss()
        }
      }
  }

  private func updateDragSelection(at location: CGPoint) {
    if let header = headerFrames.first(where: { $0.value.contains(location) })?.key {
      if presentedMenu != header {
        presentedMenu = header
        hoveredItem = nil
      }
      dragHighlightedItem = nil
      return
    }

    dragHighlightedItem = enabledItem(at: location)
  }

  private func enabledItem(at location: CGPoint) -> MenuItemKey95? {
    itemFrames.first { key, frame in
      key.menu == presentedMenu
        && frame.contains(location)
        && item(for: key)?.isEnabled == true
    }?
    .key
  }

  private func item(for key: MenuItemKey95) -> MenuItem95? {
    guard menus.indices.contains(key.menu) else { return nil }
    let elements = menus[key.menu].elements
    guard elements.indices.contains(key.element) else { return nil }
    guard case let .item(item) = elements[key.element] else { return nil }
    return item
  }

  func menuPanel(at menuIndex: Int) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(menus[menuIndex].elements.indices, id: \.self) { elementIndex in
        switch menus[menuIndex].elements[elementIndex] {
        case let .item(item):
          menuItem(item, key: MenuItemKey95(menu: menuIndex, element: elementIndex))
        case .divider:
          Divider95()
            .padding(.vertical, theme.spacing.xxxs)
        }
      }
    }
    .padding(theme.spacing.xxxs)
    .frame(minWidth: theme.metrics.pickerMinimumWidth, alignment: .leading)
    .fixedSize(horizontal: true, vertical: true)
    .background(theme.colors.background)
    .bevel95(.raised)
  }

  private func menuItem(
    _ item: MenuItem95,
    key: MenuItemKey95
  ) -> some View {
    let isHighlighted =
      item.isEnabled && (dragHighlightedItem == key || hoveredItem == key)

    let button = Button {
      dismiss()
      item.action()
    } label: {
      item.label
        .font(theme.fonts.body)
        .foregroundStyle(
          isHighlighted
            ? theme.colors.accentText
            : item.isEnabled ? theme.colors.text : theme.colors.textDisabled
        )
        .padding(.horizontal, theme.spacing.m)
        .frame(
          minWidth: theme.metrics.pickerMinimumWidth,
          minHeight: theme.metrics.startMenuRowHeight,
          alignment: .leading
        )
        .background(isHighlighted ? theme.colors.accent : Color.clear)
        .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .disabled(!item.isEnabled)
    .background {
      GeometryReader { geometry in
        Color.clear.preference(
          key: MenuItemFramePreference95.self,
          value: [key: geometry.frame(in: .global)]
        )
      }
    }
    .onHover { isHovering in
      guard !isTrackingDrag else { return }
      hoveredItem = isHovering && item.isEnabled ? key : nil
    }

    return item.transformed(AnyView(button))
  }

  private func dismiss() {
    presentedMenu = nil
    hoveredItem = nil
    dragHighlightedItem = nil
  }
}

private struct MenuItemKey95: Hashable {
  let menu: Int
  let element: Int
}

private struct MenuHeaderFramePreference95: PreferenceKey {
  static var defaultValue: [Int: CGRect] { [:] }

  static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
    value.merge(nextValue(), uniquingKeysWith: { _, new in new })
  }
}

private struct MenuItemFramePreference95: PreferenceKey {
  static var defaultValue: [MenuItemKey95: CGRect] { [:] }

  static func reduce(
    value: inout [MenuItemKey95: CGRect],
    nextValue: () -> [MenuItemKey95: CGRect]
  ) {
    value.merge(nextValue(), uniquingKeysWith: { _, new in new })
  }
}
