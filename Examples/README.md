# Swift95 example apps

Three independent, offline SwiftUI apps show how Swift95 components fit together in complete interfaces.

| Scheme | Explore |
| --- | --- |
| [Spotify95](Spotify95/) | Playlists, library and album navigation, favorites, search and a simulated player |
| [Slack95](Slack95/) | Channels, direct messages, conversation search, local messages and threaded replies |
| [Finder95](Finder95/) | A demo filesystem, folder history, grid/list views, search, new folders, renaming and file details |

Run `make generate`, open `Swift95.xcworkspace`, and select an app scheme. Each app supports macOS 15, iOS 18 and iPadOS 18 or later. The Catalog remains a separate app in the same workspace.

The examples use fictional local content. Spotify95 simulates playback without playing audio. Slack95 does not send messages to a service. Finder95 never reads or changes your real files. These are independent interface studies, unaffiliated with the apps that inspired them.

## Structure

Each app owns its entry point in `App/`, feature state and views in `Features/`. Observable models own navigation and changes to demo data; views own temporary presentation. The apps depend on Swift95 and optional Swift95Icons, and do not import one another or the Catalog.

`Examples/Project.swift` defines the separate app targets. The root `Workspace.swift` connects them with the Catalog. The `Examples` scheme builds all three apps.

```sh
make build-examples
```

The README and website captures live in `Website/public/images/examples/`; each app folder also has a README gallery with additional captures in `Screenshots/`. Updating these promotional images does not change component snapshot references.

Slack95 is designed around phone navigation, conversations and threads. Spotify95 and Finder95 use desktop layouts with compact adaptations. Example interactions are verified manually; they have no test targets.
