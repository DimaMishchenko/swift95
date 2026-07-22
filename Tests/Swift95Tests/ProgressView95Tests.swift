import Testing

@testable import Swift95

@Test func determinateProgressClampsInvalidValuesToItsDisplayRange() {
  #expect(ProgressFraction95(-0.4).value == 0)
  #expect(ProgressFraction95(0.425).value == 0.425)
  #expect(ProgressFraction95(1.4).value == 1)
  #expect(ProgressFraction95(.infinity).value == 0)
}

@Test func progressPercentageRoundsToTheNearestWholePercent() {
  #expect(ProgressFraction95(0.425).percentage == 43)
}
