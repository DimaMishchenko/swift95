# ``Swift95Icons``

Use type-safe Windows 95 pixel artwork in SwiftUI.

@Metadata {
  @PageImage(purpose: icon, source: "Swift95Icons-icon.png", alt: "A Windows 95 computer icon.")
  @PageImage(purpose: card, source: "Swift95Icons-card.png", alt: "A Windows 95 computer icon.")
}

## Overview

Swift95Icons bundles the original-size PNG renditions and exposes them through ``Icon95``. Choose an
``Icon95/Name-swift.enum`` and semantic ``Icon95/Size``; the view selects the best available resource
without smoothing the pixel art.

```swift
import Swift95Icons

Icon95(.computer)
```

## Topics

### Icons

- ``Icon95``
- ``Icon95/Name-swift.enum``
- ``Icon95/Size``
