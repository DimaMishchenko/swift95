import SwiftUI
import Testing

@testable import Swift95

struct Slider95Tests {
  @MainActor
  @Test(arguments: [LayoutDirection.leftToRight, .rightToLeft])
  func renderedThumbMatchesThePhysicalValuePosition(direction: LayoutDirection) throws {
    let theme = Theme95.classic
    for fraction in [0.0, 0.25, 0.75, 1.0] {
      let renderer = ImageRenderer(
        content: Slider95(value: .constant(fraction))
          .environment(\.layoutDirection, direction)
          .frame(width: 200, height: 44)
      )
      let image = try #require(renderer.cgImage)
      var pixels = [UInt8](repeating: 0, count: image.width * image.height * 4)
      let counts = try pixels.withUnsafeMutableBytes { bytes -> [Int] in
        let context = try #require(
          CGContext(
            data: bytes.baseAddress, width: image.width, height: image.height,
            bitsPerComponent: 8, bytesPerRow: image.width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              | CGBitmapInfo.byteOrder32Big.rawValue
          ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return (0..<image.width)
          .map { x in
            (0..<image.height).filter { y in bytes[(y * image.width + x) * 4 + 3] > 128 }.count
          }
      }
      let tallest = try #require(counts.max())
      let thumbColumns = counts.indices.filter { counts[$0] > tallest * 3 / 4 }
      let left = try #require(thumbColumns.first)
      let right = try #require(thumbColumns.last)
      let center = CGFloat(left + right + 1) / 2
      let expected = SliderGeometry95.thumbCenter(
        fraction: fraction, width: 200, thumbWidth: theme.metrics.sliderThumbWidth,
        layoutDirection: direction
      )
      #expect(abs(center - expected) <= 1)
    }
  }

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
