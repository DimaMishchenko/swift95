import SwiftUI
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

@Test func singleSelectionWritesEveryActivatedRow() {
  let box = SelectionTestBox<Int?>(1)
  let binding = Binding<Int?>(
    get: { box.value },
    set: { box.value = $0 }
  )
  let selection = ListSelection.single(binding)

  selection.select(2)
  #expect(box.value == 2)

  selection.select(3)
  #expect(box.value == 3)
}

private final class SelectionTestBox<Value>: @unchecked Sendable {
  var value: Value

  init(_ value: Value) {
    self.value = value
  }
}
