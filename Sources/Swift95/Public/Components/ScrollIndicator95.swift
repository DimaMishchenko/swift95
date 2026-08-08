import SwiftUI

/// A Windows 95-style vertical scroll indicator for custom scrollable content.
///
/// `ScrollIndicator95` provides arrow buttons, page scrolling through the track, and a draggable
/// proportional thumb. It disables its arrows and hides its thumb when the content fits within the
/// viewport. The bound offset is always written within the valid scrollable range.
///
/// Place the indicator beside clipped custom content and bind both views to the same offset:
///
/// ```swift
/// @State private var offset: CGFloat = 0
///
/// HStack(spacing: 0) {
///   content
///     .offset(y: -offset)
///     .clipped()
///
///   ScrollIndicator95(
///     contentOffset: $offset,
///     contentLength: 720,
///     viewportLength: 180,
///     lineIncrement: 24
///   )
/// }
/// .frame(height: 180)
/// ```
public struct ScrollIndicator95: View {
  @Environment(\.locale) private var locale
  @Environment(\.strings95) private var strings
  @Environment(\.theme95) private var theme
  @Environment(\.valueFormatters95) private var valueFormatters
  @State private var dragStartOffset: CGFloat?
  @Binding private var contentOffset: CGFloat

  private let contentLength: CGFloat
  private let viewportLength: CGFloat
  private let configuredLineIncrement: CGFloat?

  /// Creates a vertical scroll indicator bound to a custom scroll position.
  ///
  /// - Parameters:
  ///   - contentOffset: The current vertical offset, measured from the start of the content.
  ///   - contentLength: The total vertical length of the scrollable content.
  ///   - viewportLength: The visible vertical length of the content viewport.
  ///   - lineIncrement: The distance scrolled by an arrow button. When omitted, Swift95 derives
  ///     an increment from the viewport and theme metrics.
  public init(
    contentOffset: Binding<CGFloat>,
    contentLength: CGFloat,
    viewportLength: CGFloat,
    lineIncrement: CGFloat? = nil
  ) {
    _contentOffset = contentOffset
    self.contentLength = max(0, contentLength)
    self.viewportLength = max(0, viewportLength)
    configuredLineIncrement = lineIncrement.map { max(0, $0) }
  }

  /// The styled vertical scroll indicator.
  public var body: some View {
    VStack(spacing: 0) {
      ScrollArrowButton95(direction: .up, theme: theme) {
        scroll(by: -lineIncrement)
      }
      .disabled(!metrics.isScrollable)

      GeometryReader { geometry in
        ScrollTrack95(colors: theme.colors)
          .gesture(
            SpatialTapGesture()
              .onEnded { value in
                pageScroll(at: value.location.y, trackHeight: geometry.size.height)
              }
          )
          // The track remains available for direct touch and pointer paging, but
          // it is not a separate assistive-technology control. The arrows and
          // adjustable thumb expose the accessible scrolling actions.
          .accessibilityHidden(true)
          .overlay(alignment: .top) {
            if metrics.isScrollable {
              scrollThumb(trackHeight: geometry.size.height)
            }
          }
      }

      ScrollArrowButton95(direction: .down, theme: theme) {
        scroll(by: lineIncrement)
      }
      .disabled(!metrics.isScrollable)
    }
    .padding(theme.metrics.bevelWidth)
    .frame(width: theme.metrics.scrollBarWidth)
    .background(theme.colors.background)
  }

  private var metrics: ScrollMetrics95 {
    ScrollMetrics95(
      contentOffset: contentOffset,
      contentHeight: contentLength,
      containerHeight: viewportLength
    )
  }

  private var lineIncrement: CGFloat {
    configuredLineIncrement
      ?? max(theme.metrics.scrollLineIncrementMinimum, metrics.containerHeight * 0.1)
  }

  private func pageScroll(at location: CGFloat, trackHeight: CGFloat) {
    guard metrics.isScrollable else {
      return
    }

    let thumb = thumbGeometry(trackHeight: trackHeight)
    if location < thumb.offset {
      scroll(by: -metrics.containerHeight)
    } else if location > thumb.offset + thumb.height {
      scroll(by: metrics.containerHeight)
    }
  }

  private func scroll(by distance: CGFloat) {
    contentOffset = min(max(metrics.contentOffset + distance, 0), metrics.scrollableHeight)
  }

  @ViewBuilder
  private func scrollThumb(trackHeight: CGFloat) -> some View {
    let thumb = thumbGeometry(trackHeight: trackHeight)

    ZStack {
      Color.clear
        .frame(height: thumb.height)
        .bevel95(.raised)
        .accessibilityHidden(true)
    }
    .frame(height: thumb.height)
    .contentShape(.rect)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(strings.scrollPosition))
    .accessibilityValue(
      Text(verbatim: valueFormatters.percentage(Double(metrics.progress), locale))
    )
    .accessibilityAdjustableAction { direction in
      switch direction {
      case .increment:
        scroll(by: lineIncrement)
      case .decrement:
        scroll(by: -lineIncrement)
      @unknown default:
        break
      }
    }
    .minimumInteractionTarget95()
    .offset(y: thumb.offset)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged { value in
          dragThumb(value, trackHeight: trackHeight, thumbHeight: thumb.height)
        }
        .onEnded { _ in
          dragStartOffset = nil
        }
    )
  }

  private func dragThumb(
    _ value: DragGesture.Value,
    trackHeight: CGFloat,
    thumbHeight: CGFloat
  ) {
    let travel = max(0, trackHeight - thumbHeight)
    guard travel > 0 else {
      return
    }

    if dragStartOffset == nil {
      dragStartOffset = metrics.progress * travel
    }

    let startOffset = dragStartOffset ?? 0
    let offset = min(max(startOffset + value.translation.height, 0), travel)
    contentOffset = offset / travel * metrics.scrollableHeight
  }

  private func thumbGeometry(trackHeight: CGFloat) -> (height: CGFloat, offset: CGFloat) {
    let height = min(
      trackHeight,
      max(theme.metrics.scrollThumbMinimumLength, trackHeight * metrics.visibleFraction)
    )
    let offset = max(0, trackHeight - height) * metrics.progress
    return (height, offset)
  }
}

struct ScrollMetrics95: Equatable {
  var contentOffset = CGFloat.zero
  var contentHeight = CGFloat.zero
  var containerHeight = CGFloat.zero

  init() {}

  init(contentOffset: CGFloat, contentHeight: CGFloat, containerHeight: CGFloat) {
    self.contentOffset = contentOffset
    self.contentHeight = contentHeight
    self.containerHeight = containerHeight
  }

  var isScrollable: Bool {
    scrollableHeight > 1
  }

  var progress: CGFloat {
    guard isScrollable else {
      return 0
    }
    return min(max(contentOffset / scrollableHeight, 0), 1)
  }

  var scrollableHeight: CGFloat {
    max(0, contentHeight - containerHeight)
  }

  var visibleFraction: CGFloat {
    guard contentHeight > 0 else {
      return 1
    }
    return min(max(containerHeight / contentHeight, 0), 1)
  }
}

private enum ScrollArrowDirection95 {
  case up
  case down
}

private struct ScrollArrowButton95: View {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.strings95) private var strings

  let direction: ScrollArrowDirection95
  let theme: Theme95
  let action: () -> Void

  var body: some View {
    Button95(action: action, contentInsets: EdgeInsets()) {
      PixelArrow95(
        direction: direction,
        color: isEnabled ? theme.colors.text : theme.colors.textDisabled
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .contentShape(.rect)
    }
    .frame(height: theme.metrics.scrollBarWidth - theme.metrics.bevelWidth * 2)
    .accessibilityLabel(Text(direction == .up ? strings.scrollUp : strings.scrollDown))
  }
}

private struct PixelArrow95: View {
  let direction: ScrollArrowDirection95
  let color: Color

  var body: some View {
    Canvas { context, _ in
      for row in 0..<5 {
        let visualRow = direction == .up ? row : 4 - row
        let width = CGFloat(visualRow * 2 + 1)
        let rect = CGRect(
          x: (9 - width) / 2,
          y: CGFloat(row),
          width: width,
          height: 1
        )
        context.fill(Path(rect), with: .color(color))
      }
    }
    .frame(width: 9, height: 5)
    .accessibilityHidden(true)
  }
}

private struct ScrollTrack95: View {
  let colors: Colors95

  var body: some View {
    Checkerboard(colors: colors)
      .accessibilityHidden(true)
  }
}
