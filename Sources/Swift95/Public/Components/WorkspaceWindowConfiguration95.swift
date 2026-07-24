import CoreGraphics

/// Operations available for one logical workspace window.
public struct WorkspaceWindowCapabilities95: OptionSet, Sendable {
  /// The option-set storage.
  public let rawValue: UInt8

  /// Creates a capability set from its raw representation.
  public init(rawValue: UInt8) {
    self.rawValue = rawValue
  }

  /// Allows the window to be minimized.
  public static let minimize = WorkspaceWindowCapabilities95(rawValue: 1 << 0)
  /// Allows the window to be maximized and restored.
  public static let maximize = WorkspaceWindowCapabilities95(rawValue: 1 << 1)
  /// Allows the window to be closed.
  public static let close = WorkspaceWindowCapabilities95(rawValue: 1 << 2)
  /// Allows the window to be resized.
  public static let resize = WorkspaceWindowCapabilities95(rawValue: 1 << 3)
  /// Allows the window to be moved.
  public static let move = WorkspaceWindowCapabilities95(rawValue: 1 << 4)

  /// The standard set of window capabilities.
  public static let standard: WorkspaceWindowCapabilities95 = [
    .minimize, .maximize, .close, .resize, .move
  ]
}

/// Behavior owned by a single ``WorkspaceWindow95``.
public struct WorkspaceWindowConfiguration95: Sendable {
  /// The smallest size allowed for this window.
  public var minimumSize: CGSize
  /// Operations exposed by this window.
  public var capabilities: WorkspaceWindowCapabilities95

  /// Creates behavior for one workspace window.
  public init(
    minimumSize: CGSize = CGSize(width: 280, height: 200),
    capabilities: WorkspaceWindowCapabilities95 = .standard
  ) {
    self.minimumSize = minimumSize
    self.capabilities = capabilities
  }

  /// The standard workspace-window behavior.
  public static let `default` = WorkspaceWindowConfiguration95()
}
