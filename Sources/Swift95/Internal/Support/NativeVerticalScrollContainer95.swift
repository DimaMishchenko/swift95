import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

struct NativeVerticalScrollContainer<Scroll: View>: View {
  @State private var position = ScrollPosition(y: 0)
  @State private var requestedOffset: CGFloat?
  @State private var synchronization = ScrollSynchronization()

  let scroll: Scroll
  let showsIndicator: Bool
  let lineIncrement: CGFloat?
  let bevelStyle: Bevel95Style?
  let indicatorTransform: (AnyView) -> AnyView

  var body: some View {
    if let bevelStyle {
      content
        .padding(bevelStyle.contentInset)
        .clipped()
        .bevel95(bevelStyle)
    } else {
      content
    }
  }

  private var content: some View {
    HStack(alignment: .top, spacing: 0) {
      scroll
        .scrollIndicators(.hidden)
        .scrollPosition($position)
        .background {
          #if canImport(UIKit)
            NativeScrollOffsetWriter(targetOffset: $requestedOffset)
          #elseif canImport(AppKit)
            NativeScrollOffsetWriter(targetOffset: $requestedOffset)
          #endif
        }
        .onScrollGeometryChange(for: ScrollMetrics95.self) { geometry in
          ScrollMetrics95(
            contentOffset: geometry.contentOffset.y,
            contentHeight: geometry.contentSize.height,
            containerHeight: geometry.containerSize.height
          )
        } action: { _, newMetrics in
          synchronization.update(from: newMetrics)
        }

      if showsIndicator {
        indicatorTransform(
          AnyView(
            ScrollIndicator95(
              contentOffset: scrollOffset,
              contentLength: synchronization.metrics.contentHeight,
              viewportLength: synchronization.metrics.containerHeight,
              lineIncrement: lineIncrement
            )
          )
        )
      }
    }
  }

  private var scrollOffset: Binding<CGFloat> {
    Binding(
      get: { synchronization.metrics.contentOffset },
      set: { newOffset in
        let offset = synchronization.requestOffset(newOffset)
        position = ScrollPosition(y: offset)
        requestedOffset = offset
      }
    )
  }
}

private extension Bevel95Style {
  var contentInset: CGFloat {
    switch self {
    case .sunken: 1
    case .raised, .input: 2
    }
  }
}

#if canImport(UIKit)
  private struct NativeScrollOffsetWriter: UIViewRepresentable {
    @Binding var targetOffset: CGFloat?

    func makeUIView(context: Context) -> UIView {
      UIView(frame: .zero)
    }

    func updateUIView(_ view: UIView, context: Context) {
      guard let targetOffset else { return }

      DispatchQueue.main.async {
        guard let scrollView = view.connectedScrollView else { return }

        let minimumOffset = -scrollView.adjustedContentInset.top
        let maximumOffset = max(
          minimumOffset,
          scrollView.contentSize.height - scrollView.bounds.height
            + scrollView.adjustedContentInset.bottom
        )
        scrollView.setContentOffset(
          CGPoint(
            x: scrollView.contentOffset.x,
            y: min(max(targetOffset + minimumOffset, minimumOffset), maximumOffset)
          ),
          animated: false
        )
        self.targetOffset = nil
      }
    }
  }

  private extension UIView {
    var connectedScrollView: UIScrollView? {
      var ancestor = superview
      while let view = ancestor {
        if let scrollView = view as? UIScrollView {
          return scrollView
        }
        ancestor = view.superview
      }

      guard let window else { return nil }
      let probePoint = convert(
        CGPoint(x: bounds.midX, y: bounds.midY),
        to: window
      )
      return window.descendantScrollViews
        .filter { scrollView in
          let frame = scrollView.convert(scrollView.bounds, to: window)
          return frame.contains(probePoint)
            && scrollView.contentSize.height > scrollView.bounds.height
        }
        .min { lhs, rhs in
          lhs.bounds.width * lhs.bounds.height < rhs.bounds.width * rhs.bounds.height
        }
    }

    var descendantScrollViews: [UIScrollView] {
      var scrollViews: [UIScrollView] = []
      if let scrollView = self as? UIScrollView {
        scrollViews.append(scrollView)
      }
      return subviews.reduce(into: scrollViews) { result, subview in
        result.append(contentsOf: subview.descendantScrollViews)
      }
    }
  }
#elseif canImport(AppKit)
  private struct NativeScrollOffsetWriter: NSViewRepresentable {
    @Binding var targetOffset: CGFloat?

    func makeNSView(context: Context) -> NSView {
      NSView(frame: .zero)
    }

    func updateNSView(_ view: NSView, context: Context) {
      guard let targetOffset else { return }

      DispatchQueue.main.async {
        guard let scrollView = view.connectedScrollView,
          let documentView = scrollView.documentView
        else { return }

        let clipView = scrollView.contentView
        let documentHeight = max(documentView.bounds.height, documentView.frame.height)
        let originY = NativeVerticalScrollOffset95.originY(
          targetOffset: targetOffset,
          documentHeight: documentHeight,
          viewportHeight: clipView.bounds.height,
          isFlipped: documentView.isFlipped
        )

        clipView.scroll(
          to: CGPoint(x: clipView.bounds.minX, y: originY)
        )
        scrollView.reflectScrolledClipView(clipView)
        self.targetOffset = nil
      }
    }
  }

  private extension NSView {
    var connectedScrollView: NSScrollView? {
      var ancestor = superview
      while let view = ancestor {
        if let scrollView = view as? NSScrollView {
          return scrollView
        }
        ancestor = view.superview
      }

      guard let window, let contentView = window.contentView else { return nil }
      let probePoint = convert(
        CGPoint(x: bounds.midX, y: bounds.midY),
        to: nil
      )
      return contentView.descendantScrollViews
        .filter { scrollView in
          let frame = scrollView.convert(scrollView.bounds, to: nil)
          let documentHeight = max(
            scrollView.documentView?.bounds.height ?? 0,
            scrollView.documentView?.frame.height ?? 0
          )
          return frame.contains(probePoint)
            && documentHeight > scrollView.contentView.bounds.height
        }
        .min { lhs, rhs in
          lhs.bounds.width * lhs.bounds.height < rhs.bounds.width * rhs.bounds.height
        }
    }

    var descendantScrollViews: [NSScrollView] {
      var scrollViews: [NSScrollView] = []
      if let scrollView = self as? NSScrollView {
        scrollViews.append(scrollView)
      }
      return subviews.reduce(into: scrollViews) { result, subview in
        result.append(contentsOf: subview.descendantScrollViews)
      }
    }
  }
#endif

enum NativeVerticalScrollOffset95 {
  static func originY(
    targetOffset: CGFloat,
    documentHeight: CGFloat,
    viewportHeight: CGFloat,
    isFlipped: Bool
  ) -> CGFloat {
    let maximumOffset = max(0, documentHeight - viewportHeight)
    let offset = min(max(targetOffset, 0), maximumOffset)
    return isFlipped ? offset : maximumOffset - offset
  }
}

struct ScrollSynchronization: Equatable {
  private(set) var metrics = ScrollMetrics95()
  private var pendingOffset: CGFloat?
  private var lastObservedOffset = CGFloat.zero

  mutating func update(from newMetrics: ScrollMetrics95) {
    let sanitizedMetrics = ScrollMetrics95(
      contentOffset: min(max(newMetrics.contentOffset, 0), newMetrics.scrollableHeight),
      contentHeight: max(0, newMetrics.contentHeight),
      containerHeight: max(0, newMetrics.containerHeight)
    )

    if let pendingOffset {
      if abs(sanitizedMetrics.contentOffset - pendingOffset) < 1 {
        self.pendingOffset = nil
      } else if abs(sanitizedMetrics.contentOffset - lastObservedOffset) < 1 {
        metrics.contentHeight = sanitizedMetrics.contentHeight
        metrics.containerHeight = sanitizedMetrics.containerHeight
        return
      } else {
        self.pendingOffset = nil
      }
    }

    metrics = sanitizedMetrics
    lastObservedOffset = sanitizedMetrics.contentOffset
  }

  mutating func requestOffset(_ requestedOffset: CGFloat) -> CGFloat {
    let offset = min(max(requestedOffset, 0), metrics.scrollableHeight)
    lastObservedOffset = metrics.contentOffset
    pendingOffset = offset
    metrics.contentOffset = offset
    return offset
  }
}
