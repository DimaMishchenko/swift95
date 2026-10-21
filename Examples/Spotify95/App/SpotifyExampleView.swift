import Swift95
import SwiftUI

struct SpotifyExampleView: View {
  @State private var model = MusicLibraryModel()

  var body: some View {
    GeometryReader { geometry in
      let compact = geometry.size.width < 650
      VStack(spacing: 0) {
        titleBar
        HStack(spacing: 4) {
          if !compact { MusicSidebar(model: model).frame(width: 190) }
          VStack(spacing: 0) {
            toolbar(compact: compact)
            MusicCollectionView(model: model, compact: compact)
          }
          .bevel95(.sunken, background: MusicStyle.navy)
          if geometry.size.width > 1000 {
            MusicNowPlaying(model: model).frame(width: 216)
          }
        }
        .padding(4)
        MusicPlayerBar(model: model, compact: compact)
        HStack {
          Text("●  OFFLINE COLLECTION")
          Spacer()
          Text(
            compact ? "DEMO • NO AUDIO" : "8 demo tracks    •    Playback simulation / no audio")
        }
        .font(MusicStyle.fonts.font(size: 11))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .bevel95(.sunken)
      }
      .padding(4)
      .bevel95(.raised)
      .font(MusicStyle.fonts.body)
      .background(Theme95.classic.colors.background)
    }
    .preferredColorScheme(.light)
    .task {
      while !Task.isCancelled {
        do { try await Task.sleep(for: .seconds(1)) } catch { return }
        model.tick()
      }
    }
  }

  private var titleBar: some View {
    HStack(spacing: 8) {
      Image(systemName: "music.note.list")
        .foregroundStyle(MusicStyle.green)
      Text("Spotify ’95")
        .font(MusicStyle.fonts.font(size: 18, weight: .bold))
      Spacer()
      Text("YOUR MUSIC. A DIFFERENT ERA.")
        .font(MusicStyle.fonts.font(size: 10))
        .foregroundStyle(MusicStyle.green)
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 9)
    .padding(.vertical, 7)
    .background(Color(red: 0.04, green: 0.23, blue: 0.18))
  }

  private func toolbar(compact: Bool) -> some View {
    @Bindable var model = model
    return HStack(spacing: 8) {
      Button95(action: model.goBack) { Image(systemName: "arrow.left") }
        .disabled(model.history.isEmpty)
        .accessibilityLabel("Back")
        .accessibilityIdentifier("music.back")
      if compact {
        Menu {
          Button("Home") { model.navigate(to: .home) }
          Button("Your Library") { model.navigate(to: .library) }
          Button("Liked Songs") { model.navigate(to: .favorites) }
          ForEach(MusicLibrary.playlists) { playlist in
            Button(playlist.title) { model.navigate(to: .playlist(playlist.id)) }
          }
        } label: {
          Image(systemName: "sidebar.left")
        }
        .accessibilityLabel("Browse collection")
      }
      TextField95(
        "Search this collection",
        text: $model.search,
        prompt: Text("Search this collection").foregroundColor(MusicStyle.muted)
      )
      .accessibilityIdentifier("music.search")
      if !compact {
        Text("LOCAL FILES")
          .font(MusicStyle.fonts.font(size: 11))
          .foregroundStyle(MusicStyle.green)
      }
    }
    .padding(10)
    .theme95(MusicStyle.darkTheme)
    .environment(\.colorScheme, .dark)
    .background(MusicStyle.panel)
  }
}

struct MusicSidebar: View {
  let model: MusicLibraryModel

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading, spacing: 6) {
        Text("MUSIC EXPLORER")
          .font(MusicStyle.fonts.font(size: 11))
          .foregroundStyle(MusicStyle.muted)
          .padding(.bottom, 8)
        item("Home", icon: "house", destination: .home, id: "home")
        item("Your Library", icon: "square.stack", destination: .library, id: "library")
        item("Liked Songs", icon: "heart.fill", destination: .favorites, id: "favorites")
        Rectangle().fill(MusicStyle.muted.opacity(0.3)).frame(height: 1).padding(.vertical, 12)
        Text("YOUR PLAYLISTS")
          .font(MusicStyle.fonts.font(size: 11))
          .foregroundStyle(MusicStyle.muted)
          .padding(.bottom, 6)
        ForEach(MusicLibrary.playlists) { playlist in
          item(
            playlist.title, icon: "music.note.list", destination: .playlist(playlist.id),
            id: playlist.id)
        }
        Spacer(minLength: 16)
        MusicArtwork(variant: 2).frame(width: 52, height: 52)
        Text("A mixtape for your desktop.")
          .font(MusicStyle.fonts.font(size: 13))
          .foregroundStyle(MusicStyle.muted)
        Text("100% local. 100% nostalgic.")
          .font(MusicStyle.fonts.font(size: 11))
          .foregroundStyle(MusicStyle.muted)
      }
      .padding(13)
    }
    .frame(maxHeight: .infinity)
    .bevel95(.sunken, background: MusicStyle.navy)
    .theme95(MusicStyle.darkTheme)
  }

  private func item(
    _ title: String, icon: String, destination: LibraryDestination, id: String
  ) -> some View {
    Button {
      model.navigate(to: destination)
    } label: {
      HStack(spacing: 9) {
        Image(systemName: icon).frame(width: 17)
        Text(title).lineLimit(1)
        Spacer(minLength: 0)
      }
      .font(MusicStyle.fonts.font(size: 15))
      .foregroundStyle(model.destination == destination ? MusicStyle.green : .white)
      .padding(.horizontal, 7)
      .padding(.vertical, 10)
      .background(model.destination == destination ? MusicStyle.panel : .clear)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(model.destination == destination ? .isSelected : [])
    .accessibilityIdentifier("music.nav.\(id)")
  }
}
