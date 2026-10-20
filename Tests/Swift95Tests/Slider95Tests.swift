import SwiftUI
import Testing

@testable import Swift95

struct Slider95Tests {
  @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
  func thumbStaysOnTrackAndDragReturnsItsValue(direction: LayoutDirection) throws {
    for fraction: CGFloat in [0, 0.25, 0.5, 0.75, 1] {
      let center = SliderGeometry95.thumbCenter(
        fraction: fraction, width: 200, thumbWidth: 12, layoutDirection: direction
      )
      #expect(center >= 6)
      #expect(center <= 194)
      let draggedFraction = try #require(
        SliderGeometry95.fraction(
          at: center, width: 200, thumbWidth: 12, layoutDirection: direction
        )
      )
      #expect(abs(draggedFraction - fraction) < 0.0001)
    }
  }

  @Test func rightToLeftMinimumIsAtTheRightAndMaximumIsAtTheLeft() {
    #expect(
      SliderGeometry95.thumbCenter(
        fraction: 0, width: 200, thumbWidth: 12, layoutDirection: .rightToLeft
      ) == 194
    )
    #expect(
      SliderGeometry95.thumbCenter(
        fraction: 1, width: 200, thumbWidth: 12, layoutDirection: .rightToLeft
      ) == 6
    )
    #expect(
      SliderGeometry95.fraction(
        at: -100, width: 200, thumbWidth: 12, layoutDirection: .rightToLeft
      ) == 1
    )
    #expect(
      SliderGeometry95.fraction(
        at: 300, width: 200, thumbWidth: 12, layoutDirection: .rightToLeft
      ) == 0
    )
  }

  @Test func dragIgnoresTracksWithoutThumbTravel() {
    #expect(
      SliderGeometry95.fraction(
        at: 0, width: 12, thumbWidth: 12, layoutDirection: .rightToLeft
      ) == nil
    )
  }
}
