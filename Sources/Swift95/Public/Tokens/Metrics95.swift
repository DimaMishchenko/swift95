import CoreGraphics

/// Stable measurements shared by Swift95 components.
///
/// Metrics describe visible component geometry, not minimum interaction sizes.
/// Start with ``classic`` when creating a theme with only a few adjusted
/// measurements.
///
/// ```swift
/// var metrics = Metrics95.classic
/// metrics.scrollBarWidth = 19
/// ```
public struct Metrics95: Sendable {
  /// The width of one bevel edge.
  public var bevelWidth: CGFloat
  /// The visible checkbox indicator size.
  public var checkboxSize: CGFloat
  /// The visible radio indicator size.
  public var radioButtonSize: CGFloat
  /// The visible scrollbar width.
  public var scrollBarWidth: CGFloat
  /// The minimum visible scrollbar thumb length.
  public var scrollThumbMinimumLength: CGFloat
  /// The minimum distance moved by a scrollbar line action.
  public var scrollLineIncrementMinimum: CGFloat
  /// The default progress bar height.
  public var progressBarHeight: CGFloat
  /// The default window title bar height.
  public var titleBarHeight: CGFloat
  /// The window title bar height in compact presentations.
  public var compactTitleBarHeight: CGFloat
  /// The default taskbar height.
  public var taskbarHeight: CGFloat
  /// The height of controls within the taskbar.
  public var taskbarItemHeight: CGFloat
  /// The displacement applied to content while a control is pressed.
  public var pressedContentOffset: CGFloat
  /// The inset between progress content and its sunken frame.
  public var progressContentInset: CGFloat
  /// The amount the tab strip overlaps its connected content panel.
  public var tabStripOverlap: CGFloat
  /// The visible slider thumb width.
  public var sliderThumbWidth: CGFloat
  /// The visible slider track height.
  public var sliderTrackHeight: CGFloat
  /// The visible slider control height.
  public var sliderControlHeight: CGFloat
  /// The Start menu width.
  public var startMenuWidth: CGFloat
  /// The minimum height of a Start menu command.
  public var startMenuRowHeight: CGFloat
  /// The minimum width of a picker field and option list.
  public var pickerMinimumWidth: CGFloat
  /// The maximum height of a long picker option list.
  public var pickerMaximumHeight: CGFloat
  /// The visible width and height of the picker disclosure button.
  public var pickerDisclosureSize: CGFloat
  /// The Start icon size in the taskbar.
  public var taskbarStartIconSize: CGFloat
  /// The window icon size in a taskbar item.
  public var taskbarIconSize: CGFloat
  /// The minimum width of a taskbar task button.
  public var taskbarButtonMinimumWidth: CGFloat
  /// The maximum width of a taskbar task button.
  public var taskbarButtonMaximumWidth: CGFloat
  /// The opacity of a minimized task.
  public var taskbarMinimizedOpacity: Double
  /// The desktop shortcut icon size.
  public var desktopIconSize: CGFloat
  /// The desktop shortcut cell width.
  public var desktopShortcutWidth: CGFloat
  /// The opacity of a desktop shortcut's drag preview.
  public var desktopDragPreviewOpacity: Double
  /// The title-bar icon size in compact windows.
  public var compactTitleBarIconSize: CGFloat
  /// The title-bar icon size in windowed presentations.
  public var titleBarIconSize: CGFloat
  /// The visible window-control glyph button width.
  public var windowControlWidth: CGFloat
  /// The visible window-control glyph button height.
  public var windowControlHeight: CGFloat
  /// The minimum interactive width of a window control.
  public var windowControlMinimumWidth: CGFloat
  /// The status bar height.
  public var statusBarHeight: CGFloat
  /// The visible resize-handle size.
  public var resizeHandleSize: CGFloat
  /// The selection-mark size in a large list row.
  public var listLargeSelectionMarkSize: CGFloat
  /// The selection-mark size in a compact list row.
  public var listCompactSelectionMarkSize: CGFloat
  /// The icon size in a large list row.
  public var listLargeIconSize: CGFloat
  /// The icon size in a compact list row.
  public var listCompactIconSize: CGFloat
  /// The minimum height of a large list row.
  public var listLargeRowHeight: CGFloat
  /// The minimum height of a compact list row.
  public var listCompactRowHeight: CGFloat
  /// The width of a progress segment or indeterminate block.
  public var progressSegmentWidth: CGFloat
  /// The gap between progress segments.
  public var progressSegmentGap: CGFloat
  /// The number of blocks in the indeterminate indicator.
  public var indeterminateProgressBlockCount: Int

  /// Creates a set of component measurements.
  ///
  /// - Parameters:
  ///   - bevelWidth: The width of one bevel edge.
  ///   - checkboxSize: The visible checkbox indicator size.
  ///   - radioButtonSize: The visible radio indicator size.
  ///   - scrollBarWidth: The visible scrollbar width.
  ///   - scrollThumbMinimumLength: The minimum visible scrollbar thumb length.
  ///   - scrollLineIncrementMinimum: The minimum distance moved by a scrollbar line action.
  ///   - progressBarHeight: The default progress bar height.
  ///   - titleBarHeight: The default window title bar height.
  ///   - compactTitleBarHeight: The window title bar height in compact presentations.
  ///   - taskbarHeight: The default taskbar height.
  ///   - taskbarItemHeight: The height of controls within the taskbar.
  ///   - pressedContentOffset: The displacement applied to pressed control content.
  ///   - progressContentInset: The inset between progress content and its frame.
  ///   - tabStripOverlap: The overlap between the tab strip and content panel.
  ///   - sliderThumbWidth: The visible slider thumb width.
  ///   - sliderTrackHeight: The visible slider track height.
  ///   - sliderControlHeight: The slider control's layout height.
  ///   - startMenuWidth: The width of the Start menu.
  ///   - startMenuRowHeight: The minimum height of a Start menu row.
  ///   - pickerMinimumWidth: The minimum width of a picker menu.
  ///   - pickerMaximumHeight: The maximum height of a picker menu.
  ///   - pickerDisclosureSize: The picker disclosure-glyph size.
  ///   - taskbarStartIconSize: The Start button icon size.
  ///   - taskbarIconSize: The taskbar window icon size.
  ///   - taskbarButtonMinimumWidth: The minimum taskbar window-button width.
  ///   - taskbarButtonMaximumWidth: The maximum taskbar window-button width.
  ///   - taskbarMinimizedOpacity: The opacity of minimized taskbar items.
  ///   - desktopIconSize: The desktop shortcut icon size.
  ///   - desktopShortcutWidth: The desktop shortcut layout width.
  ///   - desktopDragPreviewOpacity: The opacity of a dragged desktop shortcut.
  ///   - compactTitleBarIconSize: The title-bar icon size in compact presentations.
  ///   - titleBarIconSize: The title-bar icon size in windowed presentations.
  ///   - windowControlWidth: The visible width of a window-control glyph.
  ///   - windowControlHeight: The visible height of a window-control glyph.
  ///   - windowControlMinimumWidth: The minimum window-control layout width.
  ///   - statusBarHeight: The visible window status-bar height.
  ///   - resizeHandleSize: The visible window resize-handle size.
  ///   - listLargeSelectionMarkSize: The selection-mark size for large list rows.
  ///   - listCompactSelectionMarkSize: The selection-mark size for compact list rows.
  ///   - listLargeIconSize: The icon size for large list rows.
  ///   - listCompactIconSize: The icon size for compact list rows.
  ///   - listLargeRowHeight: The minimum height of a large list row.
  ///   - listCompactRowHeight: The minimum height of a compact list row.
  ///   - progressSegmentWidth: The width of a progress segment.
  ///   - progressSegmentGap: The gap between progress segments.
  ///   - indeterminateProgressBlockCount: The number of indeterminate progress blocks.
  public init(
    bevelWidth: CGFloat,
    checkboxSize: CGFloat,
    radioButtonSize: CGFloat,
    scrollBarWidth: CGFloat,
    scrollThumbMinimumLength: CGFloat = 17,
    scrollLineIncrementMinimum: CGFloat = 20,
    progressBarHeight: CGFloat,
    titleBarHeight: CGFloat,
    compactTitleBarHeight: CGFloat = 44,
    taskbarHeight: CGFloat,
    taskbarItemHeight: CGFloat = 34,
    pressedContentOffset: CGFloat = 1,
    progressContentInset: CGFloat = 2,
    tabStripOverlap: CGFloat = 2,
    sliderThumbWidth: CGFloat = 18,
    sliderTrackHeight: CGFloat = 6,
    sliderControlHeight: CGFloat = 28,
    startMenuWidth: CGFloat = 280,
    startMenuRowHeight: CGFloat = 38,
    pickerMinimumWidth: CGFloat = 160,
    pickerMaximumHeight: CGFloat = 280,
    pickerDisclosureSize: CGFloat = 24,
    taskbarStartIconSize: CGFloat = 22,
    taskbarIconSize: CGFloat = 20,
    taskbarButtonMinimumWidth: CGFloat = 96,
    taskbarButtonMaximumWidth: CGFloat = 190,
    taskbarMinimizedOpacity: Double = 0.82,
    desktopIconSize: CGFloat = 42,
    desktopShortcutWidth: CGFloat = 88,
    desktopDragPreviewOpacity: Double = 0.62,
    compactTitleBarIconSize: CGFloat = 24,
    titleBarIconSize: CGFloat = 18,
    windowControlWidth: CGFloat = 24,
    windowControlHeight: CGFloat = 22,
    windowControlMinimumWidth: CGFloat = 32,
    statusBarHeight: CGFloat = 28,
    resizeHandleSize: CGFloat = 24,
    listLargeSelectionMarkSize: CGFloat = 14,
    listCompactSelectionMarkSize: CGFloat = 12,
    listLargeIconSize: CGFloat = 32,
    listCompactIconSize: CGFloat = 18,
    listLargeRowHeight: CGFloat = 48,
    listCompactRowHeight: CGFloat = 24,
    progressSegmentWidth: CGFloat = 10,
    progressSegmentGap: CGFloat = 2,
    indeterminateProgressBlockCount: Int = 3
  ) {
    self.bevelWidth = bevelWidth
    self.checkboxSize = checkboxSize
    self.radioButtonSize = radioButtonSize
    self.scrollBarWidth = scrollBarWidth
    self.scrollThumbMinimumLength = scrollThumbMinimumLength
    self.scrollLineIncrementMinimum = scrollLineIncrementMinimum
    self.progressBarHeight = progressBarHeight
    self.titleBarHeight = titleBarHeight
    self.compactTitleBarHeight = compactTitleBarHeight
    self.taskbarHeight = taskbarHeight
    self.taskbarItemHeight = taskbarItemHeight
    self.pressedContentOffset = pressedContentOffset
    self.progressContentInset = progressContentInset
    self.tabStripOverlap = tabStripOverlap
    self.sliderThumbWidth = sliderThumbWidth
    self.sliderTrackHeight = sliderTrackHeight
    self.sliderControlHeight = sliderControlHeight
    self.startMenuWidth = startMenuWidth
    self.startMenuRowHeight = startMenuRowHeight
    self.pickerMinimumWidth = pickerMinimumWidth
    self.pickerMaximumHeight = pickerMaximumHeight
    self.pickerDisclosureSize = pickerDisclosureSize
    self.taskbarStartIconSize = taskbarStartIconSize
    self.taskbarIconSize = taskbarIconSize
    self.taskbarButtonMinimumWidth = taskbarButtonMinimumWidth
    self.taskbarButtonMaximumWidth = taskbarButtonMaximumWidth
    self.taskbarMinimizedOpacity = taskbarMinimizedOpacity
    self.desktopIconSize = desktopIconSize
    self.desktopShortcutWidth = desktopShortcutWidth
    self.desktopDragPreviewOpacity = desktopDragPreviewOpacity
    self.compactTitleBarIconSize = compactTitleBarIconSize
    self.titleBarIconSize = titleBarIconSize
    self.windowControlWidth = windowControlWidth
    self.windowControlHeight = windowControlHeight
    self.windowControlMinimumWidth = windowControlMinimumWidth
    self.statusBarHeight = statusBarHeight
    self.resizeHandleSize = resizeHandleSize
    self.listLargeSelectionMarkSize = listLargeSelectionMarkSize
    self.listCompactSelectionMarkSize = listCompactSelectionMarkSize
    self.listLargeIconSize = listLargeIconSize
    self.listCompactIconSize = listCompactIconSize
    self.listLargeRowHeight = listLargeRowHeight
    self.listCompactRowHeight = listCompactRowHeight
    self.progressSegmentWidth = progressSegmentWidth
    self.progressSegmentGap = progressSegmentGap
    self.indeterminateProgressBlockCount = indeterminateProgressBlockCount
  }

  /// The default Windows 95-inspired component measurements.
  public static let classic = Metrics95(
    bevelWidth: 1,
    checkboxSize: 18,
    radioButtonSize: 18,
    scrollBarWidth: 17,
    scrollThumbMinimumLength: 17,
    scrollLineIncrementMinimum: 20,
    progressBarHeight: 20,
    titleBarHeight: 30,
    compactTitleBarHeight: 44,
    taskbarHeight: 44,
    taskbarItemHeight: 34,
    pressedContentOffset: 1,
    progressContentInset: 2,
    tabStripOverlap: 2
  )
}
