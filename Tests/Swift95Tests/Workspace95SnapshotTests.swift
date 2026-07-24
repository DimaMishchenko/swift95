#if os(iOS)
  import SnapshotTesting
  import SwiftUI
  import Testing
  import UIKit

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct Workspace95SnapshotTests {
    @Test func workspaceCompact() {
      let state = WorkspaceState95<SnapshotWorkspaceRoute>(
        openWindows: [.notes, .settings],
        activeWindow: .notes
      )
      let view = snapshotCanvas {
        Workspace95(
          for: SnapshotWorkspaceRoute.self,
          state: .constant(state),
          presentation: .compact
        ) { route in
          WorkspaceWindow95(route.title) {
            workspaceIcon(route == .notes ? .blue : .gray)
          } taskBarIcon: {
            workspaceIcon(route == .notes ? .blue : .gray)
          } content: {
            VStack(alignment: .leading, spacing: 12) {
              Text95("Compact workspace")
              Divider95()
              Checkbox95("Enabled", isOn: .constant(true))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
          }
        } desktop: {
          Desktop95(allowsShortcutMovement: false) {
            DesktopShortcut95("Notes", value: SnapshotWorkspaceRoute.notes) {
              workspaceIcon(.blue)
            }
          }
        } taskBar: {
          TaskBar95("Start") {
            workspaceIcon(.green)
          } menu: {
            StartMenu95 {
              WorkspaceLink95("Notes", value: SnapshotWorkspaceRoute.notes)
            }
          }
        }
      }

      assertSnapshot95(of: view, as: imageSnapshot(height: 700))
    }

    @Test func workspaceWindowedRegularWidth() {
      let state = WorkspaceState95<SnapshotWorkspaceRoute>(
        openWindows: [.notes, .settings],
        activeWindow: .notes,
        windowFrames: [
          .notes: CGRect(x: 70, y: 45, width: 440, height: 340),
          .settings: CGRect(x: 300, y: 170, width: 350, height: 270)
        ]
      )
      let view = snapshotCanvas {
        Workspace95(
          for: SnapshotWorkspaceRoute.self,
          state: .constant(state),
          presentation: .windowed
        ) { route in
          WorkspaceWindow95(route.title) {
            workspaceIcon(route == .notes ? .blue : .gray)
          } taskBarIcon: {
            workspaceIcon(route == .notes ? .blue : .gray)
          } content: {
            VStack(alignment: .leading, spacing: 12) {
              Text95(route == .notes ? "Regular-width workspace" : "Display settings")
              Divider95()
              Checkbox95("Enabled", isOn: .constant(true))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
          }
          .statusBar95 {
            Text95("Ready")
          }
        } desktop: {
          Desktop95(allowsShortcutMovement: false, shortcutActivation: .doubleClick) {
            DesktopShortcut95("Notes", value: SnapshotWorkspaceRoute.notes) {
              workspaceIcon(.blue)
            }
            DesktopShortcut95("Settings", value: SnapshotWorkspaceRoute.settings) {
              workspaceIcon(.gray)
            }
          }
        } taskBar: {
          TaskBar95("Start") {
            workspaceIcon(.green)
          } menu: {
            StartMenu95 {
              WorkspaceLink95("Notes", value: SnapshotWorkspaceRoute.notes)
              WorkspaceLink95("Settings", value: SnapshotWorkspaceRoute.settings)
            }
          } tray: {
            Text95("12:00")
          }
        }
      }

      assertSnapshot95(of: view, as: imageSnapshot(width: 820, height: 650))
    }
    private func workspaceIcon(_ color: Color) -> some View {
      color
        .frame(width: 18, height: 18)
        .bevel95(.raised)
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

    private func imageSnapshot<V: View>(
      width: CGFloat = 390,
      height: CGFloat
    ) -> Snapshotting<V, UIImage> {
      .image(
        precision: 1,
        perceptualPrecision: 0.98,
        layout: .fixed(width: width, height: height),
        traits: snapshotTraits()
      )
    }
  }

  private enum SnapshotWorkspaceRoute: Hashable {
    case notes
    case settings

    var title: String {
      switch self {
      case .notes: "Untitled - Notepad"
      case .settings: "Settings"
      }
    }
  }
#endif
