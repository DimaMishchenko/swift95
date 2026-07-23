import CoreGraphics

/// A theme-owned spacing scale shared by Swift95 components and app layouts.
///
/// Read the scale from the closest ``Theme95`` so changing a theme preserves a
/// consistent layout rhythm across both library controls and consumer views.
///
/// ```swift
/// var spacing = Spacing95.classic
/// spacing.m = 10
/// ```
public struct Spacing95: Sendable {
  /// Extra-extra-extra-small spacing.
  public var xxxs: CGFloat
  /// Extra-extra-small spacing.
  public var xxs: CGFloat
  /// Extra-small spacing.
  public var xs: CGFloat
  /// Small spacing.
  public var s: CGFloat
  /// Medium spacing.
  public var m: CGFloat
  /// Large spacing.
  public var l: CGFloat
  /// Extra-large spacing.
  public var xl: CGFloat
  /// Extra-extra-large spacing.
  public var xxl: CGFloat

  /// Creates a spacing scale.
  public init(
    xxxs: CGFloat,
    xxs: CGFloat,
    xs: CGFloat,
    s: CGFloat,
    m: CGFloat,
    l: CGFloat,
    xl: CGFloat,
    xxl: CGFloat
  ) {
    self.xxxs = xxxs
    self.xxs = xxs
    self.xs = xs
    self.s = s
    self.m = m
    self.l = l
    self.xl = xl
    self.xxl = xxl
  }

  /// The default Windows 95-inspired component spacing.
  public static let classic = Spacing95(
    xxxs: 2,
    xxs: 4,
    xs: 5,
    s: 6,
    m: 8,
    l: 10,
    xl: 12,
    xxl: 16
  )
}
