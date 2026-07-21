import SwiftUI

/// An image surface with a recessed Swift95 frame and optional pixelation.
///
/// Pixelation is enabled by default and is applied before the bevel is drawn,
/// keeping the classic dark top/leading and light bottom/trailing edges crisp.
/// Prepare the embedded image with normal SwiftUI image modifiers before
/// passing it to this component.
///
/// ```swift
/// Image95(Image("Photo").resizable())
///   .frame(width: 160, height: 120)
///
/// Image95(Image("Photo"), isPixelated: false)
/// ```
public struct Image95<Content: View>: View {
  private let content: Content
  private let isPixelated: Bool

  /// Creates a Swift95 image from a SwiftUI image.
  ///
  /// - Parameters:
  ///   - image: The image to display.
  ///   - isPixelated: Whether to apply the Windows 95-style pixelation effect.
  public init(
    _ image: Image,
    isPixelated: Bool = true
  ) where Content == Image {
    content = image
    self.isPixelated = isPixelated
  }

  /// Creates a Swift95 image surface from arbitrary view content.
  ///
  /// - Parameters:
  ///   - isPixelated: Whether to apply the Windows 95-style pixelation effect.
  ///   - content: The content displayed inside the image surface.
  public init(
    isPixelated: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.isPixelated = isPixelated
  }

  private init(content: Content, isPixelated: Bool) {
    self.content = content
    self.isPixelated = isPixelated
  }

  /// The styled image content.
  public var body: some View {
    ImageSurface95(content: content, isPixelated: isPixelated)
  }

  /// Applies a transformation to the embedded image content.
  ///
  /// The transformed content continues to receive pixelation and the recessed
  /// Swift95 frame.
  public func swiftUI<ModifiedContent: View>(
    @ViewBuilder _ transform: (Content) -> ModifiedContent
  ) -> Image95<ModifiedContent> {
    Image95<ModifiedContent>(
      content: transform(content),
      isPixelated: isPixelated
    )
  }
}

struct ImageSurface95<Content: View>: View {
  let content: Content
  let isPixelated: Bool

  var body: some View {
    content
      .modifier(PixelationModifier95(isEnabled: isPixelated))
      .clipped()
      .bevel95(.sunken, background: Color.clear)
  }
}

private struct PixelationModifier95: ViewModifier {
  let isEnabled: Bool

  @ViewBuilder
  func body(content: Content) -> some View {
    if isEnabled {
      content.layerEffect(
        ShaderLibrary.bundle(.module)
          .pixelate95(
            .boundingRect,
            .float(ImagePixelation95.pixelSize)
          ),
        maxSampleOffset: ImagePixelation95.maxSampleOffset
      )
    } else {
      content
    }
  }
}

enum ImagePixelation95 {
  static let pixelSize: Float = 2
  static let maxSampleOffset = CGSize(width: 1, height: 1)
}
