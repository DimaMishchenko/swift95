import Foundation
import Testing

@testable import Swift95

@Test func percentageFormattingUsesTheRequestedLocale() {
  let formatter = ValueFormatters95.localized

  #expect(formatter.percentage(0.5, Locale(identifier: "en_US")) == "50%")
  #expect(formatter.percentage(0.5, Locale(identifier: "fr_FR")) == "50 %")
}

@Test func percentageFormattingCanBeOverriddenWithoutChangingTheTheme() {
  let formatter = ValueFormatters95 { fraction, _ in
    "progress=\(Int(fraction * 100))"
  }

  #expect(formatter.percentage(0.42, Locale(identifier: "en_US")) == "progress=42")
}
