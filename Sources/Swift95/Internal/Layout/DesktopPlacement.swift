import CoreGraphics

enum DesktopPlacement {
  static func normalizedOffsets(
    baseFrames: [AnyHashable: CGRect],
    offsets: [AnyHashable: CGSize],
    desktopSize: CGSize,
    clearance: CGFloat
  ) -> [AnyHashable: CGSize] {
    var normalizedOffsets = offsets
    var occupiedFrames: [CGRect] = []
    let orderedFrames = baseFrames.sorted { lhs, rhs in
      if lhs.value.minY == rhs.value.minY {
        return lhs.value.minX < rhs.value.minX
      }
      return lhs.value.minY < rhs.value.minY
    }

    for (id, baseFrame) in orderedFrames {
      let offset = offsets[id] ?? .zero
      let requestedOrigin = CGPoint(
        x: baseFrame.minX + offset.width,
        y: baseFrame.minY + offset.height
      )
      let boundedTarget = boundedOrigin(
        requestedOrigin,
        itemSize: baseFrame.size,
        desktopSize: desktopSize
      )
      let resolvedOrigin = nearestAvailableOrigin(
        to: boundedTarget,
        fallback: baseFrame.origin,
        itemSize: baseFrame.size,
        among: occupiedFrames,
        desktopSize: desktopSize,
        clearance: clearance
      )

      normalizedOffsets[id] = translation(from: baseFrame.origin, to: resolvedOrigin)
      occupiedFrames.append(CGRect(origin: resolvedOrigin, size: baseFrame.size))
    }

    return normalizedOffsets
  }

  static func positionedFrames(
    baseFrames: [AnyHashable: CGRect],
    offsets: [AnyHashable: CGSize]
  ) -> [AnyHashable: CGRect] {
    Dictionary(
      uniqueKeysWithValues: baseFrames.map { id, frame in
        let offset = offsets[id] ?? .zero
        return (id, frame.offsetBy(dx: offset.width, dy: offset.height))
      }
    )
  }

  static func boundedTranslation(
    for id: AnyHashable,
    proposed proposedTranslation: CGSize,
    frames: [AnyHashable: CGRect],
    desktopSize: CGSize
  ) -> CGSize {
    guard let frame = frames[id] else { return proposedTranslation }
    let origin = boundedOrigin(
      CGPoint(
        x: frame.minX + proposedTranslation.width,
        y: frame.minY + proposedTranslation.height
      ),
      itemSize: frame.size,
      desktopSize: desktopSize
    )
    return translation(from: frame.origin, to: origin)
  }

  static func resolvedTranslation(
    for id: AnyHashable,
    proposed proposedTranslation: CGSize,
    frames: [AnyHashable: CGRect],
    desktopSize: CGSize,
    clearance: CGFloat
  ) -> CGSize {
    guard let frame = frames[id] else { return proposedTranslation }

    let boundedTranslation = boundedTranslation(
      for: id,
      proposed: proposedTranslation,
      frames: frames,
      desktopSize: desktopSize
    )
    let targetOrigin = CGPoint(
      x: frame.minX + boundedTranslation.width,
      y: frame.minY + boundedTranslation.height
    )
    let otherFrames =
      frames
      .filter { $0.key != id }
      .map(\.value)

    if isAvailable(
      targetOrigin,
      itemSize: frame.size,
      among: otherFrames,
      clearance: clearance
    ) {
      return translation(from: frame.origin, to: targetOrigin)
    }

    var candidates = [frame.origin]
    for otherFrame in otherFrames {
      let obstacle = otherFrame.insetBy(dx: -clearance, dy: -clearance)
      candidates.append(
        contentsOf: [
          CGPoint(x: obstacle.minX - frame.width, y: targetOrigin.y),
          CGPoint(x: obstacle.maxX, y: targetOrigin.y),
          CGPoint(x: targetOrigin.x, y: obstacle.minY - frame.height),
          CGPoint(x: targetOrigin.x, y: obstacle.maxY)
        ]
      )
    }

    let resolvedOrigin =
      candidates
      .map {
        boundedOrigin($0, itemSize: frame.size, desktopSize: desktopSize)
      }
      .filter {
        isAvailable(
          $0,
          itemSize: frame.size,
          among: otherFrames,
          clearance: clearance
        )
      }
      .min {
        squaredDistance(from: $0, to: targetOrigin)
          < squaredDistance(from: $1, to: targetOrigin)
      } ?? frame.origin

    return translation(from: frame.origin, to: resolvedOrigin)
  }

  private static func boundedOrigin(
    _ origin: CGPoint,
    itemSize: CGSize,
    desktopSize: CGSize
  ) -> CGPoint {
    CGPoint(
      x: min(max(0, origin.x), max(0, desktopSize.width - itemSize.width)),
      y: min(max(0, origin.y), max(0, desktopSize.height - itemSize.height))
    )
  }

  private static func nearestAvailableOrigin(
    to targetOrigin: CGPoint,
    fallback: CGPoint,
    itemSize: CGSize,
    among otherFrames: [CGRect],
    desktopSize: CGSize,
    clearance: CGFloat
  ) -> CGPoint {
    if isAvailable(
      targetOrigin,
      itemSize: itemSize,
      among: otherFrames,
      clearance: clearance
    ) {
      return targetOrigin
    }

    var candidates = [fallback]
    for otherFrame in otherFrames {
      let obstacle = otherFrame.insetBy(dx: -clearance, dy: -clearance)
      candidates.append(
        contentsOf: [
          CGPoint(x: obstacle.minX - itemSize.width, y: targetOrigin.y),
          CGPoint(x: obstacle.maxX, y: targetOrigin.y),
          CGPoint(x: targetOrigin.x, y: obstacle.minY - itemSize.height),
          CGPoint(x: targetOrigin.x, y: obstacle.maxY),
          CGPoint(x: obstacle.minX - itemSize.width, y: obstacle.minY - itemSize.height),
          CGPoint(x: obstacle.maxX, y: obstacle.minY - itemSize.height),
          CGPoint(x: obstacle.minX - itemSize.width, y: obstacle.maxY),
          CGPoint(x: obstacle.maxX, y: obstacle.maxY)
        ]
      )
    }

    return
      candidates
      .map { boundedOrigin($0, itemSize: itemSize, desktopSize: desktopSize) }
      .filter {
        isAvailable(
          $0,
          itemSize: itemSize,
          among: otherFrames,
          clearance: clearance
        )
      }
      .min {
        squaredDistance(from: $0, to: targetOrigin)
          < squaredDistance(from: $1, to: targetOrigin)
      } ?? targetOrigin
  }

  private static func isAvailable(
    _ origin: CGPoint,
    itemSize: CGSize,
    among otherFrames: [CGRect],
    clearance: CGFloat
  ) -> Bool {
    let candidate = CGRect(origin: origin, size: itemSize)
    return !otherFrames.contains {
      candidate.intersects($0.insetBy(dx: -clearance, dy: -clearance))
    }
  }

  private static func translation(from start: CGPoint, to end: CGPoint) -> CGSize {
    CGSize(width: end.x - start.x, height: end.y - start.y)
  }

  private static func squaredDistance(from start: CGPoint, to end: CGPoint) -> CGFloat {
    let x = end.x - start.x
    let y = end.y - start.y
    return x * x + y * y
  }
}
