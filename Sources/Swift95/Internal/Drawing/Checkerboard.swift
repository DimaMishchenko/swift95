import SwiftUI

struct Checkerboard: View {
  let colors: Colors95

  var body: some View {
    Canvas { context, size in
      context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(colors.borderLightest))

      let tileSize = CGFloat(2)
      let columns = Int(ceil(size.width / tileSize))
      let rows = Int(ceil(size.height / tileSize))

      for row in 0..<rows {
        for column in 0..<columns where (row + column).isMultiple(of: 2) {
          let rect = CGRect(
            x: CGFloat(column) * tileSize,
            y: CGFloat(row) * tileSize,
            width: tileSize,
            height: tileSize
          )
          context.fill(Path(rect), with: .color(colors.background))
        }
      }
    }
  }
}
