import SwiftUI
import Testing

@testable import Swift95

@MainActor
struct Image95Tests {
  @Test func pixelationUsesClassicTwoPointBlocks() {
    #expect(ImagePixelation95.pixelSize == 2)
    #expect(ImagePixelation95.maxSampleOffset == CGSize(width: 1, height: 1))
  }

  @Test func imageInitializersAndTransformsBuild() {
    let defaultImage = Image95(Image(systemName: "photo"))
      .swiftUI { $0.resizable().scaledToFit() }
    let unpixelatedImage = Image95(
      Image(systemName: "photo"),
      isPixelated: false
    )
    let customContent = Image95(isPixelated: false) {
      Color.blue
    }

    _ = defaultImage.body
    _ = unpixelatedImage.body
    _ = customContent.body
  }

  @Test func asyncImageInitializersAndTransformsBuild() {
    let standard = AsyncImage95(url: nil)
      .swiftUI { $0.frame(width: 32, height: 32) }
    let phased = AsyncImage95(url: nil, isPixelated: false) { phase in
      if let image = phase.image {
        image
      } else {
        Image(systemName: "photo")
      }
    }

    _ = standard.body
    _ = phased.body
  }
}
