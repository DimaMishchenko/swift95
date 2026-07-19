import CoreGraphics

/// Direct point spacing used while the component system is still taking shape.
///
/// Example: `.padding(Spacing95[4])`.
///
/// - Todo: Once real component usage reveals stable roles, replace direct
///   values in public component defaults with semantic spacing tokens stored in
///   `Theme95` while retaining this helper for literal measurements.
public enum Spacing95 {
  public static let initialRange = 0...24

  public static subscript(points: Int) -> CGFloat {
    precondition(points >= 0, "Spacing95 only accepts nonnegative point values")
    return CGFloat(points)
  }
}
