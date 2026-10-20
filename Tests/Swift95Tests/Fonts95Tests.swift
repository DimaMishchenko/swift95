import CoreText
import SwiftUI
import Testing

@testable import Swift95

@Test func bundledClassicFontCanBeRegisteredAndLoaded() {
  _ = Fonts95.classic
  let font = CTFontCreateWithName("W95FARegular" as CFString, 16, nil)

  #expect(CTFontCopyPostScriptName(font) as String == "W95FARegular")
}

@MainActor
struct SystemFonts95Tests {
  private let fonts = Fonts95(
    title: .system(.title),
    title2: .system(.title2),
    title3: .system(.title3),
    body: .system(.body)
  )

  @Test func scalableSystemFontsRetainTheRequestedBaseSize() throws {
    let small = try renderedWidth(size: 12)
    let large = try renderedWidth(size: 30)

    #expect(large > small * 2)
    #expect(large < small * 3)
  }

  @Test func scalableSystemFontMatchesNativeSystemRendering() throws {
    let scalable = try renderedSize(
      font: fonts.font(size: 30, weight: .semibold, relativeTo: .body)
    )
    let native = try renderedSize(font: .system(size: 30, weight: .semibold))

    #expect(scalable == native)
  }

  #if compiler(>=6.2)
    @Test func scalableSystemFontResolvesToTheSystemFamilyAndRequestedWeight() {
      if #available(iOS 26, macOS 26, *) {
        let context = EnvironmentValues().fontResolutionContext
        let resolved = fonts.font(size: 30, weight: .semibold, relativeTo: .body)
          .resolve(in: context)
        let system = Font.system(size: 30, weight: .semibold).resolve(in: context)

        #expect(
          CTFontCopyFamilyName(resolved.ctFont) as String
            == CTFontCopyFamilyName(system.ctFont) as String
        )
        #expect(abs(resolved.pointSize - 30) < 0.1)
        #expect(resolved.weight == system.weight)
      }
    }
  #endif

  #if os(iOS)
    @Test func scalableSystemFontsRespondToDynamicType() throws {
      let standard = try renderedWidth(size: 20, dynamicTypeSize: .large)
      let accessible = try renderedWidth(size: 20, dynamicTypeSize: .accessibility3)

      #expect(accessible > standard)
    }
  #endif

  private func renderedWidth(
    size: CGFloat,
    dynamicTypeSize: DynamicTypeSize = .large
  ) throws -> Int {
    Int(
      try renderedSize(
        font: fonts.font(size: size, relativeTo: .body),
        dynamicTypeSize: dynamicTypeSize
      )
      .width
    )
  }

  private func renderedSize(
    font: Font,
    dynamicTypeSize: DynamicTypeSize = .large
  ) throws -> CGSize {
    let renderer = ImageRenderer(
      content: Text("System font sample")
        .font(font)
        .environment(\.dynamicTypeSize, dynamicTypeSize)
        .fixedSize()
    )
    let image = try #require(renderer.cgImage)
    return CGSize(width: image.width, height: image.height)
  }
}
