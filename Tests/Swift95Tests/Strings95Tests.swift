import Foundation
import Testing

@testable import Swift95

@Test func bundledStringsResolveFromThePackageResourceBundle() {
  var close = Strings95.localized.close
  close.locale = Locale(identifier: "en")
  #expect(String(localized: close) == "Close")
  var scrollUp = Strings95.localized.scrollUp
  scrollUp.locale = Locale(identifier: "en")
  #expect(String(localized: scrollUp) == "Scroll up")
}
