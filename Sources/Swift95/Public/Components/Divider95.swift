import SwiftUI

/// An etched horizontal or vertical separator.
///
/// `Divider95` draws adjacent dark and light lines using the active theme. Its
/// intrinsic thickness is two points and it expands along its selected axis.
/// The divider is decorative and hidden from accessibility technologies.
///
/// ```swift
/// VStack(spacing: Spacing95[8]) {
///   Text95("General")
///   Divider95()
///   settings
/// }
/// ```
public struct Divider95: View {
  @Environment(\.theme95) private var theme

  private let axis: Axis

  /// Creates an etched divider.
  ///
  /// - Parameter axis: The axis along which the divider extends.
  public init(_ axis: Axis = .horizontal) {
    self.axis = axis
  }

  /// The styled divider.
  public var body: some View {
    Group {
      switch axis {
      case .horizontal:
        VStack(spacing: 0) {
          theme.colors.borderDark
          theme.colors.borderLightest
        }
        .frame(maxWidth: .infinity)
        .frame(height: 2)
      case .vertical:
        HStack(spacing: 0) {
          theme.colors.borderDark
          theme.colors.borderLightest
        }
        .frame(width: 2)
        .frame(maxHeight: .infinity)
      }
    }
    .accessibilityHidden(true)
  }
}
