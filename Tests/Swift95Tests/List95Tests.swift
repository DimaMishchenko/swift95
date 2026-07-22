import Testing

@testable import Swift95

@Test func pressedRowTemporarilyOwnsTheListHighlight() {
  #expect(
    ListSelectionHighlight.isHighlighted(
      id: 1,
      selected: true,
      pressedID: Optional<Int>.none
    )
  )
  #expect(!ListSelectionHighlight.isHighlighted(id: 1, selected: true, pressedID: 2))
  #expect(ListSelectionHighlight.isHighlighted(id: 2, selected: false, pressedID: 2))
  #expect(!ListSelectionHighlight.isHighlighted(id: 3, selected: false, pressedID: 2))
}
