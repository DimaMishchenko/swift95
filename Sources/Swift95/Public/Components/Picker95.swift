import SwiftUI

#if os(macOS)
  import AppKit
#endif

/// A typed option displayed by ``Picker95``.
public struct PickerOption95<Value: Hashable, Label: View>: Identifiable {
  /// The value written to the picker's selection when this option is activated.
  public let value: Value

  /// The SwiftUI content displayed for this option.
  public let label: Label

  /// The value also serves as the option's stable identity.
  public var id: Value { value }

  private let transform: (AnyView) -> AnyView
  let accessibilityValue: Text?

  /// Creates an option with a custom SwiftUI label.
  ///
  /// - Parameters:
  ///   - value: The value represented by this option.
  ///   - accessibilityValue: Text that describes the option when it is selected.
  ///   - label: The content displayed in the option list.
  public init(
    value: Value,
    accessibilityValue: Text? = nil,
    @ViewBuilder label: () -> Label
  ) {
    self.value = value
    self.label = label()
    self.accessibilityValue = accessibilityValue
    transform = { $0 }
  }

  private init(
    value: Value,
    label: Label,
    accessibilityValue: Text?,
    transform: @escaping (AnyView) -> AnyView
  ) {
    self.value = value
    self.label = label
    self.accessibilityValue = accessibilityValue
    self.transform = transform
  }

  /// Applies SwiftUI modifiers to this option's completed button.
  ///
  /// Use this escape hatch for per-option configuration such as accessibility
  /// hints, identifiers, focus behavior, or keyboard shortcuts.
  ///
  /// ```swift
  /// PickerOption95("Name", value: SortOrder.name)
  ///   .swiftUI { option in
  ///     option.accessibilityHint("Sorts alphabetically")
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure that receives the styled option button.
  /// - Returns: An option that applies the transformation when displayed.
  public func swiftUI<ModifiedOption: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedOption
  ) -> PickerOption95<Value, Label> {
    PickerOption95<Value, Label>(
      value: value,
      label: label,
      accessibilityValue: accessibilityValue,
      transform: { option in
        AnyView(transform(self.transform(option)))
      }
    )
  }

  func transformed(_ option: AnyView) -> AnyView {
    transform(option)
  }
}

extension PickerOption95 where Label == Text {
  /// Creates an option with a localized text label.
  public init(_ titleKey: LocalizedStringKey, value: Value) {
    self.init(value: value, accessibilityValue: Text(titleKey)) {
      Text(titleKey)
    }
  }

  /// Creates an option with an unlocalized text label.
  public init<S>(_ title: S, value: Value) where S: StringProtocol {
    self.init(value: value, accessibilityValue: Text(verbatim: String(title))) {
      Text(verbatim: String(title))
    }
  }
}

/// A fully custom Windows 95-style value picker.
///
/// `Picker95` draws both the closed field and its option list using the active
/// ``Theme95``. The option list is presented in a separate transparent layer,
/// allowing it to appear above surrounding content without changing layout.
///
/// ```swift
/// Picker95(
///   "Sort by",
///   selection: $sortOrder,
///   options: [
///     PickerOption95("Name", value: .name),
///     PickerOption95("Date modified", value: .dateModified)
///   ]
/// )
/// ```
public struct Picker95<
  SelectionValue: Hashable,
  OptionLabel: View,
  CurrentValueLabel: View
>: View {
  @Environment(\.theme95) private var theme
  @State private var isPresented = false
  @State private var pressedOption: SelectionValue?
  @Binding private var selection: SelectionValue

  private let title: Text
  private let options: [PickerOption95<SelectionValue, OptionLabel>]
  private let currentValueLabel: (SelectionValue) -> CurrentValueLabel
  private let accessibilityValue: (SelectionValue) -> Text?
  private let triggerTransform: (AnyView) -> AnyView

  /// Creates a picker whose closed field reuses the selected option label.
  ///
  /// - Parameters:
  ///   - titleKey: The localized accessibility label for the picker.
  ///   - selection: The currently selected value.
  ///   - options: The nonempty ordered collection of available options.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<SelectionValue>,
    options: [PickerOption95<SelectionValue, OptionLabel>]
  ) where CurrentValueLabel == AnyView {
    precondition(!options.isEmpty, "Picker95 requires at least one option")
    title = Text(titleKey)
    _selection = selection
    self.options = options
    currentValueLabel = { value in
      guard let option = options.first(where: { $0.value == value }) else {
        return AnyView(EmptyView())
      }
      return AnyView(option.label)
    }
    accessibilityValue = { value in
      options.first(where: { $0.value == value })?.accessibilityValue
    }
    triggerTransform = { $0 }
  }

  /// Creates a picker whose closed field reuses the selected option label.
  ///
  /// - Parameters:
  ///   - title: The unlocalized accessibility label for the picker.
  ///   - selection: The currently selected value.
  ///   - options: The nonempty ordered collection of available options.
  public init<S>(
    _ title: S,
    selection: Binding<SelectionValue>,
    options: [PickerOption95<SelectionValue, OptionLabel>]
  ) where S: StringProtocol, CurrentValueLabel == AnyView {
    precondition(!options.isEmpty, "Picker95 requires at least one option")
    self.title = Text(verbatim: String(title))
    _selection = selection
    self.options = options
    currentValueLabel = { value in
      guard let option = options.first(where: { $0.value == value }) else {
        return AnyView(EmptyView())
      }
      return AnyView(option.label)
    }
    accessibilityValue = { value in
      options.first(where: { $0.value == value })?.accessibilityValue
    }
    triggerTransform = { $0 }
  }

  /// Creates a picker with custom content in its closed field.
  ///
  /// - Parameters:
  ///   - titleKey: The localized accessibility label for the picker.
  ///   - selection: The currently selected value.
  ///   - options: The nonempty ordered collection of available options.
  ///   - accessibilityValue: Accessible text generated for the current selection.
  ///   - currentValueLabel: Content generated for the current selection.
  public init(
    _ titleKey: LocalizedStringKey,
    selection: Binding<SelectionValue>,
    options: [PickerOption95<SelectionValue, OptionLabel>],
    accessibilityValue: @escaping (SelectionValue) -> Text,
    @ViewBuilder currentValueLabel: @escaping (SelectionValue) -> CurrentValueLabel
  ) {
    precondition(!options.isEmpty, "Picker95 requires at least one option")
    title = Text(titleKey)
    _selection = selection
    self.options = options
    self.currentValueLabel = currentValueLabel
    self.accessibilityValue = accessibilityValue
    triggerTransform = { $0 }
  }

  /// Creates a picker with custom content in its closed field.
  ///
  /// - Parameters:
  ///   - title: The unlocalized accessibility label for the picker.
  ///   - selection: The currently selected value.
  ///   - options: The nonempty ordered collection of available options.
  ///   - accessibilityValue: Accessible text generated for the current selection.
  ///   - currentValueLabel: Content generated for the current selection.
  public init<S>(
    _ title: S,
    selection: Binding<SelectionValue>,
    options: [PickerOption95<SelectionValue, OptionLabel>],
    accessibilityValue: @escaping (SelectionValue) -> Text,
    @ViewBuilder currentValueLabel: @escaping (SelectionValue) -> CurrentValueLabel
  ) where S: StringProtocol {
    precondition(!options.isEmpty, "Picker95 requires at least one option")
    self.title = Text(verbatim: String(title))
    _selection = selection
    self.options = options
    self.currentValueLabel = currentValueLabel
    self.accessibilityValue = accessibilityValue
    triggerTransform = { $0 }
  }

  private init(
    title: Text,
    selection: Binding<SelectionValue>,
    options: [PickerOption95<SelectionValue, OptionLabel>],
    currentValueLabel: @escaping (SelectionValue) -> CurrentValueLabel,
    accessibilityValue: @escaping (SelectionValue) -> Text?,
    triggerTransform: @escaping (AnyView) -> AnyView
  ) {
    self.title = title
    _selection = selection
    self.options = options
    self.currentValueLabel = currentValueLabel
    self.accessibilityValue = accessibilityValue
    self.triggerTransform = triggerTransform
  }

  /// The styled picker field and custom option presentation.
  public var body: some View {
    Group {
      #if os(iOS)
        triggerTransform(AnyView(trigger))
          .overlay {
            GeometryReader { geometry in
              let triggerFrame = geometry.frame(in: .global)

              Color.clear
                .fullScreenCover(isPresented: $isPresented) {
                  optionPresentation(triggerFrame: triggerFrame)
                }
                .transaction { transaction in
                  transaction.disablesAnimations = true
                }
            }
            .allowsHitTesting(false)
          }
      #else
        triggerTransform(AnyView(trigger))
          .background {
            MacPickerPresentation95(
              isPresented: $isPresented,
              overlap: theme.metrics.bevelWidth * 2,
              minimumWidth: theme.metrics.pickerMinimumWidth
            ) {
              optionList
            }
            .allowsHitTesting(false)
          }
      #endif
    }
    .onKeyPress(.escape) {
      guard isPresented else { return .ignored }
      pressedOption = nil
      isPresented = false
      return .handled
    }
  }

  /// Applies SwiftUI modifiers to the completed picker trigger.
  ///
  /// Use this escape hatch for trigger-specific configuration such as focus,
  /// accessibility hints, identifiers, or keyboard shortcuts.
  ///
  /// ```swift
  /// Picker95("Sort by", selection: $sortOrder, options: options)
  ///   .swiftUITrigger { trigger in
  ///     trigger.accessibilityHint("Changes the file sort order")
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure that receives the styled trigger button.
  /// - Returns: A picker that applies the transformation to its trigger.
  public func swiftUITrigger<ModifiedTrigger: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedTrigger
  ) -> Picker95<SelectionValue, OptionLabel, CurrentValueLabel> {
    Picker95<SelectionValue, OptionLabel, CurrentValueLabel>(
      title: title,
      selection: $selection,
      options: options,
      currentValueLabel: currentValueLabel,
      accessibilityValue: accessibilityValue,
      triggerTransform: { trigger in
        AnyView(transform(self.triggerTransform(trigger)))
      }
    )
  }

  private var trigger: some View {
    Button {
      pressedOption = nil
      isPresented.toggle()
    } label: {
      currentValueLabel(selection)
    }
    .buttonStyle(PickerTriggerButtonStyle95(theme: theme))
    .modifier(PickerTriggerFocusEffect95())
    .accessibilityLabel(title)
    .modifier(PickerAccessibilityValue95(value: accessibilityValue(selection)))
  }

  private func optionPresentation(triggerFrame: CGRect) -> some View {
    ZStack(alignment: .topLeading) {
      Color.black
        .opacity(0.001)
        .contentShape(.rect)
        .onTapGesture {
          pressedOption = nil
          isPresented = false
        }

      PickerOptionPresentationLayout95(
        triggerFrame: triggerFrame,
        overlap: theme.metrics.bevelWidth * 2,
        minimumWidth: theme.metrics.pickerMinimumWidth
      ) {
        optionList
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .ignoresSafeArea()
    .presentationBackground(.clear)
  }

  @ViewBuilder
  private var optionList: some View {
    PickerOptionList95(
      options: options,
      selection: $selection,
      pressedOption: $pressedOption,
      theme: theme
    ) {
      isPresented = false
    }
  }

  func snapshotOptionList95(selection: SelectionValue, theme: Theme95) -> some View {
    PickerOptionList95(
      options: options,
      selection: .constant(selection),
      pressedOption: .constant(nil),
      theme: theme,
      dismiss: {}
    )
  }
}

#if os(macOS)
  struct MacPickerPresentation95<Content: View>: NSViewRepresentable {
    @Binding var isPresented: Bool

    let overlap: CGFloat
    let minimumWidth: CGFloat
    @ViewBuilder let content: () -> Content

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
      PickerPresentationAnchor95()
    }

    func updateNSView(_ anchor: NSView, context: Context) {
      guard isPresented, anchor.window != nil else {
        context.coordinator.dismiss()
        return
      }

      context.coordinator.dismissAction = {
        isPresented = false
      }
      context.coordinator.present(
        AnyView(
          content()
            .frame(minWidth: max(anchor.bounds.width, minimumWidth))
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.self, context.environment)
        ),
        from: anchor,
        overlap: overlap
      )
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
      coordinator.dismiss()
    }

    @MainActor
    final class Coordinator {
      var dismissAction: (() -> Void)?

      private var panel: PickerPanelWindow95?
      private var localEventMonitor: Any?
      private var globalEventMonitor: Any?

      func present(_ rootView: AnyView, from anchor: NSView, overlap: CGFloat) {
        guard let parentWindow = anchor.window else { return }

        let host = NSHostingView(rootView: rootView)
        let contentSize = host.fittingSize
        host.frame = CGRect(origin: .zero, size: contentSize)

        let panel: PickerPanelWindow95
        if let currentPanel = self.panel {
          panel = currentPanel
          panel.contentView = host
          panel.setContentSize(contentSize)
        } else {
          panel = PickerPanelWindow95(
            contentRect: CGRect(origin: .zero, size: contentSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
          )
          panel.isOpaque = false
          panel.backgroundColor = .clear
          panel.hasShadow = false
          panel.hidesOnDeactivate = true
          panel.level = .popUpMenu
          panel.contentView = host
          parentWindow.addChildWindow(panel, ordered: .above)
          self.panel = panel
          installEventMonitors()
        }

        position(panel, relativeTo: anchor, overlap: overlap)
        panel.makeKeyAndOrderFront(nil)
      }

      func dismiss() {
        if let panel {
          panel.parent?.removeChildWindow(panel)
          panel.orderOut(nil)
        }
        panel = nil
        removeEventMonitors()
      }

      private func position(
        _ panel: NSPanel,
        relativeTo anchor: NSView,
        overlap: CGFloat
      ) {
        guard let window = anchor.window else { return }

        let triggerFrame = window.convertToScreen(anchor.convert(anchor.bounds, to: nil))
        let visibleFrame =
          window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? triggerFrame
        let panelSize = panel.frame.size
        let availableBelow = triggerFrame.minY - visibleFrame.minY
        let y =
          availableBelow >= panelSize.height - overlap
          ? triggerFrame.minY - panelSize.height + overlap
          : triggerFrame.maxY - overlap
        let x = min(
          max(triggerFrame.minX, visibleFrame.minX),
          max(visibleFrame.minX, visibleFrame.maxX - panelSize.width)
        )

        panel.setFrameOrigin(
          CGPoint(
            x: x,
            y: min(
              max(y, visibleFrame.minY),
              max(visibleFrame.minY, visibleFrame.maxY - panelSize.height)
            )
          )
        )
      }

      private func installEventMonitors() {
        localEventMonitor = NSEvent.addLocalMonitorForEvents(
          matching: [.leftMouseDown, .rightMouseDown, .keyDown]
        ) { [weak self] event in
          guard let self, let panel else { return event }
          if event.type == .keyDown, event.keyCode == 53 {
            dismissAction?()
            return nil
          }
          if event.window !== panel {
            dismissAction?()
          }
          return event
        }
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(
          matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
          self?.dismissAction?()
        }
      }

      private func removeEventMonitors() {
        if let localEventMonitor {
          NSEvent.removeMonitor(localEventMonitor)
        }
        if let globalEventMonitor {
          NSEvent.removeMonitor(globalEventMonitor)
        }
        localEventMonitor = nil
        globalEventMonitor = nil
      }
    }
  }

  final class PickerPanelWindow95: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
  }

  final class PickerPresentationAnchor95: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
      nil
    }
  }
#endif

private struct PickerTriggerFocusEffect95: ViewModifier {
  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(macOS)
      content.focusEffectDisabled()
    #else
      content
    #endif
  }
}

private struct PickerAccessibilityValue95: ViewModifier {
  let value: Text?

  @ViewBuilder
  func body(content: Content) -> some View {
    if let value {
      content.accessibilityValue(value)
    } else {
      content
    }
  }
}

private struct PickerOptionList95<Value: Hashable, OptionLabel: View>: View {
  let options: [PickerOption95<Value, OptionLabel>]
  @Binding var selection: Value
  @Binding var pressedOption: Value?
  let theme: Theme95
  let dismiss: () -> Void

  @ViewBuilder
  var body: some View {
    if options.count > 7 {
      ScrollView95 {
        optionRows
      }
      .frame(maxHeight: theme.metrics.pickerMaximumHeight)
    } else {
      optionRows
        .bevel95(.input)
    }
  }

  private var optionRows: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      ForEach(options) { option in
        optionRow(option)
      }
    }
  }

  private func optionRow(
    _ option: PickerOption95<Value, OptionLabel>
  ) -> some View {
    let isSelected = selection == option.value
    let button = Button {
      selection = option.value
      pressedOption = nil
      dismiss()
    } label: {
      option.label
    }
    .buttonStyle(
      PickerOptionButtonStyle95(
        pressedOption: $pressedOption,
        isSelected: isSelected,
        value: option.value,
        theme: theme
      )
    )
    .accessibilityAddTraits(isSelected ? .isSelected : [])

    return option.transformed(AnyView(button))
  }
}

struct PickerOptionButtonStyle95<Value: Hashable>: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  @Binding var pressedOption: Value?

  let isSelected: Bool
  let value: Value
  let theme: Theme95
  var forcedPressed = false

  func makeBody(configuration: Configuration) -> some View {
    let isHighlighted =
      isEnabled
      && (forcedPressed || configuration.isPressed || (isSelected && pressedOption == nil))

    configuration.label
      .font(theme.fonts.body)
      .foregroundStyle(
        isHighlighted
          ? theme.colors.accentText
          : isEnabled ? theme.colors.text : theme.colors.textDisabled
      )
      .padding(.horizontal, theme.spacing.m)
      .padding(.vertical, theme.spacing.s)
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(.rect)
      .background(
        isHighlighted
          ? theme.colors.accent
          : isEnabled ? theme.colors.inputBackground : theme.colors.inputBackgroundDisabled
      )
      .onChange(of: configuration.isPressed) { _, isPressed in
        if isPressed {
          pressedOption = value
        } else if pressedOption == value {
          pressedOption = nil
        }
      }
  }
}

struct PickerOptionPresentationLayout95: Layout {
  let triggerFrame: CGRect
  let overlap: CGFloat
  let minimumWidth: CGFloat

  init(
    triggerFrame: CGRect,
    overlap: CGFloat,
    minimumWidth: CGFloat = Metrics95.classic.pickerMinimumWidth
  ) {
    self.triggerFrame = triggerFrame
    self.overlap = overlap
    self.minimumWidth = minimumWidth
  }

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    proposal.replacingUnspecifiedDimensions()
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    guard let subview = subviews.first else {
      return
    }

    let placement = PickerOptionPlacement95.frame(
      triggerFrame: triggerFrame,
      contentSize: subview.sizeThatFits(
        ProposedViewSize(
          width: min(max(triggerFrame.width, minimumWidth), bounds.width),
          height: bounds.height
        )
      ),
      bounds: bounds,
      minimumWidth: minimumWidth,
      overlap: overlap
    )
    let width = placement.width
    let contentProposal = ProposedViewSize(width: width, height: bounds.height)
    let contentSize = subview.sizeThatFits(contentProposal)

    subview.place(
      at: placement.origin,
      anchor: .topLeading,
      proposal: ProposedViewSize(width: width, height: contentSize.height)
    )
  }
}

struct PickerTriggerButtonStyle95: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled

  let theme: Theme95
  var forcedPressed = false

  func makeBody(configuration: Configuration) -> some View {
    let isPressed = forcedPressed || configuration.isPressed

    HStack(spacing: 0) {
      configuration.label
        .font(theme.fonts.body)
        .foregroundStyle(isEnabled ? theme.colors.text : theme.colors.textDisabled)
        .padding(.horizontal, theme.spacing.s)
        .padding(.vertical, theme.spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)

      Color.clear
        .frame(
          width: theme.metrics.pickerDisclosureSize,
          height: theme.metrics.pickerDisclosureSize
        )
        .bevel95(isPressed ? .sunken : .raised)
        .overlay {
          PixelCaret95(
            color: isEnabled ? theme.colors.text : theme.colors.textDisabled
          )
          .offset(
            x: isPressed ? theme.metrics.pressedContentOffset : 0,
            y: isPressed ? theme.metrics.pressedContentOffset : 0
          )
        }
        .padding(theme.spacing.xxxs)
    }
    .contentShape(.rect)
    .bevel95(
      .input,
      background: isEnabled
        ? theme.colors.inputBackground
        : theme.colors.inputBackgroundDisabled
    )
  }
}
