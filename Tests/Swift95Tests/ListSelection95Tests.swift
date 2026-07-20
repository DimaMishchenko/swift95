import SwiftUI
import Testing

@testable import Swift95

@MainActor @Test func publicListTypesUseTheirQualifiedNames() {
  let style: List95.Style = .compact
  let section = List95.Section(id: "Actions", items: [TestListItem(id: 1)])
  let unbeveledList = List95(section.items, showsBevel: false) { _ in
    Row95 { EmptyView() }
  }

  #expect(style == .compact)
  #expect(section.id == "Actions")
  #expect(section.items.map(\.id) == [1])
  _ = unbeveledList
}

@Test func singleAndMultipleSelectionsReportMembership() {
  let single = ListSelection<Int>.single(.constant(2))
  let multiple = ListSelection<Int>.multiple(.constant([1, 3]))

  #expect(single.contains(2))
  #expect(!single.contains(1))
  #expect(multiple.contains(1))
  #expect(!multiple.contains(2))
  #expect(single.highlightsSelectedRows)
  #expect(!single.isMultiple)
  #expect(!multiple.highlightsSelectedRows)
  #expect(multiple.isMultiple)
}

@Test func activelyPressedRowTemporarilyReplacesSelectionHighlight() {
  #expect(
    ListSelectionHighlight.isHighlighted(
      id: 1,
      selected: true,
      pressedID: Optional<Int>.none
    )
  )
  #expect(
    !ListSelectionHighlight.isHighlighted(id: 1, selected: true, pressedID: 2)
  )
  #expect(
    ListSelectionHighlight.isHighlighted(id: 2, selected: false, pressedID: 2)
  )
  #expect(
    !ListSelectionHighlight.isHighlighted(id: 3, selected: false, pressedID: 2)
  )
}

@Test func nativeSelectionBindingsRemainTheSourceOfTruth() {
  let singleValue = TestValueBox<Int?>(nil)
  let multipleValues = TestValueBox<Set<Int>>([1])
  let single = ListSelection<Int>
    .single(
      Binding(get: { singleValue.value }, set: { singleValue.value = $0 })
    )
  let multiple = ListSelection<Int>
    .multiple(
      Binding(get: { multipleValues.value }, set: { multipleValues.value = $0 })
    )

  singleValue.value = 2
  multipleValues.value = [2, 3]

  #expect(single.contains(2))
  #expect(!single.contains(1))
  #expect(multiple.contains(2))
  #expect(multiple.contains(3))
  #expect(!multiple.contains(1))
}

@Test func multipleSelectionActivationTogglesOnlyTheRequestedItem() {
  let values = TestValueBox<Set<Int>>([1, 2])
  let selection = ListSelection<Int>
    .multiple(
      Binding(get: { values.value }, set: { values.value = $0 })
    )

  selection.activate(1)
  selection.activate(3)

  #expect(values.value == [2, 3])
}

private struct TestListItem: Identifiable {
  let id: Int
}

private final class TestValueBox<Value>: @unchecked Sendable {
  var value: Value

  init(_ value: Value) {
    self.value = value
  }
}
