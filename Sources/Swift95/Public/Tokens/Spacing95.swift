import CoreGraphics

/// Direct point spacing used while the component system is still taking shape.
///
/// The subscript maps a nonnegative integer directly to the same number of
/// points, making literal spacing values explicit at call sites.
///
/// ```swift
/// VStack(spacing: Spacing95[8]) {
///   Text95("Name")
///   TextField95("Name", text: $name)
/// }
/// .padding(Spacing95[12])
/// ```
///
/// - Todo: Once real component usage reveals stable roles, replace direct
///   values in public component defaults with semantic spacing tokens stored in
///   `Theme95` while retaining this helper for literal measurements.
public enum Spacing95 {
  /// The direct spacing range displayed by the catalog and related tooling.
  public static let initialRange = 0...24

  /// Returns a direct point value for a nonnegative integer.
  ///
  /// - Parameter points: The requested spacing in points. Passing a negative
  ///   value triggers a precondition failure.
  /// - Returns: The supplied integer converted to `CGFloat`.
  public static subscript(points: Int) -> CGFloat {
    precondition(points >= 0, "Spacing95 only accepts nonnegative point values")
    return CGFloat(points)
  }
}
