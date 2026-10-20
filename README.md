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

## Try it

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/dimamishchenko/swift95
```

Add the `Swift95` product to your target, then use its components like ordinary SwiftUI views:

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
open Catalog/Swift95Catalog.xcworkspace
```

Run the `Swift95Catalog` scheme for your preferred destination—or
**[🚀 start with the complete guide](https://swift95.dimasike.com/start/)**.

## Development

Run `make help` for the available commands. Use `make format` and `make lint` for formatting,
`make check` for package tests, platform tests, and Catalog builds, and `make website-build` for
the complete documentation site. The Catalog uses the Tuist version in `.tool-versions`; the
website uses Node.js 22 and dependencies installed with `npm --prefix Website ci`.

CI validates pull requests and pushes to `main` using Xcode 16.4 and iOS 18.5 simulators on
macOS 15. Platform tests also build and launch the Catalog. Snapshot references are checked
without recording replacements.

The **CI** workflow publishes the website after every push to `main`, including merged pull
requests, once all checks pass. To publish manually, run it from `main` with **publish_website**
selected. Pull requests validate the website without publishing it.

Dependabot checks Swift packages, website npm packages, and GitHub Actions weekly. Minor and
patch updates are grouped by ecosystem; major updates get separate pull requests.
