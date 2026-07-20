#if canImport(UIKit)
  import SnapshotTesting
  import SwiftUI
  import Testing
  import UIKit

  @testable import Swift95

  @MainActor
  @Suite(.serialized)
  struct CatalogItemSnapshotTests {
    @Test func text95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            Text95("Body text")
            Text95("Underlined through SwiftUI").swiftUI { $0.underline() }
            Text95("Disabled text").disabled(true)
          }
        },
        as: image(height: 150)
      )
    }

    @Test func button95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            Button95("Default") {}
            Button95("Disabled") {}.disabled(true)
            Button95(action: {}) {
              Label("Custom label", systemImage: "square.and.pencil")
            }
          }
        },
        as: image(height: 200)
      )
    }

    @Test func slider95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            Slider95(value: .constant(0.45), in: 0...1) { Text("Continuous") }
            Slider95(value: .constant(6.0), in: 0...10, step: 1) { Text("Stepped") }
            Slider95(value: .constant(0.35), in: 0...1) { Text("Disabled") }
              .disabled(true)
          }
        },
        as: image(height: 240)
      )
    }

    @Test func textField95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            TextField95("Name", text: .constant("Jane Doe"))
            TextField95("Empty", text: .constant(""), prompt: Text("Enter a value"))
            TextField95("Disabled", text: .constant("Read only")).disabled(true)
          }
        },
        as: image(height: 190)
      )
    }

    @Test func secureField95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            SecureField95("Password", text: .constant("windows95"))
            SecureField95("Empty", text: .constant(""), prompt: Text("Required"))
            SecureField95("Disabled", text: .constant("windows95")).disabled(true)
          }
        },
        as: image(height: 190)
      )
    }

    @Test func textEditor95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            TextEditor95(text: .constant("Line 1\nLine 2\nLine 3\nLine 4\nLine 5"))
              .frame(height: 110)
            TextEditor95(text: .constant("Disabled editor"))
              .disabled(true)
              .frame(height: 70)
          }
        },
        as: image(height: 250)
      )
    }

    @Test func scrollIndicator95() {
      assertSnapshot(
        of: canvas {
          HStack(alignment: .top, spacing: 24) {
            ScrollIndicator95(
              contentOffset: .constant(240),
              contentLength: 720,
              viewportLength: 180,
              lineIncrement: 24
            )
            .frame(height: 180)

            ScrollIndicator95(
              contentOffset: .constant(0),
              contentLength: 100,
              viewportLength: 180
            )
            .frame(height: 180)
          }
        },
        as: image(height: 230)
      )
    }

    @Test func scrollView95() {
      assertSnapshot(
        of: canvas {
          HStack(alignment: .top, spacing: 16) {
            ScrollView95(lineIncrement: 28) {
              LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(1...10, id: \.self) { line in
                  Text95("Line \(line)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 28)
                }
              }
            }
            .frame(height: 150)

            ScrollView95 {
              Text95("Content fits")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            .frame(height: 80)
          }
        },
        as: image(height: 210)
      )
    }

    @Test func divider95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
              Text95("Above")
              Divider95()
              Text95("Below")
            }
            HStack(spacing: 8) {
              Text95("Leading")
              Divider95(.vertical)
              Text95("Trailing")
            }
            .frame(height: 48)
          }
        },
        as: image(height: 200)
      )
    }

    @Test func checkbox95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            Checkbox95("Checked", isOn: .constant(true))
            Checkbox95("Unchecked", isOn: .constant(false))
            Checkbox95("Disabled checked", isOn: .constant(true)).disabled(true)
            Checkbox95("Disabled unchecked", isOn: .constant(false)).disabled(true)
          }
        },
        as: image(height: 200)
      )
    }

    @Test func radioButton95() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            RadioButton95("Selected", value: 1, selection: .constant(1))
            RadioButton95("Unselected", value: 2, selection: .constant(1))
            RadioButton95("Disabled selected", value: 1, selection: .constant(1))
              .disabled(true)
            RadioButton95("Disabled unselected", value: 2, selection: .constant(1))
              .disabled(true)
          }
        },
        as: image(height: 200)
      )
    }

    @Test func progressView95Styles() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            ProgressView95("Continuous", value: 0.42)
            ProgressView95("Segmented", value: 0.6, barStyle: .segmented)
            ProgressView95("Complete", value: 1)
            ProgressView95("Disabled", value: 0.65).disabled(true)
          }
        },
        as: image(height: 280)
      )
    }

    @Test func tabs95() {
      assertSnapshot(
        of: canvas {
          Tabs95(
            selection: .constant(SnapshotTab.general),
            tabs: [
              Tab95("General", value: .general),
              Tab95("Display", value: .display),
              Tab95("Advanced", value: .advanced)
            ]
          ) { selection in
            VStack(alignment: .leading, spacing: 8) {
              Text95(selection.title)
              Text95("Settings for the selected section.")
            }
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
          }
        },
        as: image(height: 220)
      )
    }

    @Test func sliderBoundaryStates() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            Slider95(value: .constant(0.0), in: 0...1) { Text("Minimum") }
            Slider95(value: .constant(1.0), in: 0...1) { Text("Maximum") }
            Slider95(value: .constant(0.0), in: 0...0) { Text("Zero-length range") }
          }
        },
        as: image(height: 230)
      )
    }

    @Test func textEditorContentFitAndOverflow() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            TextEditor95(text: .constant("Content fits without scrolling"))
              .frame(height: 90)
            TextEditor95(
              text: .constant((1...20).map { "Overflow line \($0)" }.joined(separator: "\n"))
            )
            .frame(height: 130)
          }
        },
        as: image(height: 290)
      )
    }

    @Test func list95LargeIconAndAccessories() {
      let items = SnapshotCatalogListItem.largeItems
      assertSnapshot(
        of: canvas {
          List95(items, style: .largeIcon) { item in
            Row95 {
              Image(systemName: item.symbol)
                .resizable()
                .scaledToFit()
            } label: {
              Text95(item.title)
            } accessory: {
              item.hasChildren
            }
          }
          .frame(height: 220)
        },
        as: image(height: 280)
      )
    }

    @Test func list95SingleSelectionAndSections() {
      let actions = SnapshotCatalogListItem.actions
      let sections = [
        List95.Section(id: "File", items: Array(actions.prefix(2))),
        List95.Section(id: "View", items: Array(actions.suffix(2)))
      ]

      assertSnapshot(
        of: canvas {
          List95(
            sections,
            selection: .constant(Optional(actions[1].id)),
            style: .compact
          ) { section in
            Text95(section.id)
          } rowContent: { item in
            Row95 { Text95(item.title) }
          }
          .frame(height: 220)
        },
        as: image(height: 280)
      )
    }

    @Test func list95DisabledAndOverflowing() {
      assertSnapshot(
        of: canvas {
          HStack(alignment: .top, spacing: 12) {
            List95(SnapshotCatalogListItem.largeItems, style: .largeIcon) { item in
              Row95 { Text95(item.title) }
            }
            .disabled(true)

            List95(SnapshotCatalogListItem.overflowItems, style: .compact) { item in
              Row95 { Text95(item.title) }
            }
          }
          .frame(height: 190)
        },
        as: image(height: 250)
      )
    }

    @Test func list95RowRenderingBranches() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 8) {
            Row95 { Text95("Normal compact row") }
              .snapshotState95(style: .compact)
            Row95 { Text95("Highlighted selected row") }
              .snapshotState95(style: .compact, isHighlighted: true, isSelected: true)
            Row95 { Text95("Pressed row") }
              .snapshotState95(style: .compact, isPressed: true)
            Row95 { Text95("Checked multiple row") }
              .snapshotState95(
                style: .compact,
                isSelected: true,
                showsSelectionMark: true
              )
            Row95 { Text95("Unchecked multiple row") }
              .snapshotState95(style: .compact, showsSelectionMark: true)
          }
        },
        as: image(height: 230)
      )
    }

    @Test func pickerDisabledAndOptionStates() {
      let picker = snapshotPicker(selection: .name)
      let longPicker = Picker95(
        "Long picker",
        selection: .constant(SnapshotPickerChoice.option1),
        options: SnapshotPickerChoice.longOptions
      )

      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            picker.disabled(true)
            picker.snapshotOptionList95(selection: .name, theme: .classic)
              .frame(width: 240)
            longPicker.snapshotOptionList95(selection: .option1, theme: .classic)
              .frame(width: 240, height: 280)
          }
        },
        as: image(height: 500)
      )
    }

    @Test func pickerPresentationBelowAndAbove() {
      let options = snapshotPicker(selection: .dateModified)
        .snapshotOptionList95(selection: .dateModified, theme: .classic)

      assertSnapshot(
        of: canvas {
          ZStack(alignment: .topLeading) {
            PickerOptionPresentationLayout95(
              triggerFrame: CGRect(x: 20, y: 30, width: 220, height: 32),
              overlap: 2
            ) {
              options
            }
          }
          .frame(width: 342, height: 360)
        },
        as: image(height: 420),
        named: "below"
      )

      assertSnapshot(
        of: canvas {
          ZStack(alignment: .topLeading) {
            PickerOptionPresentationLayout95(
              triggerFrame: CGRect(x: 20, y: 310, width: 220, height: 32),
              overlap: 2
            ) {
              options
            }
          }
          .frame(width: 342, height: 360)
        },
        as: image(height: 420),
        named: "above"
      )
    }

    @Test func deterministicPressedStates() {
      let theme = Theme95.classic
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 14) {
            Button("Pressed button") {}
              .buttonStyle(
                ButtonStyle95(
                  theme: theme,
                  contentInsets: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
                  forcedPressed: true
                )
              )

            Button("Pressed picker") {}
              .buttonStyle(PickerTriggerButtonStyle95(theme: theme, forcedPressed: true))

            Button("Pressed option") {}
              .buttonStyle(
                PickerOptionButtonStyle95(
                  pressedOption: .constant(Optional<Int>.none),
                  isSelected: false,
                  value: 1,
                  theme: theme,
                  forcedPressed: true
                )
              )

            Button("Pressed tab") {}
              .buttonStyle(
                TabButtonStyle95(
                  isSelected: false,
                  theme: theme,
                  contentInsets: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
                  forcedPressed: true
                )
              )
          }
        },
        as: image(height: 280)
      )
    }

    @Test func tabsDisabledAndOverflowing() {
      let tabs = (1...8).map { Tab95("Tab \($0)", value: $0) }
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 16) {
            Tabs95(selection: .constant(1), tabs: tabs) { value in
              Text95("Selected tab \(value)")
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
            }
            Tabs95(selection: .constant(2), tabs: Array(tabs.prefix(3))) { value in
              Text95("Disabled tab \(value)")
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
            }
            .disabled(true)
          }
        },
        as: image(height: 330)
      )
    }

    @Test func indeterminateProgressFixedPhase() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            Text95("Indeterminate — fixed phase")
            IndeterminateProgressDrawing95(
              color: Theme95.classic.colors.accent,
              phase: 0.35
            )
            .frame(height: Theme95.classic.metrics.progressBarHeight)
            .bevel95(.input)
          }
        },
        as: image(height: 130)
      )
    }

    @Test func accessibilityDynamicTypeMatrix() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 18) {
            Text95("Accessibility text")
            Button95("Accessibility button") {}
            Checkbox95("Accessibility checkbox", isOn: .constant(true))
            RadioButton95("Accessibility radio", value: 1, selection: .constant(1))
            Slider95(value: .constant(0.5)) { Text("Accessibility slider") }
            TextField95("Field", text: .constant("Accessibility field"))
            snapshotPicker(selection: .name)
            Tabs95(
              selection: .constant(SnapshotTab.general),
              tabs: [
                Tab95("General", value: .general),
                Tab95("Advanced settings", value: .advanced)
              ]
            ) { value in
              Text95(value.title)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
            }
          }
          .dynamicTypeSize(.accessibility5)
        },
        as: image(height: 1000)
      )
    }

    @Test func rightToLeftAndLongContent() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 14) {
            Button95("A long localized button title") {}
            Checkbox95("A long localized checkbox label", isOn: .constant(true))
            RadioButton95(
              "A long localized radio-button label",
              value: 1,
              selection: .constant(1)
            )
            snapshotPicker(selection: .dateModified)
            TextField95("Localized field", text: .constant("Long localized content"))
          }
          .environment(\.layoutDirection, .rightToLeft)
        },
        as: image(height: 330)
      )
    }

    @Test func bevelFoundation() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
              foundationBox("Raised", style: .raised)
              foundationBox("Sunken", style: .sunken)
              foundationBox("Input", style: .input)
            }
            HStack(spacing: 12) {
              foundationBox("Raised + sunken", style: .raisedSunken)
              foundationBox("Raised + input", style: .raisedInput)
            }
            Text95("Accent background")
              .frame(maxWidth: .infinity, minHeight: 54)
              .bevel95(.raised, background: Theme95.classic.colors.accent)
            Text95("Raised + input, custom spacing")
              .frame(maxWidth: .infinity, minHeight: 54)
              .bevel95(.raisedInput, spacing: Spacing95[8])
          }
        },
        as: image(height: 370)
      )
    }

    @Test func typographyFoundation() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 10) {
            ThemedFontSample(text: "Title", keyPath: \.title)
            ThemedFontSample(text: "Title 2", keyPath: \.title2)
            ThemedFontSample(text: "Title 3", keyPath: \.title3)
            ThemedFontSample(
              text: "The quick brown fox jumps over the lazy dog.",
              keyPath: \.body
            )
          }
        },
        as: image(height: 210)
      )
    }

    @Test func colorsFoundation() {
      assertSnapshot(
        of: canvas {
          ColorFoundationGrid()
        },
        as: image(height: 460)
      )
    }

    @Test func spacingFoundation() {
      assertSnapshot(
        of: canvas {
          VStack(alignment: .leading, spacing: 7) {
            ForEach(Array(Spacing95.initialRange), id: \.self) { value in
              HStack(spacing: 8) {
                Text95("\(value)").frame(width: 24, alignment: .trailing)
                Rectangle()
                  .fill(Theme95.classic.colors.accent)
                  .frame(width: max(1, Spacing95[value] * 5), height: 8)
              }
            }
          }
        },
        as: image(height: 700)
      )
    }

    @Test func metricsFoundation() {
      assertSnapshot(
        of: canvas {
          MetricsFoundationGrid()
        },
        as: image(height: 260)
      )
    }

    private func snapshotPicker(
      selection: SnapshotPickerChoice
    ) -> Picker95<SnapshotPickerChoice, Text, AnyView> {
      Picker95(
        "Sort by",
        selection: .constant(selection),
        options: SnapshotPickerChoice.options
      )
    }

    private func canvas<Content: View>(
      @ViewBuilder content: () -> Content
    ) -> some View {
      content()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .background(Theme95.classic.colors.background)
        .environment(\.theme95, .classic)
        .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        .environment(\.colorScheme, .light)
        .environment(\.layoutDirection, .leftToRight)
        .transaction { $0.disablesAnimations = true }
    }

    private func image<V: View>(height: CGFloat) -> Snapshotting<V, UIImage> {
      .image(
        precision: 1,
        perceptualPrecision: 0.98,
        layout: .fixed(width: 390, height: height),
        traits: UITraitCollection(traitsFrom: [
          UITraitCollection(displayScale: 1),
          UITraitCollection(userInterfaceStyle: .light),
          UITraitCollection(preferredContentSizeCategory: .large),
          UITraitCollection(layoutDirection: .leftToRight)
        ])
      )
    }

    private func foundationBox(_ title: String, style: Bevel95Style) -> some View {
      Text95(title)
        .frame(maxWidth: .infinity, minHeight: 54)
        .bevel95(style)
    }

    private func foundationBox(_ title: String, style: ComposedBevel95Style) -> some View {
      Text95(title)
        .frame(maxWidth: .infinity, minHeight: 54)
        .bevel95(style)
    }
  }

  private enum SnapshotTab: Hashable {
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

  private enum SnapshotPickerChoice: Int, Hashable, CaseIterable {
    case name
    case dateModified
    case size
    case option1
    case option2
    case option3
    case option4
    case option5
    case option6
    case option7
    case option8
    case option9

    static var options: [PickerOption95<SnapshotPickerChoice, Text>] {
      [
        PickerOption95("Name", value: .name),
        PickerOption95("Date modified", value: .dateModified),
        PickerOption95("Size", value: .size)
      ]
    }

    static var longOptions: [PickerOption95<SnapshotPickerChoice, Text>] {
      (option1.rawValue...option9.rawValue).compactMap(Self.init(rawValue:))
        .enumerated()
        .map { offset, value in
          PickerOption95("Option \(offset + 1)", value: value)
        }
    }
  }

  private struct SnapshotCatalogListItem: Identifiable {
    let id: Int
    let title: String
    let symbol: String
    let hasChildren: Bool

    static let largeItems = [
      SnapshotCatalogListItem(id: 1, title: "Programs", symbol: "folder", hasChildren: true),
      SnapshotCatalogListItem(id: 2, title: "Documents", symbol: "doc", hasChildren: true),
      SnapshotCatalogListItem(id: 3, title: "Settings", symbol: "gearshape", hasChildren: false)
    ]

    static let actions = [
      SnapshotCatalogListItem(id: 10, title: "Open", symbol: "folder", hasChildren: false),
      SnapshotCatalogListItem(
        id: 11, title: "Refresh", symbol: "arrow.clockwise", hasChildren: false),
      SnapshotCatalogListItem(
        id: 12, title: "Properties", symbol: "info.circle", hasChildren: false),
      SnapshotCatalogListItem(id: 13, title: "Close", symbol: "xmark", hasChildren: false)
    ]

    static let overflowItems = (1...18)
      .map {
        SnapshotCatalogListItem(
          id: 100 + $0,
          title: "Overflow item \($0)",
          symbol: "doc",
          hasChildren: false
        )
      }
  }

  private struct ThemedFontSample: View {
    @Environment(\.theme95) private var theme

    let text: String
    let keyPath: KeyPath<Fonts95, Font>

    var body: some View {
      Text(text).font(theme.fonts[keyPath: keyPath])
    }
  }

  private struct ColorFoundationGrid: View {
    @Environment(\.theme95) private var theme

    var body: some View {
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
        ForEach(tokens, id: \.name) { token in
          HStack(spacing: 8) {
            token.color
              .frame(width: 32, height: 32)
              .overlay { Rectangle().stroke(theme.colors.borderDarkest, lineWidth: 1) }
            VStack(alignment: .leading, spacing: 2) {
              Text95(token.name)
              Text95(token.hex).disabled(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }

    private var tokens: [(name: String, hex: String, color: Color)] {
      let colors = theme.colors
      return [
        ("background", "#C3C7CB", colors.background),
        ("text", "#000000", colors.text),
        ("textInverted", "#FFFFFF", colors.textInverted),
        ("textDisabled", "#868A8E", colors.textDisabled),
        ("disabledHighlight", "#D2D2D2", colors.textDisabledHighlight),
        ("accent", "#000E7A", colors.accent),
        ("accentText", "#FEFEFE", colors.accentText),
        ("link", "#000E7A", colors.link),
        ("linkVisited", "#440381", colors.linkVisited),
        ("input", "#FFFFFF", colors.inputBackground),
        ("inputDisabled", "#D2D2D2", colors.inputBackgroundDisabled),
        ("inactive", "#7F787F", colors.inactiveBackground),
        ("inactiveText", "#C6C6C6", colors.inactiveText),
        ("borderDarkest", "#000000", colors.borderDarkest),
        ("borderDark", "#868A8E", colors.borderDark),
        ("borderLight", "#D2D2D2", colors.borderLight),
        ("borderLighter", "#E6E6E6", colors.borderLighter),
        ("borderLightest", "#FFFFFF", colors.borderLightest)
      ]
    }
  }

  private struct MetricsFoundationGrid: View {
    @Environment(\.theme95) private var theme

    var body: some View {
      Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
        row("bevelWidth", theme.metrics.bevelWidth)
        row("checkboxSize", theme.metrics.checkboxSize)
        row("radioButtonSize", theme.metrics.radioButtonSize)
        row("scrollBarWidth", theme.metrics.scrollBarWidth)
        row("progressBarHeight", theme.metrics.progressBarHeight)
        row("titleBarHeight", theme.metrics.titleBarHeight)
        row("taskbarHeight", theme.metrics.taskbarHeight)
      }
    }

    private func row(_ name: String, _ value: CGFloat) -> some View {
      GridRow {
        Text95(name)
        Text95(value.formatted())
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
  }
#endif
