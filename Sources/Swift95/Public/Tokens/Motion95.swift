import Foundation

/// Semantic motion timings used by Swift95 components.
public struct Motion95: Sendable {
  /// A brief state transition, such as opening the Start menu.
  public var quick: TimeInterval
  /// Immediate pressed and highlight feedback.
  public var feedback: TimeInterval
  /// One cycle of an indeterminate progress animation.
  public var indeterminateProgressCycle: TimeInterval
  /// Maximum refresh rate for indeterminate progress.
  public var indeterminateProgressFPS: Double

  /// Creates a set of semantic motion timings.
  public init(
    quick: TimeInterval,
    feedback: TimeInterval,
    indeterminateProgressCycle: TimeInterval,
    indeterminateProgressFPS: Double
  ) {
    self.quick = quick
    self.feedback = feedback
    self.indeterminateProgressCycle = indeterminateProgressCycle
    self.indeterminateProgressFPS = indeterminateProgressFPS
  }

  /// The default Windows 95-inspired motion timings.
  public static let classic = Motion95(
    quick: 0.1,
    feedback: 0.08,
    indeterminateProgressCycle: 1.2,
    indeterminateProgressFPS: 30
  )
}
