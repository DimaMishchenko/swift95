import SwiftUI

/// A vertical SwiftUI scroll view with a functional classic scroll indicator.
///
/// The component uses native SwiftUI scrolling and synchronizes its position
/// with ``ScrollIndicator95``. The indicator remains visible when content fits,
/// matching the classic disabled-scrollbar presentation.
///
/// ```swift
/// ScrollView95 {
///   LazyVStack {
///     ForEach(items) { item in
///       ItemRow(item: item)
///     }
///   }
/// }
/// ```
public struct ScrollView95<Content: View, Scroll: View>: View {
  private let scroll: Scroll
  private let showsIndicator: Bool
  private let lineIncrement: CGFloat?
  private let indicatorTransform: (AnyView) -> AnyView

  /// Creates a vertical scroll view.
  ///
  /// - Parameters:
  ///   - showsIndicator: Whether to include the classic vertical indicator.
  ///   - lineIncrement: The distance moved by an indicator arrow button.
  ///   - content: The scrollable SwiftUI content.
  public init(
    showsIndicator: Bool = true,
    lineIncrement: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) where Scroll == ScrollView<Content> {
    scroll = ScrollView(.vertical, showsIndicators: false, content: content)
    self.showsIndicator = showsIndicator
    self.lineIncrement = lineIncrement
    indicatorTransform = { $0 }
  }

  private init(
    scroll: Scroll,
    showsIndicator: Bool,
    lineIncrement: CGFloat?,
    indicatorTransform: @escaping (AnyView) -> AnyView
  ) {
    self.scroll = scroll
    self.showsIndicator = showsIndicator
    self.lineIncrement = lineIncrement
    self.indicatorTransform = indicatorTransform
  }

  /// The styled scroll view.
  public var body: some View {
    NativeVerticalScrollContainer(
      scroll: scroll,
      showsIndicator: showsIndicator,
      lineIncrement: lineIncrement,
      bevelStyle: .input,
      indicatorTransform: indicatorTransform
    )
  }

  /// Applies a transformation to the embedded SwiftUI scroll view.
  ///
  /// - Parameter transform: A closure that receives the embedded scroll view.
  /// - Returns: A component containing the transformed SwiftUI scroll view.
  public func swiftUI<ModifiedScroll: View>(
    @ViewBuilder _ transform: (Scroll) -> ModifiedScroll
  ) -> ScrollView95<Content, ModifiedScroll> {
    ScrollView95<Content, ModifiedScroll>(
      scroll: transform(scroll),
      showsIndicator: showsIndicator,
      lineIncrement: lineIncrement,
      indicatorTransform: indicatorTransform
    )
  }

  /// Applies SwiftUI modifiers to the completed classic scroll indicator.
  ///
  /// ```swift
  /// ScrollView95 {
  ///   content
  /// }
  /// .swiftUIIndicator { indicator in
  ///   indicator.accessibilityHint("Scrolls the file list")
  /// }
  /// ```
  ///
  /// - Parameter transform: A closure that receives ``ScrollIndicator95``
  ///   after it has been connected to the native scroll position.
  /// - Returns: A scroll view that applies the indicator transformation.
  public func swiftUIIndicator<ModifiedIndicator: View>(
    @ViewBuilder _ transform: @escaping (AnyView) -> ModifiedIndicator
  ) -> ScrollView95<Content, Scroll> {
    ScrollView95<Content, Scroll>(
      scroll: scroll,
      showsIndicator: showsIndicator,
      lineIncrement: lineIncrement,
      indicatorTransform: { indicator in
        AnyView(transform(self.indicatorTransform(indicator)))
      }
    )
  }
}
