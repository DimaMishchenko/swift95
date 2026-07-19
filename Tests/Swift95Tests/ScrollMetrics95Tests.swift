import CoreGraphics
import Testing

@testable import Swift95

@Test func fittingScrollContentDoesNotScroll() {
  let metrics = ScrollMetrics95(
    contentOffset: 0,
    contentHeight: 80,
    containerHeight: 100
  )

  #expect(!metrics.isScrollable)
  #expect(metrics.progress == 0)
  #expect(metrics.visibleFraction == 1)
}

@Test func overflowingScrollContentReportsItsPositionAndVisibleFraction() {
  let metrics = ScrollMetrics95(
    contentOffset: 50,
    contentHeight: 200,
    containerHeight: 100
  )

  #expect(metrics.isScrollable)
  #expect(metrics.progress == 0.5)
  #expect(metrics.visibleFraction == 0.5)
}
