#if canImport(UIKit)
  import SnapshotTesting
  import SwiftUI
  import Testing
  import UIKit

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct ComponentSnapshotTests {
    @Test func progressAtAccessibilityDynamicTypeSize() {
      let view = snapshotCanvas {
        VStack(alignment: .leading, spacing: 24) {
          ProgressView95("Installing", value: 0.42)
          ProgressView95("Complete", value: 1)
        }
        .dynamicTypeSize(.accessibility5)
      }

      assertSnapshot(of: view, as: imageSnapshot(height: 300))
    }

    @Test func pickerWithValidSelection() {
      let view = snapshotCanvas {
        Picker95(
          "Sort by",
          selection: .constant(SnapshotPickerValue.name),
          options: pickerOptions
        )
      }

      assertSnapshot(of: view, as: imageSnapshot(height: 160))
    }

    @Test func pickerWithInvalidSelectionDoesNotMisrepresentValue() {
      let view = snapshotCanvas {
        Picker95(
          "Sort by",
          selection: .constant(SnapshotPickerValue.missing),
          options: pickerOptions
        )
      }

      assertSnapshot(of: view, as: imageSnapshot(height: 160))
    }

    @Test func multipleSelectionList() {
      let items = [
        SnapshotListItem(id: 1, title: "View"),
        SnapshotListItem(id: 2, title: "Refresh"),
        SnapshotListItem(id: 3, title: "Properties")
      ]
      let view = snapshotCanvas {
        List95(
          items,
          selection: .constant(Set([1, 3])),
          style: .compact,
          showsSeparators: true
        ) { item in
          Row95 { Text95(item.title) }
        }
        .frame(height: 120)
      }

      assertSnapshot(of: view, as: imageSnapshot(height: 200))
    }

    private var pickerOptions: [PickerOption95<SnapshotPickerValue, Text>] {
      [
        PickerOption95("Name", value: .name),
        PickerOption95("Date modified", value: .dateModified)
      ]
    }

    private func snapshotCanvas<Content: View>(
      @ViewBuilder content: () -> Content
    ) -> some View {
      content()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .background(Theme95.classic.colors.background)
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .environment(\.colorScheme, .light)
        .environment(\.layoutDirection, .leftToRight)
        .transaction { $0.disablesAnimations = true }
    }

    private func imageSnapshot<V: View>(height: CGFloat) -> Snapshotting<V, UIImage> {
      .image(
        precision: 0.99,
        perceptualPrecision: 0.99,
        layout: .fixed(width: 390, height: height),
        traits: UITraitCollection(traitsFrom: [
          UITraitCollection(displayScale: 1),
          UITraitCollection(userInterfaceStyle: .light),
          UITraitCollection(preferredContentSizeCategory: .large),
          UITraitCollection(layoutDirection: .leftToRight)
        ])
      )
    }
  }

  private enum SnapshotPickerValue: String, Hashable {
    case name
    case dateModified
    case missing
  }

  private struct SnapshotListItem: Identifiable {
    let id: Int
    let title: String
  }
#endif
