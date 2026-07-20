import Observation
import SwiftUI

#if canImport(UIKit)
  import UIKit

  @MainActor
  @Observable
  final class TextEditorScrollBridge95 {
    var metrics = ScrollMetrics95()

    @ObservationIgnored private weak var textView: UITextView?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []

    func attach(from marker: UIView) {
      if let textView, textView.window != nil,
        intersectionArea(of: textView, with: marker.convert(marker.bounds, to: nil)) > 0
      {
        refreshMetrics()
        return
      }

      guard let resolvedTextView = findTextView(from: marker), resolvedTextView !== textView else {
        return
      }

      textView = resolvedTextView
      observations = [
        resolvedTextView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] _, _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        },
        resolvedTextView.observe(\.contentSize, options: [.initial, .new]) { [weak self] _, _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        },
        resolvedTextView.observe(\.bounds, options: [.initial, .new]) { [weak self] _, _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        }
      ]
      refreshMetrics()
    }

    func scroll(to offset: CGFloat) {
      guard let textView else {
        return
      }

      let insets = textView.adjustedContentInset
      let maximumOffset = max(
        -insets.top,
        textView.contentSize.height - textView.bounds.height + insets.bottom
      )
      let targetOffset = min(max(offset - insets.top, -insets.top), maximumOffset)
      textView.setContentOffset(
        CGPoint(x: textView.contentOffset.x, y: targetOffset), animated: false)
      refreshMetrics()
    }

    private func refreshMetrics() {
      guard let textView else {
        metrics = ScrollMetrics95()
        return
      }

      let insets = textView.adjustedContentInset
      metrics = ScrollMetrics95(
        contentOffset: max(0, textView.contentOffset.y + insets.top),
        contentHeight: textView.contentSize.height + insets.top + insets.bottom,
        containerHeight: textView.bounds.height
      )
    }

    private func findTextView(from marker: UIView) -> UITextView? {
      let markerFrame = marker.convert(marker.bounds, to: nil)
      var ancestor = marker.superview

      while let currentAncestor = ancestor {
        let candidates = textViews(in: currentAncestor)
        if !candidates.isEmpty {
          return candidates.max { first, second in
            intersectionArea(of: first, with: markerFrame)
              < intersectionArea(of: second, with: markerFrame)
          }
        }
        ancestor = currentAncestor.superview
      }

      return nil
    }

    private func textViews(in view: UIView) -> [UITextView] {
      var result = view.subviews.compactMap { $0 as? UITextView }
      for subview in view.subviews {
        result.append(contentsOf: textViews(in: subview))
      }
      return result
    }

    private func intersectionArea(of textView: UITextView, with markerFrame: CGRect) -> CGFloat {
      let frame = textView.convert(textView.bounds, to: nil)
      let intersection = frame.intersection(markerFrame)
      guard !intersection.isNull else {
        return 0
      }
      return intersection.width * intersection.height
    }
  }

  struct TextEditorScrollProbe95: UIViewRepresentable {
    let bridge: TextEditorScrollBridge95

    func makeUIView(context: Context) -> TextEditorScrollProbeView95 {
      let view = TextEditorScrollProbeView95()
      view.onLayout = { [weak bridge] marker in
        bridge?.attach(from: marker)
      }
      return view
    }

    func updateUIView(_ uiView: TextEditorScrollProbeView95, context: Context) {
      bridge.attach(from: uiView)
    }
  }

  final class TextEditorScrollProbeView95: UIView {
    var onLayout: ((UIView) -> Void)?

    override func didMoveToWindow() {
      super.didMoveToWindow()
      onLayout?(self)
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      onLayout?(self)
    }
  }
#elseif canImport(AppKit)
  import AppKit

  private final class TextEditorScrollObservations95: @unchecked Sendable {
    var values: [NSObjectProtocol] = []

    deinit {
      removeAll()
    }

    func removeAll() {
      let notificationCenter = NotificationCenter.default
      for observation in values {
        notificationCenter.removeObserver(observation)
      }
      values.removeAll()
    }
  }

  @MainActor
  @Observable
  final class TextEditorScrollBridge95 {
    var metrics = ScrollMetrics95()

    @ObservationIgnored private weak var scrollView: NSScrollView?
    @ObservationIgnored private let observations = TextEditorScrollObservations95()

    func attach(from marker: NSView) {
      if let scrollView, scrollView.window != nil,
        intersectionArea(of: scrollView, with: marker.convert(marker.bounds, to: nil)) > 0
      {
        refreshMetrics()
        return
      }

      guard let resolvedScrollView = findTextScrollView(from: marker),
        resolvedScrollView !== scrollView
      else {
        return
      }

      removeObservations()
      scrollView = resolvedScrollView

      let notificationCenter = NotificationCenter.default
      resolvedScrollView.contentView.postsBoundsChangedNotifications = true
      observations.values = [
        notificationCenter.addObserver(
          forName: NSView.boundsDidChangeNotification,
          object: resolvedScrollView.contentView,
          queue: .main
        ) { [weak self] _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        },
        notificationCenter.addObserver(
          forName: NSView.frameDidChangeNotification,
          object: resolvedScrollView.documentView,
          queue: .main
        ) { [weak self] _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        },
        notificationCenter.addObserver(
          forName: NSText.didChangeNotification,
          object: resolvedScrollView.documentView,
          queue: .main
        ) { [weak self] _ in
          MainActor.assumeIsolated {
            self?.refreshMetrics()
          }
        }
      ]
      resolvedScrollView.documentView?.postsFrameChangedNotifications = true
      refreshMetrics()
    }

    func scroll(to offset: CGFloat) {
      guard let scrollView else {
        return
      }

      let maximumOffset = max(
        0, contentHeight(of: scrollView) - scrollView.contentView.bounds.height)
      let targetOffset = min(max(offset, 0), maximumOffset)
      scrollView.contentView.scroll(
        to: CGPoint(x: scrollView.contentView.bounds.minX, y: targetOffset)
      )
      scrollView.reflectScrolledClipView(scrollView.contentView)
      refreshMetrics()
    }

    private func refreshMetrics() {
      guard let scrollView else {
        metrics = ScrollMetrics95()
        return
      }

      metrics = ScrollMetrics95(
        contentOffset: max(0, scrollView.contentView.bounds.minY),
        contentHeight: contentHeight(of: scrollView),
        containerHeight: scrollView.contentView.bounds.height
      )
    }

    private func contentHeight(of scrollView: NSScrollView) -> CGFloat {
      max(scrollView.documentView?.bounds.height ?? 0, scrollView.contentView.bounds.height)
    }

    private func findTextScrollView(from marker: NSView) -> NSScrollView? {
      let markerFrame = marker.convert(marker.bounds, to: nil)
      var ancestor = marker.superview

      while let currentAncestor = ancestor {
        let candidates = textScrollViews(in: currentAncestor)
        if !candidates.isEmpty {
          return candidates.max { first, second in
            intersectionArea(of: first, with: markerFrame)
              < intersectionArea(of: second, with: markerFrame)
          }
        }
        ancestor = currentAncestor.superview
      }

      return nil
    }

    private func textScrollViews(in view: NSView) -> [NSScrollView] {
      var result: [NSScrollView] = []
      if let scrollView = view as? NSScrollView,
        scrollView.documentView is NSTextView
      {
        result.append(scrollView)
      }
      for subview in view.subviews {
        result.append(contentsOf: textScrollViews(in: subview))
      }
      return result
    }

    private func intersectionArea(of scrollView: NSScrollView, with markerFrame: CGRect) -> CGFloat
    {
      let frame = scrollView.convert(scrollView.bounds, to: nil)
      let intersection = frame.intersection(markerFrame)
      guard !intersection.isNull else {
        return 0
      }
      return intersection.width * intersection.height
    }

    private func removeObservations() {
      observations.removeAll()
    }
  }

  struct TextEditorScrollProbe95: NSViewRepresentable {
    let bridge: TextEditorScrollBridge95

    func makeNSView(context: Context) -> TextEditorScrollProbeView95 {
      let view = TextEditorScrollProbeView95()
      view.onLayout = { [weak bridge] marker in
        bridge?.attach(from: marker)
      }
      return view
    }

    func updateNSView(_ nsView: TextEditorScrollProbeView95, context: Context) {
      bridge.attach(from: nsView)
    }
  }

  final class TextEditorScrollProbeView95: NSView {
    var onLayout: ((NSView) -> Void)?

    override func viewDidMoveToWindow() {
      super.viewDidMoveToWindow()
      onLayout?(self)
    }

    override func layout() {
      super.layout()
      onLayout?(self)
    }
  }
#endif
