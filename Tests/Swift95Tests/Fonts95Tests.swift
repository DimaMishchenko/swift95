import CoreText
import Testing

@testable import Swift95

@Test func bundledClassicFontCanBeRegisteredAndLoaded() {
  _ = Fonts95.classic
  let font = CTFontCreateWithName("W95FARegular" as CFString, 16, nil)

  #expect(CTFontCopyPostScriptName(font) as String == "W95FARegular")
}
