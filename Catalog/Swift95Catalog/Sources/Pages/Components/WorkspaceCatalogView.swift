import Swift95
import Swift95Icons
import SwiftUI

struct WorkspaceCatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var workspaceState = WorkspaceState95(
    openWindows: [CatalogWorkspaceRoute.myComputer],
    activeWindow: CatalogWorkspaceRoute.myComputer
  )

  var body: some View {
    VStack(alignment: .leading, spacing: theme.spacing.xl) {
      Text95(
        "Open windows from the desktop or Start menu. Narrow layouts switch full-size tasks; wide layouts support overlapping, movable windows."
      )

      Workspace95(
        for: CatalogWorkspaceRoute.self,
        state: $workspaceState,
        window
      ) {
        Desktop95 {
          DesktopShortcut95("My Computer", value: CatalogWorkspaceRoute.myComputer) {
            workspaceIcon(.computer)
          }

          DesktopShortcut95("Notepad", value: CatalogWorkspaceRoute.notepad) {
            workspaceIcon(.notepad)
          }

          DesktopShortcut95("Settings", value: CatalogWorkspaceRoute.settings) {
            workspaceIcon(.settings)
          }
        }
        .desktopState95(
          CatalogWorkspaceRoute.self,
          storageKey: "Swift95Catalog.WorkspaceExampleDesktop"
        )
      } taskBar: {
        TaskBar95("Start") {
          workspaceTaskBarIcon(.logo, size: .standard)
        } menu: {
          StartMenu95 {
            WorkspaceLink95("My Computer", value: CatalogWorkspaceRoute.myComputer)
            WorkspaceLink95("Notepad", value: CatalogWorkspaceRoute.notepad)
            WorkspaceLink95("Settings", value: CatalogWorkspaceRoute.settings)

            Divider95()

            Button("Shut Down…") {}
          }
        } tray: {
          Text95("12:00")
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .bevel95(.sunken)
    }
    .padding(theme.spacing.xxl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .catalogNavigationTitle("Workspace95")
    .background(theme.colors.background.ignoresSafeArea())
  }

  private func window(_ route: CatalogWorkspaceRoute) -> WorkspaceWindow95 {
    switch route {
    case .myComputer:
      WorkspaceWindow95("My Computer") {
        workspaceIcon(.computer, size: .small)
      } taskBarIcon: {
        workspaceTaskBarIcon(.computer)
      } content: {
        MyComputerWindow()
      }
      .statusBar95 {
        Text95("3 objects")
      }
    case .notepad:
      WorkspaceWindow95("Untitled - Notepad") {
        workspaceIcon(.notepad, size: .small)
      } taskBarIcon: {
        workspaceTaskBarIcon(.notepad)
      } content: {
        NotepadWindow()
      }
    case .settings:
      WorkspaceWindow95("Settings") {
        workspaceIcon(.settings, size: .small)
      } taskBarIcon: {
        workspaceTaskBarIcon(.settings)
      } content: {
        SettingsWindow()
      }
      .resizeControl95(.hidden)
    }
  }

  private func workspaceIcon(
    _ name: Icon95.Name,
    size: Icon95.Size = .standard
  ) -> some View {
    Icon95(name, size: size)
      .padding(theme.spacing.xxxs)
      .accessibilityHidden(true)
  }

  private func workspaceTaskBarIcon(
    _ name: Icon95.Name,
    size: Icon95.Size = .small
  ) -> some View {
    Icon95(name, size: size)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .accessibilityHidden(true)
  }
}

private enum CatalogWorkspaceRoute: Hashable, Codable {
  case myComputer
  case notepad
  case settings
}

private struct MyComputerWindow: View {
  @Environment(\.theme95) private var theme
  @Environment(\.openWorkspaceWindow95) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: theme.spacing.xl) {
      HStack(spacing: theme.spacing.m) {
        Button95("Notepad") {
          openWindow(CatalogWorkspaceRoute.notepad)
        }
        Button95("Settings") {
          openWindow(CatalogWorkspaceRoute.settings)
        }
      }

      Divider95()

      Text95("Contents")
        .swiftUI { $0.fontWeight(.bold) }
      Text95("3½ Floppy (A:)")
      Text95("Local Disk (C:)")
      Text95("Control Panel")
    }
    .padding(theme.spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private struct NotepadWindow: View {
  @Environment(\.theme95) private var theme
  @Environment(\.openWorkspaceWindow95) private var openWindow
  @State private var text =
    "Welcome to Swift95.\n\nThis window keeps its text when another task opens."

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: theme.spacing.m) {
        Button("Settings") {
          openWindow(CatalogWorkspaceRoute.settings)
        }
        .buttonStyle(.plain)

        Spacer()
      }
      .padding(.horizontal, theme.spacing.m)
      .frame(height: 30)

      Divider95()

      TextEditor95(text: $text)
        .padding(theme.spacing.s)
    }
  }
}

private struct SettingsWindow: View {
  @Environment(\.theme95) private var theme
  @State private var soundsEnabled = true
  @State private var animationsEnabled = true

  var body: some View {
    VStack(alignment: .leading, spacing: theme.spacing.xl) {
      Text95("Workspace settings")
        .swiftUI { $0.fontWeight(.bold) }

      Checkbox95("Enable interface sounds", isOn: $soundsEnabled)
      Checkbox95("Animate windows", isOn: $animationsEnabled)

      Spacer()
    }
    .padding(theme.spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
