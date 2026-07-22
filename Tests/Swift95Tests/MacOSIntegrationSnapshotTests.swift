#if os(macOS)
  import AppKit
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct MacOSIntegrationSnapshotTests {
    @Test func controls() {
      let view = hostingView(width: 700, height: 700) {
        VStack(alignment: .leading, spacing: 14) {
          Text95("Text95 on macOS")
          HStack {
            Button95("Default") {}; Button95("Disabled") {}.disabled(true)
          }
          Slider95(value: .constant(0.45)) { Text("Slider") }
          TextField95("Name", text: .constant("Jane Doe"))
          SecureField95("Password", text: .constant("windows95"))
          Checkbox95("Checked", isOn: .constant(true))
          RadioButton95("Selected", value: 1, selection: .constant(1))
          ProgressView95("Progress", value: 0.42)
          Picker95(
            "Sort by",
            selection: .constant(MacPickerValue.name),
            options: [
              PickerOption95("Name", value: .name),
              PickerOption95("Date modified", value: .dateModified)
            ]
          )
        }
      }

      assertSnapshot(of: view, as: macImage(size: view.frame.size))
    }

    @Test func containers() {
      let items = (1...12).map { MacListItem(id: $0, title: "Item \($0)") }
      let view = hostingView(width: 700, height: 760) {
        VStack(alignment: .leading, spacing: 14) {
          TextEditor95(text: .constant("Line 1\nLine 2\nLine 3\nLine 4"))
            .frame(height: 100)

          HStack(alignment: .top, spacing: 14) {
            ScrollIndicator95(
              contentOffset: .constant(120),
              contentLength: 500,
              viewportLength: 140
            )
            .frame(height: 140)

            ScrollView95 {
              VStack(alignment: .leading) {
                ForEach(1...8, id: \.self) { Text95("Scroll line \($0)") }
              }
            }
            .frame(height: 140)

            List95(items, selection: .constant(Set([2, 4])), style: .compact) { item in
              Row95 { Text95(item.title) }
            }
            .frame(height: 140)
          }

          Divider95()

          Tabs95(
            selection: .constant(MacTab.general),
            tabs: [
              Tab95("General", value: .general),
              Tab95("Display", value: .display),
              Tab95("Advanced", value: .advanced)
            ]
          ) { value in
            Text95(value.title)
              .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
          }
        }
      }

      assertSnapshot(of: view, as: macImage(size: view.frame.size))
    }

    @Test func workspaceWindowed() {
      let state = WorkspaceState95<MacWorkspaceRoute>(
        openWindows: [.notes, .settings],
        activeWindow: .notes,
        windowFrames: [
          .notes: CGRect(x: 90, y: 55, width: 480, height: 360),
          .settings: CGRect(x: 340, y: 180, width: 360, height: 280)
        ]
      )
      let view = hostingView(width: 900, height: 650) {
        Workspace95(
          for: MacWorkspaceRoute.self,
          state: .constant(state),
          presentation: .windowed,
          macWorkspaceWindow
        ) {
          Desktop95(allowsShortcutMovement: false, shortcutActivation: .doubleClick) {
            DesktopShortcut95("Notes", value: MacWorkspaceRoute.notes) {
              workspaceIcon(.blue)
            }
            DesktopShortcut95("Settings", value: MacWorkspaceRoute.settings) {
              workspaceIcon(.gray)
            }
          }
        } taskBar: {
          TaskBar95("Start") {
            workspaceIcon(.green)
          } menu: {
            StartMenu95 {
              WorkspaceLink95("Notes", value: MacWorkspaceRoute.notes)
              WorkspaceLink95("Settings", value: MacWorkspaceRoute.settings)
            }
          } tray: {
            Text95("12:00")
          }
        }
      }

      assertSnapshot(of: view, as: macImage(size: view.frame.size))
    }

    private func hostingView<Content: View>(
      width: CGFloat,
      height: CGFloat,
      @ViewBuilder content: () -> Content
    ) -> NSView {
      let root = content()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .background(Theme95.classic.colors.background)
        .environment(\.theme95, .classic)
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .environment(\.colorScheme, .light)
        .environment(\.layoutDirection, .leftToRight)
        .transaction { $0.disablesAnimations = true }
      let view = NSHostingView(rootView: root)
      view.frame = CGRect(x: 0, y: 0, width: width, height: height)
      return view
    }

    private func macImage(size: CGSize) -> Snapshotting<NSView, NSImage> {
      let image = Snapshotting<NSView, NSImage>
        .image(
          precision: 1,
          perceptualPrecision: 0.98,
          size: size
        )
      return Snapshotting(
        pathExtension: image.pathExtension,
        diffing: image.diffing
      ) { view in
        Async { callback in
          let window = NSWindow(
            contentRect: view.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
          )
          window.isReleasedWhenClosed = false
          window.contentView = view
          view.layoutSubtreeIfNeeded()

          RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
          view.layoutSubtreeIfNeeded()
          image.snapshot(view)
            .run { snapshot in
              window.contentView = nil
              callback(snapshot)
            }
        }
      }
    }

    private func macWorkspaceWindow(_ route: MacWorkspaceRoute) -> WorkspaceWindow95 {
      WorkspaceWindow95(route.title) {
        workspaceIcon(route == .notes ? .blue : .gray)
      } taskBarIcon: {
        workspaceIcon(route == .notes ? .blue : .gray)
      } content: {
        VStack(alignment: .leading, spacing: 12) {
          Text95(route == .notes ? "Workspace snapshot" : "Display settings")
          Divider95()
          Checkbox95("Enabled", isOn: .constant(true))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      .statusBar95 {
        Text95("Ready")
      }
    }

    private func workspaceIcon(_ color: Color) -> some View {
      color
        .frame(width: 18, height: 18)
        .bevel95(.raised)
    }
  }

  private enum MacPickerValue: Hashable {
    case name
    case dateModified
  }

  private enum MacTab: Hashable {
    case general
    case display
    case advanced

    var title: String {
      switch self {
      case .general: "General"
      case .display: "Display"
      case .advanced: "Advanced"
      }
    }
  }

  private struct MacListItem: Identifiable {
    let id: Int
    let title: String
  }

  private enum MacWorkspaceRoute: Hashable {
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
