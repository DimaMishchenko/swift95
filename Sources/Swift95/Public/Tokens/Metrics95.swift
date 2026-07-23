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
    tabStripOverlap: CGFloat = 2
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
