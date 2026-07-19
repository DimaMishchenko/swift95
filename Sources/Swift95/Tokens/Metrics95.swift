import CoreGraphics

/// Stable measurements shared by Swift95 components.
public struct Metrics95: Sendable {
  public var bevelWidth: CGFloat
  public var checkboxSize: CGFloat
  public var radioButtonSize: CGFloat
  public var scrollBarWidth: CGFloat
  public var progressBarHeight: CGFloat
  public var titleBarHeight: CGFloat
  public var taskbarHeight: CGFloat
  public var minimumTouchTarget: CGFloat

  public init(
    bevelWidth: CGFloat,
    checkboxSize: CGFloat,
    radioButtonSize: CGFloat,
    scrollBarWidth: CGFloat,
    progressBarHeight: CGFloat,
    titleBarHeight: CGFloat,
    taskbarHeight: CGFloat,
    minimumTouchTarget: CGFloat
  ) {
    self.bevelWidth = bevelWidth
    self.checkboxSize = checkboxSize
    self.radioButtonSize = radioButtonSize
    self.scrollBarWidth = scrollBarWidth
    self.progressBarHeight = progressBarHeight
    self.titleBarHeight = titleBarHeight
    self.taskbarHeight = taskbarHeight
    self.minimumTouchTarget = minimumTouchTarget
  }

  public static let classic = Metrics95(
    bevelWidth: 1,
    checkboxSize: 12,
    radioButtonSize: 12,
    scrollBarWidth: 17,
    progressBarHeight: 20,
    titleBarHeight: 20,
    taskbarHeight: 28,
    minimumTouchTarget: 44
  )
}
