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

@Test func scrollSynchronizationTracksNativeGeometryAndClampsIndicatorRequests() {
  var synchronization = ScrollSynchronization()

  synchronization.update(
    from: ScrollMetrics95(
      contentOffset: 40,
      contentHeight: 300,
      containerHeight: 100
    )
  )

  #expect(synchronization.metrics.contentOffset == 40)
  #expect(synchronization.requestOffset(500) == 200)
  #expect(synchronization.metrics.contentOffset == 200)
  #expect(synchronization.requestOffset(-20) == 0)
}

@Test func scrollSynchronizationClampsGeometryAfterContentShrinks() {
  var synchronization = ScrollSynchronization()

  synchronization.update(
    from: ScrollMetrics95(
      contentOffset: 160,
      contentHeight: 180,
      containerHeight: 100
    )
  )

  #expect(synchronization.metrics.contentOffset == 80)
}

@Test func scrollSynchronizationIgnoresStaleGeometryWhileApplyingIndicatorRequest() {
  var synchronization = ScrollSynchronization()

  synchronization.update(
    from: ScrollMetrics95(
      contentOffset: 200,
      contentHeight: 500,
      containerHeight: 100
    )
  )
  _ = synchronization.requestOffset(100)

  synchronization.update(
    from: ScrollMetrics95(
      contentOffset: 200,
      contentHeight: 500,
      containerHeight: 100
    )
  )
  #expect(synchronization.metrics.contentOffset == 100)

  synchronization.update(
    from: ScrollMetrics95(
      contentOffset: 100,
      contentHeight: 500,
      containerHeight: 100
    )
  )
  #expect(synchronization.metrics.contentOffset == 100)
}
