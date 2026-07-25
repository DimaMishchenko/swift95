import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

/// A Windows 95 pixel-art icon for SwiftUI.
///
/// Create an icon by selecting a ``Name`` and, optionally, a semantic ``Size``:
///
/// ```swift
/// Icon95(.computer)
/// Icon95(.computer, size: .small)
///
/// Icon95(.logo, size: .standard)
///   .resizable()
///   .frame(width: 16, height: 16)
/// ```
///
/// The view preserves the source artwork's aspect ratio, uses nearest-neighbor
/// interpolation, and renders the longest edge at the selected size. Use
/// ``resizable(capInsets:resizingMode:)`` when the selected artwork should adopt
/// a size supplied by its SwiftUI layout.
///
/// Use ``swiftUI(_:)`` to configure the rendered icon with native SwiftUI
/// modifiers. An icon's meaning depends on its context, so provide
/// accessibility semantics at the call site:
///
/// ```swift
/// Icon95(.computer)
///   .swiftUI { image in
///     image.accessibilityLabel("Computer")
///   }
///
/// Label {
///   Text("Computer")
/// } icon: {
///   Icon95(.computer)
///     .accessibilityHidden(true)
/// }
/// ```
public struct Icon95: View {
  /// The type-safe name of the displayed artwork.
  ///
  /// ```swift
  /// let icon = Icon95(.recycleBin)
  /// print(icon.name.identifier) // "recycleBin"
  /// ```
  public let name: Name

  /// The requested semantic presentation size.
  ///
  /// This selects the preferred artwork rendition and the icon's default
  /// intrinsic size. Call ``resizable(capInsets:resizingMode:)`` to override
  /// the rendered size with standard SwiftUI layout modifiers.
  ///
  /// ```swift
  /// let icon = Icon95(.computer, size: .large)
  /// print(icon.size == .large) // true
  /// ```
  public let size: Size

  /// Creates a type-safe pixel-art icon.
  ///
  /// ```swift
  /// Icon95(.computer)
  /// Icon95(.computer, size: .large)
  /// ```
  ///
  /// - Parameters:
  ///   - name: The artwork to display.
  ///   - size: The semantic presentation size. The default is ``Size/standard``.
  public init(_ name: Name, size: Size = .standard) {
    self.name = name
    self.size = size
  }

  /// The artwork size selected after falling back to an available rendition.
  ///
  /// Compare this value with ``size`` when inspecting whether a requested
  /// rendition was available:
  ///
  /// ```swift
  /// let icon = Icon95(.addressBook, size: .large)
  /// let didUseFallback = icon.sourceSize != icon.size
  /// ```
  public var sourceSize: Size {
    resource.size
  }

  /// The pixel dimensions of the selected source PNG.
  ///
  /// ```swift
  /// let pixels = Icon95(.computer).pixelSize
  /// ```
  public var pixelSize: CGSize {
    resource.pixelSize
  }

  /// The dimensions of the SwiftUI view, in points.
  ///
  /// The longest edge matches ``Size/pointDimension`` and the shorter edge is
  /// scaled proportionally.
  ///
  /// ```swift
  /// let points = Icon95(.computer, size: .small).renderedSize
  /// ```
  public var renderedSize: CGSize {
    let longestEdge = max(pixelSize.width, pixelSize.height)
    let scale = size.pointDimension / longestEdge
    return CGSize(width: pixelSize.width * scale, height: pixelSize.height * scale)
  }

  /// The pixelated SwiftUI representation of the icon.
  public var body: some View {
    resizable()
      .frame(width: renderedSize.width, height: renderedSize.height)
  }

  /// Returns a resizable SwiftUI image using nearest-neighbor interpolation.
  ///
  /// This mirrors SwiftUI's `Image.resizable(capInsets:resizingMode:)`. The
  /// selected ``size`` still determines which artwork rendition is loaded, but
  /// the surrounding SwiftUI layout determines its displayed dimensions:
  ///
  /// ```swift
  /// Icon95(.logo, size: .standard)
  ///   .resizable()
  ///   .aspectRatio(contentMode: .fit)
  ///   .frame(width: 16, height: 16)
  /// ```
  ///
  /// - Parameters:
  ///   - capInsets: Insets that are not resized.
  ///   - resizingMode: How the image fills its available space.
  /// - Returns: The selected artwork as a resizable SwiftUI image.
  public func resizable(
    capInsets: EdgeInsets = EdgeInsets(),
    resizingMode: Image.ResizingMode = .stretch
  ) -> Image {
    platformImage
      .resizable(capInsets: capInsets, resizingMode: resizingMode)
      .interpolation(.none)
  }

  /// Applies a transformation to the rendered SwiftUI icon.
  ///
  /// Use this escape hatch for native SwiftUI modifiers that `Icon95` does not
  /// expose directly. The closure receives the complete icon, including its
  /// nearest-neighbor interpolation and semantic frame.
  ///
  /// ```swift
  /// Icon95(.computer)
  ///   .swiftUI { icon in
  ///     icon
  ///       .accessibilityLabel("Computer")
  ///       .opacity(0.8)
  ///   }
  /// ```
  ///
  /// - Parameter transform: A closure that receives the rendered icon.
  /// - Returns: The transformed SwiftUI content.
  public func swiftUI<ModifiedContent: View>(
    @ViewBuilder _ transform: (Self) -> ModifiedContent
  ) -> ModifiedContent {
    transform(self)
  }

  #if canImport(UIKit)
    /// The selected source artwork as an unmodified UIKit image.
    ///
    /// The returned image retains the source rendition's pixel dimensions. Use
    /// ``pixelSize`` to inspect them.
    ///
    /// ```swift
    /// let image: UIImage = Icon95(.computer).uiImage
    /// ```
    public var uiImage: UIImage {
      guard let image = UIImage(contentsOfFile: resourceURL.path) else {
        preconditionFailure("Swift95Icons resource is missing: \(resourceName).png")
      }
      return image
    }

    private var platformImage: Image {
      Image(uiImage: uiImage)
    }
  #elseif canImport(AppKit)
    /// The selected source artwork as an unmodified AppKit image.
    ///
    /// The returned image retains the source rendition's pixel dimensions. Use
    /// ``pixelSize`` to inspect them.
    ///
    /// ```swift
    /// let image: NSImage = Icon95(.computer).nsImage
    /// ```
    public var nsImage: NSImage {
      guard let image = NSImage(contentsOf: resourceURL) else {
        preconditionFailure("Swift95Icons resource is missing: \(resourceName).png")
      }
      return image
    }

    private var platformImage: Image {
      Image(nsImage: nsImage)
    }
  #endif

  private var resourceName: String {
    resource.filename
  }

  private var resource: Name.Resource {
    name.resource(for: size)
  }

  private var resourceURL: URL {
    guard
      let url = Bundle.module.url(
        forResource: resourceName,
        withExtension: "png",
        subdirectory: "Icons"
      )
    else {
      preconditionFailure("Swift95Icons resource is missing: \(resourceName).png")
    }
    return url
  }
}

extension Icon95 {
  /// A semantic icon size.
  ///
  /// Use semantic sizes instead of display-scale-specific `@2x` or `@3x`
  /// variants. Pixel art remains crisp because ``Icon95`` uses nearest-neighbor
  /// interpolation.
  ///
  /// ```swift
  /// Icon95(.computer, size: .small)
  /// Icon95(.computer, size: .standard)
  /// Icon95(.computer, size: .large)
  /// ```
  public enum Size: String, CaseIterable, Hashable, Sendable {
    /// A compact presentation with a 16-point longest edge.
    case small

    /// The default presentation with a 32-point longest edge.
    case standard

    /// A large presentation with a 48-point longest edge.
    case large

    /// The length of the rendered icon's longest edge, in points.
    ///
    /// ```swift
    /// Icon95.Size.small.pointDimension // 16
    /// Icon95.Size.standard.pointDimension // 32
    /// Icon95.Size.large.pointDimension // 48
    /// ```
    public var pointDimension: Double {
      switch self {
      case .small: 16
      case .standard: 32
      case .large: 48
      }
    }
  }
}
