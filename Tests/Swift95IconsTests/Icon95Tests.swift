import Swift95Icons
import XCTest

@MainActor
final class Icon95Tests: XCTestCase {
  func testSemanticSizesSelectTheirRenditions() {
    let icon = Icon95(.access110)
    let smallIcon = Icon95(.access110, size: .small)

    XCTAssertEqual(icon.size, .standard)
    XCTAssertEqual(icon.sourceSize, .standard)
    XCTAssertEqual(icon.name.availableSizes, [.small, .standard])
    XCTAssertEqual(icon.pixelSize, CGSize(width: 32, height: 32))
    XCTAssertEqual(icon.renderedSize, CGSize(width: 32, height: 32))
    XCTAssertEqual(smallIcon.pixelSize, CGSize(width: 16, height: 16))
    XCTAssertEqual(smallIcon.renderedSize, CGSize(width: 16, height: 16))
  }

  func testSelectedRenditionCanBeMadeResizable() {
    let icon = Icon95(.logo, size: .standard)
    _ = icon.resizable().frame(width: 16, height: 16)

    XCTAssertEqual(icon.size, .standard)
    XCTAssertEqual(icon.sourceSize, .standard)
    XCTAssertEqual(icon.pixelSize, CGSize(width: 32, height: 32))
  }

  func testIdentifierUsesTheNormalizedSwiftName() {
    XCTAssertEqual(Icon95.Name.addressBook.identifier, "addressBook")
    XCTAssertEqual(Icon95.Name.shellEntireNetwork.identifier, "shellEntireNetwork")
    XCTAssertEqual(Icon95.Name.shell32133.identifier, "shell32133")
  }

  func testSwiftUICustomizationPreservesIconMetadata() {
    let icon = Icon95(.computer, size: .large)
    _ = icon.swiftUI { renderedIcon in
      renderedIcon.accessibilityLabel("Computer")
    }

    XCTAssertEqual(icon.name, .computer)
    XCTAssertEqual(icon.size, .large)
  }

  func testMissingRenditionFallsBackAndUsesRequestedRenderedSize() {
    let icon = Icon95(.addressBook)

    XCTAssertEqual(icon.name.availableSizes, [.small])
    XCTAssertEqual(icon.sourceSize, .small)
    XCTAssertEqual(icon.pixelSize, CGSize(width: 16, height: 16))
    XCTAssertEqual(icon.renderedSize, CGSize(width: 32, height: 32))
  }
}
