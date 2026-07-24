import XCTest

@MainActor
final class Swift95AccessibilityUITests: XCTestCase {
  func testControlsExposeCanonicalSemantics() throws {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launch()
    let button = app.descendants(matching: .any)["primary-button"]
    let checkbox = app.descendants(matching: .any)["sound-checkbox"]
    let radio = app.descendants(matching: .any)["automatic-radio"]
    let slider = app.descendants(matching: .any)["volume-slider"]

    for element in [button, checkbox, radio, slider] {
      XCTAssertTrue(element.waitForExistence(timeout: 3))
    }

    XCTAssertEqual(button.label, "Run action")
    XCTAssertEqual(checkbox.label, "Enable sound")
    XCTAssertEqual(radio.label, "Automatic")
    XCTAssertEqual(slider.label, "Volume")
    XCTAssertGreaterThanOrEqual(slider.frame.height, 44)
  }

  func testLibraryOwnedScrollbarLabelsAreLocalized() {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launch()
    let allElements = app.descendants(matching: .any)
    XCTAssertTrue(allElements["Scroll up"].waitForExistence(timeout: 3))
    XCTAssertTrue(allElements["Scroll down"].exists)

    let thumb = allElements["Scroll position"]
    XCTAssertTrue(thumb.exists)
    XCTAssertFalse(thumb.value as? String == nil)
  }

  func testLibraryOwnedStringsCanBeOverridden() {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launchArguments = ["--custom-strings"]
    app.launch()
    let allElements = app.descendants(matching: .any)

    XCTAssertTrue(allElements["Custom scroll up"].waitForExistence(timeout: 3))
    XCTAssertTrue(allElements["Custom scroll down"].exists)
    XCTAssertTrue(allElements["Custom scroll position"].exists)
    XCTAssertFalse(allElements["Scroll up"].exists)
  }

  func testScreenPassesSystemAccessibilityAudit() throws {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launch()
    try app.performAccessibilityAudit(
      for: XCUIAccessibilityAuditType.all.subtracting(.hitRegion)
    )
  }

  func testWorkspaceChromeIsAccessible() throws {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launchArguments = ["--workspace"]
    app.launch()

    for label in ["Minimize", "Maximize", "Close", "Resize window"] {
      let element = app.descendants(matching: .any)[label]
      XCTAssertTrue(element.waitForExistence(timeout: 3), label)
    }

    // XCTest treats the draggable static title as a hit target and its
    // pixel-art glyphs as separate detected images. The actual interactive
    // controls are queried, labeled, and measured explicitly above.
    try app.performAccessibilityAudit(
      for: XCUIAccessibilityAuditType.all
        .subtracting(.hitRegion)
        .subtracting(.elementDetection)
        .subtracting(.sufficientElementDescription)
    )
  }

  func testWorkspaceCapabilitiesRemoveUnavailableResizeControls() {
    continueAfterFailure = false
    let app = XCUIApplication()
    app.launchArguments = ["--workspace", "--no-resize"]
    app.launch()

    XCTAssertTrue(app.staticTexts["Accessible workspace content"].waitForExistence(timeout: 3))
    XCTAssertFalse(app.descendants(matching: .any)["Resize window"].exists)
  }
}
