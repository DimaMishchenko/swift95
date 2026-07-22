import Swift95
import SwiftUI

struct WorkspaceCatalogView: View {
  @Environment(\.theme95) private var theme
  @State private var workspaceState = WorkspaceState95(
    openWindows: [CatalogWorkspaceRoute.myComputer],
    activeWindow: CatalogWorkspaceRoute.myComputer
  )

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[12]) {
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
            workspaceIcon("desktopcomputer")
          }

          DesktopShortcut95("Notepad", value: CatalogWorkspaceRoute.notepad) {
            workspaceIcon("note.text")
          }

          DesktopShortcut95("Settings", value: CatalogWorkspaceRoute.settings) {
            workspaceIcon("gearshape")
          }
        }
        .desktopState95(
          CatalogWorkspaceRoute.self,
          storageKey: "Swift95Catalog.WorkspaceExampleDesktop"
        )
      } taskBar: {
        TaskBar95("Start") {
          workspaceTaskBarIcon("flag.fill")
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
    .padding(Spacing95[16])
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .catalogNavigationTitle("Workspace95")
    .background(theme.colors.background.ignoresSafeArea())
  }

  private func window(_ route: CatalogWorkspaceRoute) -> WorkspaceWindow95 {
    switch route {
    case .myComputer:
      WorkspaceWindow95("My Computer") {
        workspaceIcon("desktopcomputer")
      } taskBarIcon: {
        workspaceTaskBarIcon("desktopcomputer")
      } content: {
        MyComputerWindow()
      }
      .statusBar95 {
        Text95("3 objects")
      }
    case .notepad:
      WorkspaceWindow95("Untitled - Notepad") {
        workspaceIcon("note.text")
      } taskBarIcon: {
        workspaceTaskBarIcon("note.text")
      } content: {
        NotepadWindow()
      }
    case .settings:
      WorkspaceWindow95("Settings") {
        workspaceIcon("gearshape")
      } taskBarIcon: {
        workspaceTaskBarIcon("gearshape")
      } content: {
        SettingsWindow()
      }
      .resizeControl95(.hidden)
    }
  }

  private func workspaceIcon(_ systemName: String) -> some View {
    Image(systemName: systemName)
      .resizable()
      .scaledToFit()
      .foregroundStyle(.white)
      .padding(2)
  }

  private func workspaceTaskBarIcon(_ systemName: String) -> some View {
    Image(systemName: systemName)
      .resizable()
      .scaledToFit()
      .padding(2)
  }
}

private enum CatalogWorkspaceRoute: Hashable, Codable {
  case myComputer
  case notepad
  case settings
}

private struct MyComputerWindow: View {
  @Environment(\.openWorkspaceWindow95) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[12]) {
      HStack(spacing: Spacing95[8]) {
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
    .padding(Spacing95[12])
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private struct NotepadWindow: View {
  @Environment(\.openWorkspaceWindow95) private var openWindow
  @State private var text =
    "Welcome to Swift95.\n\nThis window keeps its text when another task opens."

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: Spacing95[8]) {
        Button("Settings") {
          openWindow(CatalogWorkspaceRoute.settings)
        }
        .buttonStyle(.plain)

        Spacer()
      }
      .padding(.horizontal, Spacing95[8])
      .frame(height: 30)

      Divider95()

      TextEditor95(text: $text)
        .padding(Spacing95[6])
    }
  }
}

private struct SettingsWindow: View {
  @State private var soundsEnabled = true
  @State private var animationsEnabled = true

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing95[12]) {
      Text95("Workspace settings")
        .swiftUI { $0.fontWeight(.bold) }

      Checkbox95("Enable interface sounds", isOn: $soundsEnabled)
      Checkbox95("Animate windows", isOn: $animationsEnabled)

      Spacer()
    }
    .padding(Spacing95[12])
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
