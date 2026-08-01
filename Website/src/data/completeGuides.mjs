const swiftView = (name, body, state = '') => `import Swift95
import SwiftUI

struct ${name}Example: View {
${state ? `  ${state}\n\n` : ''}  var body: some View {
${body
	.split('\n')
	.map((line) => (line ? `    ${line}` : ''))
	.join('\n')}
  }
}`;

const preview = (file, width, height, alt, caption) => ({
	alt,
	caption,
	height,
	src: `/images/${file}`,
	width,
});

const API = '/api/documentation/swift95';

export const completeGuides = {
	'text-field': {
		description: 'A single-line native text field with a sunken Swift95 input surface.',
		summary:
			'TextField95 preserves SwiftUI editing, focus, submission, and accessibility behavior while supplying classic input styling.',
		preview: preview(
			'textfield95-compact-macos.png',
			420,
			76,
			'TextField95 containing Jane Doe',
			'The compact, complete field rendered by the snippet below.',
		),
		code: swiftView(
			'TextField95',
			`TextField95("Name", text: $name)
  .swiftUI { field in
    field.textContentType(.name)
  }
  .frame(width: 380)`,
			'@State private var name = "Jane Doe"',
		),
		facts: [
			['Binding', 'Reads and writes the supplied String binding.'],
			['Native APIs', 'Use swiftUI(_:) for content type, capitalization, focus, and submit behavior.'],
			['Sizing', 'The field accepts its parent’s proposed width; constrain it in wide forms when a shorter value is expected.'],
			['State', 'Disabled colors and the sunken bevel come from the active Theme95.'],
		],
		related: ['secure-field', 'text-editor', 'theme'],
	},
	'secure-field': {
		description: 'A secure native text field with classic input styling.',
		summary:
			'SecureField95 keeps the system secure-entry behavior and styles the field without exposing or duplicating its private value.',
		preview: preview(
			'securefield95-compact-macos.png',
			420,
			76,
			'SecureField95 containing an obscured windows95 password',
			'The complete secure field rendered by the snippet below.',
		),
		code: swiftView(
			'SecureField95',
			`SecureField95("Password", text: $password)
  .swiftUI { field in
    field.textContentType(.password)
  }
  .frame(width: 380)`,
			'@State private var password = "windows95"',
		),
		facts: [
			['Privacy', 'Uses SwiftUI SecureField for native obscured text entry.'],
			['Native APIs', 'Use swiftUI(_:) for text content type and submit behavior.'],
			['Sizing', 'Choose a width that fits the expected credential instead of filling an entire desktop form.'],
			['State', 'Inherits enabled state, colors, fonts, and metrics from the environment.'],
		],
		related: ['text-field', 'strings', 'theme'],
	},
	'text-editor': {
		description: 'A multiline editor with a sunken surface and optional classic scroll indicator.',
		summary:
			'TextEditor95 wraps SwiftUI text editing in the same input treatment used by the rest of Swift95.',
		preview: preview(
			'texteditor95-macos.png',
			390,
			290,
			'TextEditor95 multiline text control',
			'The fitting and overflowing editors rendered by the snippet below.',
		),
		code: swiftView(
			'TextEditor95',
			`VStack(alignment: .leading, spacing: 12) {
  TextEditor95(text: .constant("Content fits without scrolling"))
    .frame(height: 90)

  TextEditor95(
    text: .constant(
      (1...20).map { "Overflow line \\($0)" }.joined(separator: "\\n")
    )
  )
  .frame(height: 130)
}`,
		),
		facts: [
			['Scrolling', 'Long text scrolls vertically with the component’s classic indicator.'],
			['Binding', 'Edits the supplied String binding directly.'],
			['Sizing', 'Give the editor an explicit or constrained height in flexible layouts.'],
		],
		related: ['text-field', 'scroll-indicator', 'theme'],
	},
	picker: {
		description: 'A compact menu picker with classic disclosure and selection styling.',
		summary:
			'Picker95 presents typed values in a familiar collapsed control and preserves SwiftUI selection semantics.',
		preview: preview(
			'picker95-compact-macos.png',
			420,
			78,
			'Picker95 showing Name as the selected sort order',
			'The compact closed picker rendered by the snippet below; activating it reveals both options.',
		),
		code: swiftView(
			'Picker95',
			`Picker95(
  "Sort by",
  selection: $sortOrder,
  options: [
    PickerOption95("Name", value: SortOrder.name),
    PickerOption95("Date modified", value: SortOrder.dateModified)
  ]
)
.frame(width: 380)`,
			`private enum SortOrder: Hashable { case name, dateModified }
  @State private var sortOrder = SortOrder.name`,
		),
		facts: [
			['Selection', 'The tag type must match the selection binding type.'],
			['Presentation', 'The menu placement adapts to available space.'],
			['Keyboard', 'Retains native focus and keyboard selection behavior.'],
		],
		related: ['menu', 'tabs', 'theme'],
	},
	slider: {
		description: 'A continuous or stepped value control with a classic track and thumb.',
		summary:
			'Slider95 keeps SwiftUI value binding and accessibility adjustment while drawing a Windows 95-inspired control.',
		preview: preview(
			'slider95-macos.png',
			390,
			230,
			'Slider95 minimum, maximum, and zero-length range states',
			'The three boundary states rendered by the snippet below.',
		),
		code: swiftView(
			'Slider95',
			`VStack(alignment: .leading, spacing: 16) {
  Slider95(value: .constant(0.0), in: 0...1) {
    Text("Minimum")
  }
  Slider95(value: .constant(1.0), in: 0...1) {
    Text("Maximum")
  }
  Slider95(value: .constant(0.0), in: 0...0) {
    Text("Zero-length range")
  }
}`,
		),
		facts: [
			['Values', 'Supports BinaryFloatingPoint bindings, ranges, and optional steps.'],
			['Accessibility', 'Exposes adjustable semantics through the embedded native slider.'],
			['State', 'The track, thumb, label, and disabled treatment use Theme95 tokens.'],
		],
		related: ['progress-view', 'value-formatters', 'metrics'],
	},
	text: {
		description: 'SwiftUI text rendered with the active Swift95 typography and colors.',
		summary:
			'Text95 is the direct choice for labels and copy that should inherit the library’s body font and state-aware colors.',
		preview: preview(
			'text95-states-macos.png',
			320,
			104,
			'Text95 labels in enabled and disabled states',
			'The enabled and disabled labels rendered by the snippet below.',
		),
		code: swiftView(
			'Text95',
			`VStack(alignment: .leading, spacing: 10) {
  Text95("Ready")
  Text95("Unavailable")
    .disabled(true)
}`,
		),
		facts: [
			['Typography', 'Uses the active theme’s body font by default.'],
			['State', 'Automatically switches to disabled foreground tokens.'],
			['Composition', 'Use ordinary SwiftUI layout and modifiers around Text95.'],
		],
		related: ['fonts', 'colors', 'theme'],
	},
	image: {
		description: 'An image surface with optional nearest-neighbor rendering and a sunken bevel.',
		summary:
			'Image95 is useful for bitmap artwork that should remain crisp and sit inside a classic recessed surface.',
		preview: preview(
			'image95-symbol-macos.png',
			160,
			130,
			'Image95 displaying a photo symbol in a recessed frame',
			'The non-pixelated symbol surface rendered by the snippet below.',
		),
		code: swiftView(
			'Image95',
			`Image95(
  Image(systemName: "photo").resizable(),
  isPixelated: false
)
.scaledToFit()
.padding(18)
.frame(width: 120, height: 90)`,
		),
		facts: [
			['Pixelation', 'A two-point pixelation effect is enabled by default; disable it for vectors or photographs that should remain smooth.'],
			['Surface', 'Content is clipped inside a theme-aware sunken bevel.'],
			['Native APIs', 'Use swiftUI(_:) to transform the embedded Image.'],
		],
		related: ['async-image', 'icon', 'bevel'],
	},
	'async-image': {
		description: 'Remote image loading with SwiftUI phases and Swift95 image treatment.',
		summary:
			'AsyncImage95 adds the same optional pixelation and image surface while leaving loading, success, and failure policy explicit.',
		code: swiftView(
			'AsyncImage95',
			`AsyncImage95(
  url: URL(string: "https://example.com/avatar.png"),
  isPixelated: false
) { phase in
  switch phase {
  case .empty:
    ProgressView95("Loading")
  case let .success(image):
    image.resizable().scaledToFill()
  case .failure:
    Image(systemName: "photo")
  @unknown default:
    EmptyView()
  }
}
.frame(width: 120, height: 90)`,
		),
		facts: [
			['Loading', 'Delegates URL loading and phase transitions to SwiftUI AsyncImage.'],
			['Phases', 'Handle empty, success, and failure when the surrounding layout needs deterministic placeholders.'],
			['Rendering', 'Pixelation can be disabled for photographic content.'],
		],
		related: ['image', 'progress-view', 'bevel'],
	},
	list: {
		description: 'A selectable list with classic rows, separators, icons, and scroll treatment.',
		summary:
			'List95 supports unselected, single-selection, multiple-selection, and sectioned data without replacing your model identity.',
		preview: preview(
			'list95-compact-macos.png',
			420,
			252,
			'Compact List95 with Item 2 and Item 4 selected',
			'The compact multi-selection list rendered by the snippet below.',
		),
		code: `import Swift95
import SwiftUI

private struct ListItem: Identifiable {
  let id: Int
  let title: String
}

struct List95Example: View {
  private let items = (1...12)
    .map {
      ListItem(id: $0, title: "Item \\($0)")
    }
  @State private var selection: Set<Int> = [2, 4]

  var body: some View {
    List95(items, selection: $selection, style: .compact) { item in
      Row95 { Text95(item.title) }
    }
    .frame(width: 380, height: 212)
  }
}`,
		facts: [
			['Identity', 'Rows use each Identifiable element’s stable ID.'],
			['Selection', 'Optional single and Set bindings support selection.'],
			['Style', 'Choose largeIcon or compact row metrics and opt into separators.'],
		],
		related: ['scroll-view', 'scroll-indicator', 'divider'],
	},
	tabs: {
		description: 'A typed tab strip and raised content panel.',
		summary:
			'Tabs95 makes the current tab explicit through a Hashable selection binding and an ordered set of Tab95 values.',
		preview: preview(
			'tabs95-compact-macos.png',
			460,
			184,
			'Tabs95 tab strip and content panel',
			'The three tabs and selected General panel rendered by the snippet below.',
		),
		code: swiftView(
			'Tabs95',
			`Tabs95(
  selection: $section,
  tabs: [
    Tab95("General", value: Section.general),
    Tab95("Display", value: Section.display),
    Tab95("Advanced", value: Section.advanced)
  ]
) { selected in
  Text95(selected.title)
    .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
}
.frame(width: 420)`,
			`private enum Section: String, Hashable {
    case general = "General"
    case display = "Display"
    case advanced = "Advanced"

    var title: String { rawValue }
  }
  @State private var section = Section.general`,
		),
		facts: [
			['Type safety', 'Tab values and the selection binding share one Hashable type.'],
			['Ordering', 'The tab array determines visual and keyboard order.'],
			['Native APIs', 'Tab95.swiftUI(_:) supports per-tab keyboard and accessibility modifiers.'],
		],
		related: ['picker', 'list', 'bevel'],
	},
	'progress-view': {
		description: 'Determinate and indeterminate progress rendered as a classic bar.',
		summary:
			'ProgressView95 preserves SwiftUI progress semantics and adds continuous or segmented Swift95 rendering.',
		preview: preview(
			'progressview95-variants-macos.png',
			420,
			216,
			'Continuous, segmented, and indeterminate ProgressView95 variants',
			'The three public progress modes rendered by the snippet below.',
		),
		code: swiftView(
			'ProgressView95',
			`VStack(alignment: .leading, spacing: 14) {
  ProgressView95("Continuous", value: 0.42)
  ProgressView95("Segmented", value: 0.68, barStyle: .segmented)
  ProgressView95("Searching…")
}
.frame(width: 380)`,
		),
		facts: [
			['Modes', 'Omit value for an animated indeterminate bar, or pass value and total for determinate progress.'],
			['Style', 'Continuous bars include a percentage label; segmented bars use classic blocks.'],
			['Motion', 'Indeterminate animation respects Reduce Motion and uses Motion95 timing tokens.'],
			['Formatting', 'Visible and accessible percentage text uses ValueFormatters95.'],
		],
		related: ['slider', 'value-formatters', 'motion'],
	},
	'scroll-view': {
		description: 'A vertical SwiftUI scroll view with a classic sunken viewport and indicator.',
		summary:
			'ScrollView95 composes native scrolling with the library’s track, thumb, line buttons, and accessibility actions.',
		preview: preview(
			'scrollview95-macos.png',
			390,
			210,
			'ScrollView95 with classic indicator',
			'Overflowing and fitting content rendered by the two containers below.',
		),
		code: swiftView(
			'ScrollView95',
			`HStack(alignment: .top, spacing: 16) {
  ScrollView95(lineIncrement: 28) {
    LazyVStack(alignment: .leading, spacing: 0) {
      ForEach(1...10, id: \\.self) { line in
        Text95("Line \\(line)")
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
}`,
		),
		facts: [
			['Axis', 'Provides a vertical scrolling container.'],
			['Indicator', 'The classic indicator can be hidden or transformed independently.'],
			['Native APIs', 'Use swiftUI(_:) to configure the embedded ScrollView.'],
		],
		related: ['scroll-indicator', 'list', 'text-editor'],
	},
	'scroll-indicator': {
		description: 'A standalone classic vertical scroll track, thumb, and line controls.',
		summary:
			'ScrollIndicator95 is for custom scrolling surfaces that already own a content-coordinate offset.',
		preview: preview(
			'scrollindicator95-macos.png',
			390,
			230,
			'ScrollIndicator95 track and thumb',
			'Overflowing and non-scrollable indicators rendered by the snippet below.',
		),
		code: swiftView(
			'ScrollIndicator95',
			`HStack(alignment: .top, spacing: 24) {
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
}`,
		),
		facts: [
			['Offset', 'The binding is measured in content coordinates and clamped to the valid scrollable range.'],
			['Thumb', 'Content and viewport lengths determine the thumb’s size and position.'],
			['Use', 'Prefer ScrollView95 or List95 unless building a custom scrolling host.'],
		],
		related: ['scroll-view', 'list', 'metrics'],
	},
	divider: {
		description: 'A two-pixel horizontal or vertical etched separator.',
		summary:
			'Divider95 uses paired dark and light theme colors to separate adjacent regions without introducing container chrome.',
		preview: preview(
			'divider95-context-macos.png',
			460,
			104,
			'Horizontal Divider95 separating two labels',
			'The divider shown in a small, practical layout rendered by the snippet below.',
		),
		code: swiftView(
			'Divider95',
			`VStack(alignment: .leading, spacing: 10) {
  Text95("General")
  Divider95()
  Text95("Advanced")
}
.frame(width: 420)`,
		),
		facts: [
			['Axis', 'Horizontal is the default; pass .vertical for side-by-side content.'],
			['Tokens', 'The etched pair uses active theme border colors.'],
			['Layout', 'The divider expands along its primary axis.'],
		],
		related: ['bevel', 'colors', 'spacing'],
	},
	alert: {
		description: 'A modal Swift95 alert presented from any SwiftUI view.',
		summary:
			'The alert95 modifier renders a themed modal while preserving native Button roles, enabled state, keyboard shortcuts, and dismissal semantics.',
		preview: preview(
			'alert95-macos.png',
			390,
			350,
			'Swift95 alert with actions',
			'The open alert produced after activating the button in the snippet below.',
		),
		code: swiftView(
			'Alert95',
			`Button95("Replace file") {
  isPresented = true
}
.alert95(
  "Replace file?",
  isPresented: $isPresented,
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
)`,
			'@State private var isPresented = false',
		),
		facts: [
			['Actions', 'Supply native SwiftUI Button values; Swift95 renders their labels and roles.'],
			['Dismissal', 'Actions and the enabled close control set isPresented to false.'],
			['Platform', 'Uses an app modal on compact platforms and a child panel on macOS.'],
		],
		related: ['button', 'workspace-window-actions', 'strings'],
	},
};

export const supplementalGuides = {
	workspace: {
		description: 'A route-driven desktop, window host, and taskbar.',
		summary:
			'Workspace95 owns or binds logical window state and chooses compact or overlapping presentation for the available size.',
		preview: preview(
			'workspace95-windowed-macos.png',
			820,
			650,
			'Workspace95 with desktop, windows, and taskbar',
			'The two-window desktop, shortcuts, taskbar, and tray rendered by the snippet below.',
		),
		code: `import Swift95
import SwiftUI

private enum WorkspaceRoute: Hashable {
  case notes
  case settings

  var title: String {
    self == .notes ? "Untitled - Notepad" : "Settings"
  }
}

struct Workspace95Example: View {
  @State private var state = WorkspaceState95<WorkspaceRoute>(
    openWindows: [.notes, .settings],
    activeWindow: .notes,
    windowFrames: [
      .notes: CGRect(x: 70, y: 45, width: 440, height: 340),
      .settings: CGRect(x: 300, y: 170, width: 350, height: 270)
    ]
  )

  var body: some View {
    Workspace95(
      for: WorkspaceRoute.self,
      state: $state,
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
      .statusBar95 { Text95("Ready") }
    } desktop: {
      Desktop95(allowsShortcutMovement: false, shortcutActivation: .doubleClick) {
        DesktopShortcut95("Notes", value: WorkspaceRoute.notes) {
          workspaceIcon(.blue)
        }
        DesktopShortcut95("Settings", value: WorkspaceRoute.settings) {
          workspaceIcon(.gray)
        }
      }
    } taskBar: {
      TaskBar95(
        "Start",
        icon: {
          workspaceIcon(.green)
        },
        menu: {
          StartMenu95 {
            WorkspaceLink95("Notes", value: WorkspaceRoute.notes)
            WorkspaceLink95("Settings", value: WorkspaceRoute.settings)
          }
        },
        tray: {
          Text95("12:00")
        })
    }
  }

  private func workspaceIcon(_ color: Color) -> some View {
    color.frame(width: 18, height: 18).bevel95(.raised)
  }
}`,
		facts: [
			['Routes', 'One Hashable route type identifies shortcuts, windows, and tasks.'],
			['Lifetime', 'Open windows remain mounted while inactive or minimized.'],
			['Presentation', 'Automatic mode resolves to compact or windowed using WorkspaceConfiguration95.'],
		],
		related: ['workspace-state', 'workspace-window', 'desktop'],
	},
	'workspace-window': {
		description: 'A logical workspace window with title, icon, content, menus, and status.',
		summary:
			'WorkspaceWindow95 describes window content and capabilities; Workspace95 supplies positioning, activation, and task integration.',
		code: `import Swift95
import SwiftUI

@MainActor
func makeNotesWindow() -> WorkspaceWindow95 {
  WorkspaceWindow95(
    "Notes",
    icon: {
      Color.blue.frame(width: 16, height: 16)
    }
  ) {
    TextEditor95(text: .constant("Write here"))
  }
  .statusBar95 {
    Text95("Ready")
  }
}`,
		facts: [
			['Host', 'Create it from the Workspace95 route closure, not as a standalone desktop window.'],
			['Chrome', 'Menu, status, resize-control, and configuration modifiers return updated descriptors.'],
			['Icons', 'A convenience initializer shares one icon between title bar and taskbar.'],
		],
		related: ['workspace', 'workspace-window-configuration', 'workspace-window-actions'],
	},
	desktop: {
		description: 'A classic desktop surface that lays out and optionally moves shortcuts.',
		summary:
			'Desktop95 supplies selection, activation, drag placement, and an optional custom background for DesktopShortcut95 values.',
		code: swiftView(
			'Desktop95',
			`Desktop95 {
  DesktopShortcut95("Notes", value: Route.notes) {
    Color.blue.frame(width: 32, height: 32)
  }
}`,
			'private enum Route: Hashable { case notes }',
		),
		facts: [
			['Movement', 'Shortcut movement is enabled by default and can be disabled.'],
			['Activation', 'Choose single-click or double-click activation.'],
			['Persistence', 'Attach desktopState95 to own or persist shortcut offsets.'],
		],
		related: ['desktop-shortcut', 'desktop-state', 'classic-workspace-background'],
	},
	'desktop-shortcut': {
		description: 'A route-valued desktop icon and title.',
		summary:
			'DesktopShortcut95 participates in Desktop95 selection, activation, movement, and workspace opening behavior.',
		code: swiftView(
			'DesktopShortcut95',
			`DesktopShortcut95("Computer", value: Route.computer) {
  Color.gray.frame(width: 32, height: 32)
}`,
			'private enum Route: Hashable { case computer }',
		),
		facts: [
			['Identity', 'The route value provides stable identity and the window-opening destination.'],
			['Context', 'Place shortcuts inside Desktop95 for selection and placement behavior.'],
			['Icon', 'The icon closure accepts any SwiftUI view, including Swift95Icons.Icon95.'],
		],
		related: ['desktop', 'workspace-link', 'icon'],
	},
	'workspace-link': {
		description: 'A button that opens or focuses a route in the nearest workspace.',
		summary:
			'WorkspaceLink95 is the shared launch action for Start-menu rows and other controls that target Workspace95.',
		code: swiftView(
			'WorkspaceLink95',
			`WorkspaceLink95("Notes", value: Route.notes)
  .swiftUI { button in
    button.keyboardShortcut("n", modifiers: .command)
  }`,
			'private enum Route: Hashable { case notes }',
		),
		facts: [
			['Action', 'Opens a closed route or focuses its existing window.'],
			['Menu', 'Dismisses the enclosing StartMenu95 after activation.'],
			['Native APIs', 'Use swiftUI(_:) for keyboard shortcuts and context menus.'],
		],
		related: ['workspace', 'start-menu', 'open-workspace-window-action'],
	},
	'task-bar': {
		description: 'A Start button, live workspace tasks, and optional tray.',
		summary:
			'TaskBar95 reads task state from Workspace95 and renders activation and minimization controls automatically.',
		code: swiftView(
			'TaskBar95',
			`TaskBar95(
  "Start",
  icon: {
    Color.blue.frame(width: 16, height: 16)
  },
  menu: {
    StartMenu95 { Text95("Programs") }
  },
  tray: {
    Text95("12:00")
  })`,
		),
		facts: [
			['Tasks', 'Open workspace routes appear between the Start button and tray.'],
			['Interaction', 'Selecting the active task minimizes it when the window allows minimization.'],
			['Customization', 'Transforms are available for Start and task buttons.'],
		],
		related: ['workspace', 'start-menu', 'workspace-state'],
	},
	'start-menu': {
		description: 'A raised vertical panel for launch commands.',
		summary:
			'StartMenu95 provides classic sizing, spacing, pressed-row styling, and dismissal context to its content.',
		code: swiftView(
			'StartMenu95',
			`StartMenu95 {
  WorkspaceLink95("Notes", value: Route.notes)
  WorkspaceLink95("Settings", value: Route.settings)
}`,
			'private enum Route: Hashable { case notes, settings }',
		),
		facts: [
			['Content', 'Compose links, buttons, text, and dividers with ordinary view builders.'],
			['Rows', 'Buttons receive full-width classic menu-row treatment.'],
			['Context', 'WorkspaceLink95 dismisses the menu after opening a route.'],
		],
		related: ['task-bar', 'workspace-link', 'menu'],
	},
	'classic-workspace-background': {
		description: 'The active theme’s edge-to-edge desktop background.',
		summary:
			'ClassicWorkspaceBackground95 is the minimal reusable desktop surface and automatically follows Theme95 workspace colors.',
		code: swiftView(
			'ClassicWorkspaceBackground95',
			`ClassicWorkspaceBackground95()
  .ignoresSafeArea()`,
		),
		facts: [
			['Color', 'Uses Theme95.colors.workspaceBackground.'],
			['Layout', 'Expands to all proposed width and height.'],
			['Desktop', 'Desktop95 already installs this beneath custom background content.'],
		],
		related: ['desktop', 'colors', 'theme'],
	},
	'workspace-configuration': {
		description: 'Workspace-wide presentation thresholds and window placement defaults.',
		summary:
			'WorkspaceConfiguration95 controls when automatic presentation becomes windowed and how new windows are initially sized and cascaded.',
		code: `import Swift95

let workspaceConfiguration: WorkspaceConfiguration95 = {
  var configuration = WorkspaceConfiguration95.default
  configuration.automaticWindowedMinimumSize.width = 720
  configuration.cascadeCount = 4
  configuration.cascadeStep = 24
  return configuration
}()`,
		facts: [
			['Scope', 'Pass the value to Workspace95; it applies to the whole workspace.'],
			['Presentation', 'automaticWindowedMinimumSize controls automatic mode.'],
			['Placement', 'Fractions, bounds, cascade values, and center offset define initial frames.'],
		],
		related: ['workspace', 'workspace-presentation', 'workspace-window-configuration'],
	},
	'workspace-state': {
		description: 'Serializable logical window order, activation, minimization, and frames.',
		summary:
			'WorkspaceState95 lets an app own and restore the exact state that Workspace95 would otherwise keep transiently.',
		code: `import Swift95

private enum Route: Hashable {
  case notes
  case settings
}

private struct WorkspaceStateExample {
  var state = WorkspaceState95<Route>(
    openWindows: [.notes, .settings],
    activeWindow: .notes
  )
}`,
		facts: [
			['Binding', 'Pass a Binding to Workspace95 to observe and control its state.'],
			['Normalization', 'Initialization removes duplicate routes and repairs order invariants.'],
			['Persistence', 'The type is Codable when Route is Codable.'],
		],
		related: ['workspace', 'desktop-state', 'workspace-presentation'],
	},
	'workspace-window-configuration': {
		description: 'Minimum size and capabilities for one logical window.',
		summary:
			'WorkspaceWindowConfiguration95 declares which window controls and interactions are available independently for each route.',
		code: `import CoreGraphics
import Swift95

let inspectorConfiguration = WorkspaceWindowConfiguration95(
  minimumSize: CGSize(width: 320, height: 240),
  capabilities: [.close, .resize, .move]
)`,
		facts: [
			['Capabilities', 'Minimize, maximize, close, resize, and move are independent options.'],
			['Default', 'The standard set enables every capability.'],
			['Application', 'Attach it with WorkspaceWindow95.configuration95(_:) in the route closure.'],
		],
		related: ['workspace-window', 'workspace-configuration', 'workspace-window-resize-control'],
	},
	'workspace-window-actions': {
		description: 'Environment actions that close or minimize the containing logical window.',
		summary:
			'WorkspaceWindowActions95 gives deeply nested content a route-independent way to target the window currently hosting it.',
		code: swiftView(
			'WorkspaceWindowActions95',
			`HStack {
  Button95("Minimize") { window.minimize() }
  Button95("Close") { window.close() }
}`,
			'@Environment(\\.workspaceWindow95) private var window',
		),
		facts: [
			['Context', 'The nearest WorkspaceWindow95 host supplies the actions.'],
			['No-op', 'Default environment actions safely do nothing outside a workspace window.'],
			['Capabilities', 'Only expose controls that match the window’s configured capabilities.'],
		],
		related: ['workspace-window', 'workspace-window-configuration', 'button'],
	},
	'workspace-presentation': {
		description: 'Compact, overlapping-window, or size-adaptive workspace layout.',
		summary:
			'WorkspacePresentation95 selects whether the active window fills the workspace or logical windows overlap on a desktop.',
		code: `import Swift95

let phonePresentation: WorkspacePresentation95 = .compact
let desktopPresentation: WorkspacePresentation95 = .windowed
let adaptivePresentation: WorkspacePresentation95 = .automatic`,
		facts: [
			['Compact', 'Only the active non-minimized window is visible and fills the host.'],
			['Windowed', 'Open windows overlap and support configured movement and resizing.'],
			['Automatic', 'Resolves using available size and WorkspaceConfiguration95.'],
		],
		related: ['workspace', 'workspace-configuration', 'workspace-state'],
	},
	'workspace-window-resize-control': {
		description: 'Controls whether a window displays its classic resize affordance.',
		summary:
			'WorkspaceWindowResizeControl95 lets a window inherit automatic behavior or explicitly show or hide the resize handle.',
		code: `import Swift95

let automaticResizeControl: WorkspaceWindowResizeControl95 = .automatic
let statusBarResizeControl: WorkspaceWindowResizeControl95 = .statusBar
let hiddenResizeControl: WorkspaceWindowResizeControl95 = .hidden`,
		facts: [
			['Automatic', 'Follows presentation and the window’s resize capability.'],
			['Status bar', 'Reserves a classic status bar and shows a grip when resizing is supported.'],
			['Hidden', 'Suppresses the visual affordance without changing other capabilities.'],
		],
		related: ['workspace-window', 'workspace-window-configuration', 'workspace-presentation'],
	},
	'desktop-state': {
		description: 'App-owned or persisted desktop shortcut offsets.',
		summary:
			'DesktopState95 separates movable shortcut placement from the desktop view so layouts can survive reconstruction or relaunch.',
		code: swiftView(
			'DesktopState95',
			`Desktop95 {
  DesktopShortcut95("Notes", value: Route.notes) { Color.blue }
}
.desktopState95($desktopState)`,
			`private enum Route: Hashable { case notes }
  @State private var desktopState = DesktopState95<Route>()`,
		),
		facts: [
			['Identity', 'Offsets are keyed by the shortcut route.'],
			['Binding', 'The binding overload keeps persistence policy in the app.'],
			['AppStorage', 'A Codable route type can use the storage-key convenience modifier.'],
		],
		related: ['desktop', 'desktop-shortcut', 'workspace-state'],
	},
	'desktop-shortcut-activation': {
		description: 'Single-click or double-click desktop shortcut launching.',
		summary:
			'DesktopShortcutActivation95 makes the desktop’s launch convention explicit while selection remains available in both modes.',
		code: swiftView(
			'DesktopShortcutActivation95',
			`Desktop95(shortcutActivation: .singleClick) {
  DesktopShortcut95("Notes", value: Route.notes) { Color.blue }
}`,
			'private enum Route: Hashable { case notes }',
		),
		facts: [
			['singleClick', 'One primary activation opens the shortcut route.'],
			['doubleClick', 'The first click selects; the second activation opens.'],
			['Scope', 'The mode applies to all shortcuts in one Desktop95.'],
		],
		related: ['desktop', 'desktop-shortcut', 'desktop-state'],
	},
	'open-workspace-window-action': {
		description: 'An environment action for opening or focusing workspace routes.',
		summary:
			'OpenWorkspaceWindow95Action is the low-level equivalent of WorkspaceLink95 when launch behavior must live inside a custom control.',
		code: swiftView(
			'OpenWorkspaceWindow95Action',
			`Button95("Open Notes") {
  openWindow(Route.notes)
}`,
			`private enum Route: Hashable { case notes }
  @Environment(\\.openWorkspaceWindow95) private var openWindow`,
		),
		facts: [
			['Route', 'The Hashable value must match the nearest Workspace95 route type.'],
			['Behavior', 'Opens a closed route or focuses and restores an existing one.'],
			['Convenience', 'Prefer WorkspaceLink95 when a styled launch label is sufficient.'],
		],
		related: ['workspace', 'workspace-link', 'desktop-shortcut'],
	},
	theme: {
		description: 'The complete set of colors, metrics, fonts, spacing, and motion tokens.',
		summary:
			'Theme95 is an environment value, so one modifier can consistently restyle a whole component subtree.',
		code: swiftView(
			'Theme95',
			`Button95("Save") {}
  .theme95(customTheme)`,
			`private var customTheme: Theme95 {
    var colors = Colors95.classic
    colors.accent = .purple
    return Theme95(
      colors: colors,
      metrics: .classic,
      fonts: .classic
    )
  }`,
		),
		facts: [
			['Inheritance', 'Swift95 components read the nearest theme95 environment value.'],
			['Nesting', 'A nested theme95 modifier can restyle only one section.'],
			['Classic', 'Theme95.classic is the default when no override is installed.'],
		],
		related: ['colors', 'fonts', 'metrics'],
	},
	colors: {
		description: 'Semantic colors for surfaces, text, selection, inputs, and bevels.',
		summary:
			'Colors95 names colors by component role, keeping custom themes consistent across interaction states.',
		code: `import Swift95
import SwiftUI

let colorTheme: Theme95 = {
  var colors = Colors95.classic
  colors.accent = .purple
  colors.link = .cyan
  return Theme95(
    colors: colors,
    metrics: .classic,
    fonts: .classic
  )
}()`,
		facts: [
			['Semantic', 'Prefer changing role tokens instead of styling individual controls.'],
			['Desktop', 'Workspace background, shortcut text, shadow, and selection have dedicated roles.'],
			['Bevels', 'Five border levels build raised, sunken, and input surfaces.'],
		],
		related: ['theme', 'bevel', 'classic-workspace-background'],
	},
	fonts: {
		description: 'Semantic and arbitrary-size typography for Swift95 content.',
		summary:
			'Fonts95 provides title roles, body text, and a font factory that can preserve Dynamic Type scaling in a custom family.',
		code: swiftView(
			'Fonts95',
			`Text("Custom body text")
  .font(
    Fonts95.classic.font(
      size: 18,
      relativeTo: .body
    ))`,
		),
		facts: [
			['Roles', 'title, title2, title3, and body cover the standard component hierarchy.'],
			['Scaling', 'Use the relativeTo overload for Dynamic Type-aware arbitrary sizes.'],
			['Classic', 'The bundled W95FA family is registered lazily.'],
		],
		related: ['text', 'theme', 'metrics'],
	},
	spacing: {
		description: 'An eight-step spacing scale used throughout Swift95 layouts.',
		summary:
			'Spacing95 centralizes small pixel-conscious gaps while still allowing a custom theme to scale component density.',
		code: swiftView(
			'Spacing95',
			`VStack(spacing: Spacing95.classic.m) {
  Text95("Name")
  TextField95("Name", text: .constant(""))
}`,
		),
		facts: [
			['Scale', 'The tokens run from xxxs through xxl.'],
			['Consistency', 'Components use semantic positions in this shared scale.'],
			['Customization', 'Install custom spacing as part of Theme95.'],
		],
		related: ['theme', 'metrics', 'divider'],
	},
	metrics: {
		description: 'Geometry tokens for controls, windows, desktop items, and taskbar content.',
		summary:
			'Metrics95 is the single source for classic sizes such as bevel width, title bars, scroll thumbs, and interaction offsets.',
		code: `import Swift95

let metricTheme: Theme95 = {
  var metrics = Metrics95.classic
  metrics.titleBarHeight = 34
  metrics.scrollBarWidth = 18
  return Theme95(
    colors: .classic,
    metrics: metrics,
    fonts: .classic
  )
}()`,
		facts: [
			['Geometry', 'Metrics affect rendering and layout, not only decoration.'],
			['Interaction', 'Minimum thumb, line increment, and resize-handle values support usability.'],
			['Customization', 'Start with .classic and change only intentional differences.'],
		],
		related: ['theme', 'spacing', 'motion'],
	},
	motion: {
		description: 'Timing tokens for feedback and indeterminate progress.',
		summary:
			'Motion95 keeps the library’s deliberately restrained interaction timings coherent and replaceable.',
		code: `import Swift95

let reducedMotion = Motion95(
  quick: 0,
  feedback: 0,
  indeterminateProgressCycle: 1.2,
  indeterminateProgressFPS: 15
)`,
		facts: [
			['quick', 'Short state changes that should feel immediate.'],
			['feedback', 'Pressed and interaction feedback timing.'],
			['Progress', 'Cycle duration and FPS configure indeterminate bars.'],
		],
		related: ['theme', 'progress-view', 'metrics'],
	},
	bevel: {
		description: 'Theme-aware raised, sunken, and input edge treatment.',
		summary:
			'bevel95(_:) applies the classic multi-edge surface without changing layout or hit testing.',
		code: swiftView(
			'Bevel95',
			`Text95("Status: Ready")
  .padding(8)
  .bevel95(.raised)`,
		),
		facts: [
			['Styles', 'Raised, sunken, and input styles select edge direction and default background.'],
			['Layout', 'The effect draws inside the existing bounds.'],
			['Theme', 'Border width, border colors, and surface colors come from Theme95.'],
		],
		related: ['colors', 'metrics', 'theme'],
	},
	strings: {
		description: 'Localized library-owned labels and accessibility text.',
		summary:
			'Strings95 lets an app replace Swift95’s built-in window, scrolling, and state descriptions for a subtree.',
		code: swiftView(
			'Strings95',
			`Text95("Localized workspace")
  .strings95(customStrings)`,
			`private var customStrings: Strings95 {
    var strings = Strings95.localized
    strings.close = "Dismiss"
    return strings
  }`,
		),
		facts: [
			['Scope', 'The modifier installs strings through the SwiftUI environment.'],
			['Defaults', 'Strings95.localized uses the library’s resource bundle.'],
			['Coverage', 'Includes window controls, scrolling actions, and expanded or active state text.'],
		],
		related: ['workspace-window', 'scroll-indicator', 'theme'],
	},
	'value-formatters': {
		description: 'Environment-supplied formatting for library-owned values.',
		summary:
			'ValueFormatters95 controls localized percentage output shown by continuous progress bars and their accessibility values.',
		code: swiftView(
			'ValueFormatters95',
			`ProgressView95(value: 0.42)
  .valueFormatters95(formatters)`,
			`private let formatters = ValueFormatters95 {
    fraction, _ in "\\(Int(fraction * 100)) percent"
  }`,
		),
		facts: [
			['Locale', 'The formatter receives the current SwiftUI Locale.'],
			['Scope', 'Install it for a view subtree with valueFormatters95(_:)'],
			['Default', 'The localized formatter uses Foundation percent formatting.'],
		],
		related: ['progress-view', 'strings', 'theme'],
	},
	icon: {
		description: 'Bundled Windows 95-inspired pixel icons with typed names and sizes.',
		summary:
			'Icon95 loads packaged PNG renditions, preserves nearest-neighbor rendering, and exposes SwiftUI and platform-image escape hatches.',
		preview: preview(
			'icon95-computer.png',
			32,
			32,
			'Computer Icon95 artwork',
			'The exact standard computer PNG bundled by Swift95Icons.',
		),
		code: `import Swift95Icons
import SwiftUI

struct Icon95Example: View {
  var body: some View {
    Icon95(.computer, size: .standard)
      .swiftUI { icon in
        icon.accessibilityLabel("Computer")
      }
  }
}`,
		facts: [
			['Names', 'Icon95.Name is a typed catalog of bundled resources.'],
			['Sizes', 'Requested sizes fall back to an available rendition when necessary.'],
			['Rendering', 'Nearest-neighbor interpolation keeps pixel artwork crisp.'],
		],
		related: ['image', 'desktop-shortcut', 'task-bar'],
		apiPath: '/api/documentation/swift95icons/icon95',
	},
};

Object.assign(completeGuides, supplementalGuides);

export const completeGuidePages = Object.entries(completeGuides).map(
	([slug, guide]) => ({ slug, ...guide }),
);

export function apiPathForGuide(_slug, label, guide) {
	return guide.apiPath ?? `${API}/${label.toLowerCase()}`;
}
