import SwiftUI
import Testing

@testable import Swift95

struct Menu95Tests {
  @Test func menuBarBuilderPreservesMenusCommandsAndSeparators() {
    var actionCount = 0
    let includesHelp = true

    let window = WorkspaceWindow95("Document", icon: { EmptyView() }) {
      EmptyView()
    }
    .menuBar95 {
      Menu95("File") {
        MenuItem95("New") {
          actionCount += 1
        }
        MenuDivider95()
        MenuItem95("Print", isEnabled: false) {}
      }

      if includesHelp {
        Menu95("Help") {
          MenuItem95("About") {}
        }
      }
    }

    #expect(window.menus.count == 2)
    #expect(window.menus[0].elements.count == 3)

    guard case let .item(newItem) = window.menus[0].elements[0] else {
      Issue.record("The first menu element should be a command")
      return
    }
    guard case .divider = window.menus[0].elements[1] else {
      Issue.record("The second menu element should be a divider")
      return
    }
    guard case let .item(printItem) = window.menus[0].elements[2] else {
      Issue.record("The third menu element should be a command")
      return
    }

    newItem.action()

    #expect(actionCount == 1)
    #expect(newItem.isEnabled)
    #expect(!printItem.isEnabled)
  }

  @Test func windowsHaveNoMenuBarByDefault() {
    let window = WorkspaceWindow95("Document", icon: { EmptyView() }) {
      EmptyView()
    }

    #expect(window.menus.isEmpty)
  }
}
