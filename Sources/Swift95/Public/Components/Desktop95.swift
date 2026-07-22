import SwiftUI

/// A desktop surface that arranges launch shortcuts from the top-leading corner.
///
/// Shortcuts can be selected and moved without overlapping. Connect ``DesktopState95`` with
/// ``View/desktopState95(_:)`` when their positions should survive view recreation.
///
/// ```swift
/// Desktop95 {
///   DesktopShortcut95("Notes", value: App.notes) {
///     Image95("notes")
///   }
///   DesktopShortcut95("Settings", value: App.settings) {
///     Image95("settings")
///   }
/// }
/// .desktopState95($desktopState)
/// ```
public struct Desktop95<Content: View, Background: View>: View {
  @Environment(\.desktopPositionStore) private var positionStore
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var selectedShortcut: AnyHashable?
  @State private var shortcutFrames: [AnyHashable: CGRect] = [:]
  @State private var shortcutOffsets: [AnyHashable: CGSize] = [:]

  private let content: Content
  private let background: Background
  private let allowsShortcutMovement: Bool
  private let shortcutActivation: DesktopShortcutActivation95

  /// Creates a desktop containing movable shortcuts on the theme's workspace background.
  ///
  /// - Parameters:
  ///   - allowsShortcutMovement: Whether shortcuts can be dragged to new positions.
  ///   - shortcutActivation: The click or tap behavior used to open shortcuts.
  ///   - content: The shortcuts displayed on the desktop.
  public init(
    allowsShortcutMovement: Bool = true,
    shortcutActivation: DesktopShortcutActivation95 = .automatic,
    @ViewBuilder content: () -> Content
  ) where Background == Color {
    self.content = content()
    background = Color.clear
    self.allowsShortcutMovement = allowsShortcutMovement
    self.shortcutActivation = shortcutActivation
  }

  /// Creates a desktop with custom background content.
  ///
  /// The custom background is drawn over ``ClassicWorkspaceBackground95`` and behind the shortcuts.
  public init(
    allowsShortcutMovement: Bool = true,
    shortcutActivation: DesktopShortcutActivation95 = .automatic,
    @ViewBuilder content: () -> Content,
    @ViewBuilder background: () -> Background
  ) {
    self.content = content()
    self.background = background()
    self.allowsShortcutMovement = allowsShortcutMovement
    self.shortcutActivation = shortcutActivation
  }

  /// The desktop surface.
  public var body: some View {
    GeometryReader { geometry in
      let storedOffsets = positionStore?.offsets() ?? shortcutOffsets
      let resolvedOffsets = DesktopPlacement.normalizedOffsets(
        baseFrames: shortcutFrames,
        offsets: storedOffsets,
        desktopSize: geometry.size,
        clearance: Spacing95[4]
      )
      let positionedFrames = DesktopPlacement.positionedFrames(
        baseFrames: shortcutFrames,
        offsets: resolvedOffsets
      )
      let context = DesktopContext(
        allowsShortcutMovement: allowsShortcutMovement,
        shortcutActivation: shortcutActivation.resolved(
          isCompact: horizontalSizeClass == .compact
        ),
        isSelected: { selectedShortcut == $0 },
        select: { selectedShortcut = $0 },
        offset: { resolvedOffsets[$0] ?? .zero },
        settle: { id, translation in
          var offset = resolvedOffsets[id] ?? .zero
          offset.width += translation.width
          offset.height += translation.height
          if let positionStore {
            positionStore.setOffset(id, offset)
          } else {
            shortcutOffsets[id] = offset
          }
        },
        boundedTranslation: { id, translation in
          DesktopPlacement.boundedTranslation(
            for: id,
            proposed: translation,
            frames: positionedFrames,
            desktopSize: geometry.size
          )
        },
        resolvedTranslation: { id, translation in
          DesktopPlacement.resolvedTranslation(
            for: id,
            proposed: translation,
            frames: positionedFrames,
            desktopSize: geometry.size,
            clearance: Spacing95[4]
          )
        }
      )

      ZStack(alignment: .topLeading) {
        ClassicWorkspaceBackground95()
          .contentShape(.rect)
          .onTapGesture { selectedShortcut = nil }

        background
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .contentShape(.rect)
          .onTapGesture { selectedShortcut = nil }

        VStack(alignment: .leading, spacing: Spacing95[12]) {
          content
        }
        .padding(Spacing95[12])
        .environment(\.desktopContext, context)
      }
      .coordinateSpace(name: DesktopCoordinateSpace.name)
      .onPreferenceChange(DesktopShortcutFramesPreferenceKey.self) {
        shortcutFrames = $0
      }
      .onChange(of: resolvedOffsets, initial: true) { _, normalizedOffsets in
        guard normalizedOffsets != storedOffsets else { return }

        if let positionStore {
          for (id, offset) in normalizedOffsets where storedOffsets[id] != offset {
            positionStore.setOffset(id, offset)
          }
        } else {
          shortcutOffsets = normalizedOffsets
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}
