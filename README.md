# swift-95

An opinionated Windows 95-inspired component kit for SwiftUI on Apple platforms.

## Supported platforms

- iOS and iPadOS 18 or later
- macOS 15 or later

Swift95 adapts interaction and layout behavior to each platform. The catalog is a native
multiplatform app and the component set is built and visually tested on iPhone, iPad, and Mac.

## Inspired by

- [React95](https://github.com/React95/React95), which brought the Windows 95 component language to React and provides an extensive open design kit.
- [ClassicKit](https://github.com/Baddaboo/ClassicKit), one of the early efforts to reimplement this interface style for Apple platforms.

## Catalog

```sh
tuist generate --path Catalog
open Catalog/Swift95Catalog.xcworkspace
```

Run the `Swift95Catalog` scheme using a Mac, iPhone Simulator, or iPad Simulator destination to
inspect the platform-specific behavior.

## Disclaimer

Windows and associated names and assets are the property of Microsoft Corporation. Swift95 is an independent project and is not affiliated with or endorsed by Microsoft. The bundled W95FA recreation is independently licensed under the SIL Open Font License 1.1; see [ASSET_LICENSES.md](ASSET_LICENSES.md).
