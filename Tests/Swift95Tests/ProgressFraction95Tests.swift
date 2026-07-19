import Testing

@testable import Swift95

@Test func determinateProgressIsClampedToItsDisplayRange() {
  #expect(ProgressFraction95(-0.4).value == 0)
  #expect(ProgressFraction95(0.425).value == 0.425)
  #expect(ProgressFraction95(1.4).value == 1)
  #expect(ProgressFraction95(.infinity).value == 0)
}

@Test func progressPercentageUsesTheNearestWholePercent() {
  #expect(ProgressFraction95(0.424).percentage == 42)
  #expect(ProgressFraction95(0.425).percentage == 43)
}

@Test func missingProgressRemainsIndeterminate() {
  let progress = ProgressFraction95(nil)

  #expect(progress.value == nil)
  #expect(progress.percentage == nil)
}
