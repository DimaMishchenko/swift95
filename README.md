<p align="center">
  <img src="Assets/README/swift95-readme-hero.png" alt="Swift95 window showing the project name and tagline" width="960">
</p>

# Swift95

Swift95 is a Windows 95-inspired component kit for SwiftUI. It brings classic controls,
desktop-style workspaces, themes, and classic icons to native apps without giving up SwiftUI state,
accessibility, or platform behavior.

**[📖 Documentation](https://swift95.dimasike.com)** ·
**[🧩 Components](https://swift95.dimasike.com/components/)** ·
**[🔎 API reference](https://swift95.dimasike.com/api/documentation/)**

## What you can build

Three runnable app examples, each with its own target in [Examples](Examples/README.md).

### Spotify ’95

Browse playlists and albums, save favorites, and try a simulated music player.

![Spotify ’95 with playlists, original album artwork, tracks and playback controls](Website/public/images/examples/spotify95.jpg)

### Slack ’95

Explore channels and direct messages, send local messages, and follow threaded conversations.

<img src="Website/public/images/examples/slack95.png" alt="Slack ’95 on iPhone with a channel conversation and message composer" width="320">

### Finder ’95

Browse a demo filesystem, switch views, create folders, rename items, and inspect file details.

![Finder ’95 with folders, a file grid and selected file details](Website/public/images/examples/finder95.jpg)

These independent interface studies use local demo content and connect to no external services.

## Try it

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/dimamishchenko/swift95
```

Select version **1.0.0** or later. Add the `Swift95` product to your target, then use its components like ordinary SwiftUI views:

```swift
import Swift95
import SwiftUI

struct SaveButton: View {
  var body: some View {
    Button95("Save") {
      saveDocument()
    }
  }

  private func saveDocument() {}
}
```

Add the optional `Swift95Icons` product when you want the bundled classic icon set.

Swift95 requires Swift 6 and supports iOS and iPadOS 18 or later and macOS 15 or later.

## Run the catalog

Explore the components locally on Mac, iPhone, or iPad:

```sh
make generate
open Swift95.xcworkspace
```

Run `Swift95Catalog` for the component catalog, or `Spotify95`, `Slack95` and `Finder95` for the
standalone example apps. For setup,
**[🚀 start with the complete guide](https://swift95.dimasike.com/start/)**.

## Development

Use Xcode 26.6 and the Tuist version in `.tool-versions`. Website development also requires
Node.js 22.22 or later and `npm --prefix Website ci`.

```sh
make generate       # Open Swift95.xcworkspace after generation
make format         # Format Swift sources
make check          # Lint, test, and build the Catalog on all platforms
make website-dev    # Preview the website
make website-build  # Build and validate the complete documentation site
```

Run `make help` for individual checks and simulator overrides. CI validates pull requests and
publishes the website after checks pass on `main`.
