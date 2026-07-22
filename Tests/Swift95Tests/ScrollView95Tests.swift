import Testing

@testable import Swift95

struct ScrollView95Tests {
  @Test func indicatorRequestsAreClampedToTheNativeScrollableRange() {
    var synchronization = ScrollSynchronization()
    synchronization.update(
      from: ScrollMetrics95(contentOffset: 40, contentHeight: 300, containerHeight: 100)
    )

    #expect(synchronization.requestOffset(500) == 200)
    #expect(synchronization.requestOffset(-20) == 0)
  }

  @Test func nativeOffsetIsClampedWhenScrollableContentShrinks() {
    var synchronization = ScrollSynchronization()

    synchronization.update(
      from: ScrollMetrics95(contentOffset: 160, contentHeight: 180, containerHeight: 100)
    )

    #expect(synchronization.metrics.contentOffset == 80)
  }

  @Test func staleNativeGeometryDoesNotUndoAnIndicatorRequest() {
    var synchronization = ScrollSynchronization()
    synchronization.update(
      from: ScrollMetrics95(contentOffset: 200, contentHeight: 500, containerHeight: 100)
    )
    _ = synchronization.requestOffset(100)

    synchronization.update(
      from: ScrollMetrics95(contentOffset: 200, contentHeight: 500, containerHeight: 100)
    )
    #expect(synchronization.metrics.contentOffset == 100)

    synchronization.update(
      from: ScrollMetrics95(contentOffset: 100, contentHeight: 500, containerHeight: 100)
    )
    #expect(synchronization.metrics.contentOffset == 100)
  }

  @Test func macOSScrollOffsetAccountsForDocumentOrientation() {
    #expect(
      NativeVerticalScrollOffset95.originY(
        targetOffset: 120,
        documentHeight: 500,
        viewportHeight: 200,
        isFlipped: true
      ) == 120
    )
    #expect(
      NativeVerticalScrollOffset95.originY(
        targetOffset: 120,
        documentHeight: 500,
        viewportHeight: 200,
        isFlipped: false
      ) == 180
    )
    #expect(
      NativeVerticalScrollOffset95.originY(
        targetOffset: 900,
        documentHeight: 500,
        viewportHeight: 200,
        isFlipped: true
      ) == 300
    )
  }
}
