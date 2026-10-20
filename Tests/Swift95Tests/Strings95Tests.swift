import Foundation
import Testing

@testable import Swift95

@Test func bundledStringsResolveFromThePackageResourceBundle() {
  let strings = Strings95.localized
  let labels: [(LocalizedStringResource, String)] = [
    (strings.minimize, "Minimize"),
    (strings.maximize, "Maximize"),
    (strings.restore, "Restore"),
    (strings.close, "Close"),
    (strings.scrollPosition, "Scroll position"),
    (strings.scrollUp, "Scroll up"),
    (strings.scrollDown, "Scroll down"),
    (strings.moveWindow, "Move window"),
    (strings.resizeWindow, "Resize window"),
    (strings.expanded, "Expanded"),
    (strings.collapsed, "Collapsed"),
    (strings.active, "Active"),
    (strings.minimized, "Minimized")
  ]
  for (resource, expected) in labels {
    var localized = resource
    localized.locale = Locale(identifier: "en")
    #expect(String(localized: localized) == expected)
  }
}
