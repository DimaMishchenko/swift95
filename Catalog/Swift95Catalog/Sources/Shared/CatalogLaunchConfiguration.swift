import SwiftUI

struct CatalogLaunchConfiguration: Equatable {
  var isUITesting = false
  var destination: String?
  var disablesResize = false

  static var current: Self {
    let arguments = ProcessInfo.processInfo.arguments
    return Self(
      isUITesting: arguments.contains("--ui-testing"),
      destination: value(after: "--ui-test-destination", in: arguments),
      disablesResize: arguments.contains("--ui-test-no-resize")
    )
  }

  private static func value(after flag: String, in arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: flag) else { return nil }
    let valueIndex = arguments.index(after: index)
    return valueIndex < arguments.endIndex ? arguments[valueIndex] : nil
  }
}

extension EnvironmentValues {
  @Entry var catalogLaunchConfiguration = CatalogLaunchConfiguration()
}
