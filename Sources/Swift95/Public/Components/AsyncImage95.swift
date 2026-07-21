import SwiftUI

/// An asynchronously loaded image with Swift95 pixelation and a recessed frame.
///
/// `AsyncImage95` follows SwiftUI's `AsyncImage` loading behavior. Its Metal
/// pixelation effect is enabled by default and can be disabled without changing
/// the loading or phase-handling behavior.
///
/// ```swift
/// AsyncImage95(url: artworkURL)
///
/// AsyncImage95(url: artworkURL) { phase in
///   if let image = phase.image {
///     image.resizable().scaledToFill()
///   } else {
///     Color.gray
///   }
/// }
/// ```
public struct AsyncImage95<Content: View>: View {
  private let content: Content
  private let isPixelated: Bool

  /// Creates an asynchronous Swift95 image with the standard placeholder.
  ///
  /// - Parameters:
  ///   - url: The image URL to load.
  ///   - scale: The image scale used to interpret the loaded data.
  ///   - isPixelated: Whether to apply the Windows 95-style pixelation effect.
  public init(
    url: URL?,
    scale: CGFloat = 1,
    isPixelated: Bool = true
  ) where Content == AsyncImage<Image> {
    content = AsyncImage(url: url, scale: scale)
    self.isPixelated = isPixelated
  }

  /// Creates an asynchronous Swift95 image with custom phase content.
  ///
  /// - Parameters:
  ///   - url: The image URL to load.
  ///   - scale: The image scale used to interpret the loaded data.
  ///   - transaction: The transaction used when the loading phase changes.
  ///   - isPixelated: Whether to apply the Windows 95-style pixelation effect.
  ///   - content: A view builder that renders each asynchronous image phase.
  public init<PhaseContent: View>(
    url: URL?,
    scale: CGFloat = 1,
    transaction: Transaction = Transaction(),
    isPixelated: Bool = true,
    @ViewBuilder content: @escaping (AsyncImagePhase) -> PhaseContent
  ) where Content == AsyncImage<PhaseContent> {
    self.content = AsyncImage(
      url: url,
      scale: scale,
      transaction: transaction,
      content: content
    )
    self.isPixelated = isPixelated
  }

  private init(content: Content, isPixelated: Bool) {
    self.content = content
    self.isPixelated = isPixelated
  }

  /// The styled asynchronous image content.
  public var body: some View {
    ImageSurface95(content: content, isPixelated: isPixelated)
  }

  /// Applies a transformation to the embedded SwiftUI asynchronous image.
  ///
  /// The transformed control retains the configured pixelation and recessed
  /// Swift95 frame.
  public func swiftUI<ModifiedContent: View>(
    @ViewBuilder _ transform: (Content) -> ModifiedContent
  ) -> AsyncImage95<ModifiedContent> {
    AsyncImage95<ModifiedContent>(
      content: transform(content),
      isPixelated: isPixelated
    )
  }
}
