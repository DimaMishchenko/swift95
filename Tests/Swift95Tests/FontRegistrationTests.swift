import CoreText
import Testing

@testable import Swift95

@Test func bundledFontRegistersWithItsExpectedPostScriptName() {
  _ = Theme95.classic.fonts.body

  let font = CTFontCreateWithName("W95FARegular" as CFString, 17, nil)
  #expect(CTFontCopyPostScriptName(font) as String == "W95FARegular")
}
