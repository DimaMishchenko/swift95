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
  /// The default progress bar height.
  public var progressBarHeight: CGFloat
  /// The default window title bar height.
  public var titleBarHeight: CGFloat
  /// The default taskbar height.
  public var taskbarHeight: CGFloat

  /// Creates a set of component measurements.
  ///
  /// - Parameters:
  ///   - bevelWidth: The width of one bevel edge.
  ///   - checkboxSize: The visible checkbox indicator size.
  ///   - radioButtonSize: The visible radio indicator size.
  ///   - scrollBarWidth: The visible scrollbar width.
  ///   - progressBarHeight: The default progress bar height.
  ///   - titleBarHeight: The default window title bar height.
  ///   - taskbarHeight: The default taskbar height.
  public init(
    bevelWidth: CGFloat,
    checkboxSize: CGFloat,
    radioButtonSize: CGFloat,
    scrollBarWidth: CGFloat,
    progressBarHeight: CGFloat,
    titleBarHeight: CGFloat,
    taskbarHeight: CGFloat
  ) {
    self.bevelWidth = bevelWidth
    self.checkboxSize = checkboxSize
    self.radioButtonSize = radioButtonSize
    self.scrollBarWidth = scrollBarWidth
    self.progressBarHeight = progressBarHeight
    self.titleBarHeight = titleBarHeight
    self.taskbarHeight = taskbarHeight
  }

  /// The default Windows 95-inspired component measurements.
  public static let classic = Metrics95(
    bevelWidth: 1,
    checkboxSize: 18,
    radioButtonSize: 18,
    scrollBarWidth: 17,
    progressBarHeight: 20,
    titleBarHeight: 20,
    taskbarHeight: 28
  )
}
