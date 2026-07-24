import CoreGraphics

/// Nonvisual behavior and placement defaults for a ``Workspace95``.
public struct WorkspaceConfiguration95: Sendable, Equatable {
  /// The smallest workspace that automatically uses the windowed presentation.
  public var automaticWindowedMinimumSize: CGSize
  /// The fraction of workspace width assigned to a new window.
  public var initialWindowWidthFraction: CGFloat
  /// The fraction of workspace height assigned to a new window.
  public var initialWindowHeightFraction: CGFloat
  /// The lower bound for a new window's initial size.
  public var initialWindowMinimumSize: CGSize
  /// The upper bound for a new window's initial size.
  public var initialWindowMaximumSize: CGSize
  /// The number of positions used before the initial placement cascade repeats.
  public var cascadeCount: Int
  /// The distance between consecutive positions in the initial placement cascade.
  public var cascadeStep: CGFloat
  /// An offset applied to the centered initial placement.
  public var initialWindowCenterOffset: CGSize
  /// The smallest permitted initial window origin.
  public var minimumWindowOrigin: CGPoint
  /// The distance moved by one accessibility move action.
  public var accessibilityMoveStep: CGFloat
  /// The size change applied by one accessibility resize action.
  public var accessibilityResizeStep: CGFloat

  /// Creates workspace behavior and placement defaults.
  public init(
    automaticWindowedMinimumSize: CGSize = CGSize(width: 600, height: 480),
    initialWindowWidthFraction: CGFloat = 0.62,
    initialWindowHeightFraction: CGFloat = 0.68,
    initialWindowMinimumSize: CGSize = CGSize(width: 340, height: 260),
    initialWindowMaximumSize: CGSize = CGSize(width: 620, height: 520),
    cascadeCount: Int = 8,
    cascadeStep: CGFloat = 24,
    initialWindowCenterOffset: CGSize = CGSize(width: -72, height: -48),
    minimumWindowOrigin: CGPoint = CGPoint(x: 12, y: 12),
    accessibilityMoveStep: CGFloat = 24,
    accessibilityResizeStep: CGFloat = 24
  ) {
    self.automaticWindowedMinimumSize = automaticWindowedMinimumSize
    self.initialWindowWidthFraction = initialWindowWidthFraction
    self.initialWindowHeightFraction = initialWindowHeightFraction
    self.initialWindowMinimumSize = initialWindowMinimumSize
    self.initialWindowMaximumSize = initialWindowMaximumSize
    self.cascadeCount = max(1, cascadeCount)
    self.cascadeStep = cascadeStep
    self.initialWindowCenterOffset = initialWindowCenterOffset
    self.minimumWindowOrigin = minimumWindowOrigin
    self.accessibilityMoveStep = max(1, accessibilityMoveStep)
    self.accessibilityResizeStep = max(1, accessibilityResizeStep)
  }

  /// The standard workspace behavior.
  public static let `default` = WorkspaceConfiguration95()
}
