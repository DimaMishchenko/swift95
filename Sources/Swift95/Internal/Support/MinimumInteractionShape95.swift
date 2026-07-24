import SwiftUI

private struct MinimumInteractionShape95: Shape {
  func path(in rect: CGRect) -> Path {
    let width = max(rect.width, 44)
    let height = max(rect.height, 44)
    let target = CGRect(
      x: rect.midX - width / 2,
      y: rect.midY - height / 2,
      width: width,
      height: height
    )
    return Path(target)
  }
}

extension View {
  @ViewBuilder
  func minimumInteractionTarget95() -> some View {
    #if os(iOS)
      contentShape(.interaction, MinimumInteractionShape95())
    #else
      self
    #endif
  }
}
