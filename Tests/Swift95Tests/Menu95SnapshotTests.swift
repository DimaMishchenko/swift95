#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing
  import UIKit

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Menu95SnapshotTests {
    @Test func openMenuWithHighlightedAndDisabledItems() {
      let menuBar = MenuBar95(
        presentedMenu: .constant(0),
        menus: snapshotMenus,
        snapshotHighlightedItem: (menu: 0, element: 3),
        rendersPresentedMenu: false
      )
      let view = ZStack(alignment: .topLeading) {
        Color.white
          .padding(.top, 30)

        menuBar
          .frame(maxWidth: .infinity, alignment: .leading)

        menuBar.menuPanel(at: 0)
          .offset(y: 28)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .padding(24)
      .background(Theme95.classic.colors.background)
      .environment(\.theme95, .classic)
      .environment(\.locale, Locale(identifier: "en_US_POSIX"))
      .environment(\.colorScheme, .light)
      .environment(\.layoutDirection, .leftToRight)
      .transaction { $0.disablesAnimations = true }

      assertSnapshot95(
        of: view,
        as: .image(
          precision: 1,
          perceptualPrecision: 0.98,
          layout: .fixed(width: 390, height: 360),
          traits: snapshotTraits()
        )
      )
    }

    private var snapshotMenus: [Menu95] {
      [
        Menu95("File") {
          MenuItem95("New") {}
          MenuItem95("Open…") {}
          MenuDivider95()
          MenuItem95("Save As…") {}
          MenuDivider95()
          MenuItem95("Print", isEnabled: false) {}
        },
        Menu95("Edit") {
          MenuItem95("Undo") {}
        },
        Menu95("Help") {
          MenuItem95("About") {}
        }
      ]
    }
  }
#endif
