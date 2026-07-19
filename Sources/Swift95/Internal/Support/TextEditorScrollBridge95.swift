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
#else
  @MainActor
  @Observable
  final class TextEditorScrollBridge95 {
    var metrics = ScrollMetrics95()

    func scroll(to offset: CGFloat) {}
  }

  struct TextEditorScrollProbe95: View {
    let bridge: TextEditorScrollBridge95

    var body: some View {
      EmptyView()
    }
  }
#endif
