import SwiftUI

/// Persistable placement state for shortcuts in a ``Desktop95``.
///
/// Keep the state in your app when shortcut positions should be inspectable or encoded:
///
/// ```swift
/// @State private var desktopState = DesktopState95<App>()
///
/// Desktop95 { shortcuts }
///   .desktopState95($desktopState)
/// ```
public struct DesktopState95<Route: Hashable>: Equatable {
  /// Offsets from each shortcut's initial desktop position.
  public var shortcutOffsets: [Route: CGSize]

  /// Creates desktop placement state.
  public init(shortcutOffsets: [Route: CGSize] = [:]) {
    self.shortcutOffsets = shortcutOffsets
  }
}

extension DesktopState95: Codable where Route: Codable {}

extension View {
  /// Connects a desktop's shortcut placement to app-owned state.
  ///
  /// Shortcut route values are used as stable identities. Moving a shortcut updates `state`, and
  /// recreating the desktop restores its last placement.
  public func desktopState95<Route: Hashable>(
    _ state: Binding<DesktopState95<Route>>
  ) -> some View {
    environment(
      \.desktopPositionStore,
      DesktopPositionStore(
        offsets: {
          Dictionary(
            uniqueKeysWithValues: state.wrappedValue.shortcutOffsets.map {
              (AnyHashable($0.key), $0.value)
            }
          )
        },
        setOffset: { id, offset in
          guard let route = id.base as? Route else { return }
          state.wrappedValue.shortcutOffsets[route] = offset
        }
      )
    )
  }

  /// Persists a desktop's shortcut placement in app storage.
  ///
  /// Use a storage key unique to the desktop. Route values must remain Codable and stable between
  /// app versions.
  ///
  /// ```swift
  /// Desktop95 { shortcuts }
  ///   .desktopState95(App.self, storageKey: "main-desktop")
  /// ```
  public func desktopState95<Route: Hashable & Codable>(
    _ routeType: Route.Type,
    storageKey: String
  ) -> some View {
    modifier(PersistedDesktopStateModifier<Route>(storageKey: storageKey))
  }
}

private struct PersistedDesktopStateModifier<Route: Hashable & Codable>: ViewModifier {
  @AppStorage private var encodedState: Data

  init(storageKey: String) {
    _encodedState = AppStorage(wrappedValue: Data(), storageKey)
  }

  func body(content: Content) -> some View {
    let encodedState = $encodedState
    let state = Binding<DesktopState95<Route>>(
      get: {
        (try? JSONDecoder().decode(DesktopState95<Route>.self, from: encodedState.wrappedValue))
          ?? DesktopState95()
      },
      set: { state in
        guard let data = try? JSONEncoder().encode(state) else { return }
        encodedState.wrappedValue = data
      }
    )

    content.desktopState95(state)
  }
}
