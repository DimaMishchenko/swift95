import Foundation
import SwiftUI

/// Locale-aware formatting used by Swift95's library-owned value labels.
public struct ValueFormatters95: Sendable {
  /// Formats a normalized fraction as a percentage for a locale.
  public var percentage: @Sendable (_ fraction: Double, _ locale: Locale) -> String

  /// Creates a set of library-owned value formatters.
  public init(
    percentage: @escaping @Sendable (_ fraction: Double, _ locale: Locale) -> String
  ) {
    self.percentage = percentage
  }

  /// Formatting that follows the current SwiftUI locale.
  public static let localized = ValueFormatters95 { fraction, locale in
    fraction.formatted(
      .percent
        .precision(.fractionLength(0))
        .locale(locale)
    )
  }
}

extension EnvironmentValues {
  /// Value formatting inherited by Swift95 components.
  @Entry public var valueFormatters95: ValueFormatters95 = .localized
}

extension View {
  /// Overrides library-owned value formatting for this view hierarchy.
  public func valueFormatters95(_ formatters: ValueFormatters95) -> some View {
    environment(\.valueFormatters95, formatters)
  }
}
