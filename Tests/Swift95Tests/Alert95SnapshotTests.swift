#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Alert95SnapshotTests {
    @Test func alertWithIconAndMultipleActions() {
      assertSnapshot95(
        of: snapshotCanvas {
          AlertPresentation95(
            title: Text("Replace file?"),
            isPresented: .constant(true),
            isCloseButtonEnabled: false,
            icon: {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
            },
            actions: {
              Button("Replace", role: .destructive) {}
              Button("Cancel", role: .cancel) {}
            },
            message: {
              Text("A file with this name already exists.")
            }
          )
          .frame(height: 300)
        },
        as: snapshotImage(height: 350)
      )
    }

    @Test func alertSupportsLongRightToLeftContent() {
      assertSnapshot95(
        of: snapshotCanvas {
          AlertPresentation95(
            title: Text("A long localized alert title"),
            isPresented: .constant(true),
            icon: {
              EmptyView()
            },
            actions: {
              Button("Continue with this action") {}
            },
            message: {
              Text(
                "A long localized message wraps without clipping and follows the layout direction."
              )
            }
          )
          .environment(\.layoutDirection, .rightToLeft)
          .dynamicTypeSize(.accessibility3)
          .frame(height: 430)
        },
        as: snapshotImage(height: 480)
      )
    }
  }
#endif
