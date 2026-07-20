#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit
  import SnapshotTesting
  import SwiftUI
  import Testing

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct MacOSSnapshotTests {
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

    @Test func foundations() {
      let view = hostingView(width: 700, height: 380) {
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            foundationBox("Raised", style: .raised)
            foundationBox("Sunken", style: .sunken)
            foundationBox("Input", style: .input)
          }
          HStack(spacing: 12) {
            foundationBox("Raised + sunken", style: .raisedSunken)
            foundationBox("Raised + input", style: .raisedInput)
          }
          Text95("Spacing 8")
            .padding(Spacing95[8])
            .background(Theme95.classic.colors.accent)
          Text95("Metric progressBarHeight: \(Theme95.classic.metrics.progressBarHeight)")
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

    private func foundationBox(_ title: String, style: Bevel95Style) -> some View {
      Text95(title)
        .frame(maxWidth: .infinity, minHeight: 60)
        .bevel95(style)
    }

    private func foundationBox(_ title: String, style: ComposedBevel95Style) -> some View {
      Text95(title)
        .frame(maxWidth: .infinity, minHeight: 60)
        .bevel95(style)
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

#endif
