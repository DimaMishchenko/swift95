import Swift95
import SwiftUI

struct MusicCollectionView: View {
  let model: MusicLibraryModel
  let compact: Bool

  private var showsShelves: Bool { model.destination == .home || model.destination == .library }

  var body: some View {
    ScrollView95 {
      VStack(alignment: .leading, spacing: 0) {
        if showsShelves {
          shelves
        } else {
          hero
          collectionActions
        }
        trackHeader
        if model.visibleTracks.isEmpty {
          VStack(alignment: .leading, spacing: 8) {
            Text("Nothing on this frequency.").font(MusicStyle.fonts.title2)
            Text(
              model.search.isEmpty
                ? "Save a song with the heart button to find it here."
                : "Try another title, artist, or album.")
          }
          .foregroundStyle(MusicStyle.muted)
          .padding(24)
        }
        ForEach(Array(model.visibleTracks.enumerated()), id: \.element.id) { index, track in
          trackRow(track, index: index)
        }
        Text("CURATED FOR LONG NIGHTS & EARLY MORNINGS")
          .font(MusicStyle.fonts.font(size: 10))
          .foregroundStyle(MusicStyle.muted)
          .padding(20)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(MusicStyle.navy)
    }
    .theme95(MusicStyle.darkTheme)
  }

  private var hero: some View {
    HStack(alignment: .bottom, spacing: compact ? 14 : 22) {
      MusicArtwork(variant: model.artwork)
        .frame(width: compact ? 100 : 154, height: compact ? 100 : 154)
        .padding(3)
        .bevel95(.raised)
      VStack(alignment: .leading, spacing: 10) {
        Text(collectionKind)
          .font(MusicStyle.fonts.font(size: 11))
          .foregroundStyle(MusicStyle.green)
        Text(model.title)
          .font(MusicStyle.fonts.font(size: compact ? 31 : 42, weight: .bold))
          .foregroundStyle(.white)
          .fixedSize(horizontal: false, vertical: true)
        Text(model.subtitle)
          .font(MusicStyle.fonts.font(size: 15))
          .foregroundStyle(MusicStyle.muted)
        Text("Swift95 Radio  •  \(model.visibleTracks.count) songs  •  \(totalDuration) min")
          .font(MusicStyle.fonts.font(size: 12))
          .foregroundStyle(.white)
      }
      Spacer(minLength: 0)
    }
    .padding(compact ? 16 : 24)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(MusicStyle.panel)
  }

  private var collectionKind: String {
    switch model.destination {
    case .album: "ALBUM / LOCAL FILES"
    case .favorites: "YOUR PERSONAL COLLECTION"
    default: "PLAYLIST / MADE FOR YOU"
    }
  }

  private var totalDuration: Int { Int(model.visibleTracks.reduce(0) { $0 + $1.duration } / 60) }

  private var collectionActions: some View {
    HStack(spacing: 12) {
      Button95(action: model.playCollection) {
        Label("Play collection", systemImage: "play.fill")
      }
      .disabled(model.visibleTracks.isEmpty)
      .accessibilityIdentifier("music.playCollection")
      Text("OFFLINE & READY")
        .font(MusicStyle.fonts.font(size: 10))
        .foregroundStyle(MusicStyle.green)
      Spacer(minLength: 0)
    }
    .padding(.horizontal, compact ? 16 : 24)
    .padding(.vertical, 16)
  }

  private var shelves: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("WELCOME BACK, LISTENER")
        .font(MusicStyle.fonts.font(size: 11))
        .foregroundStyle(MusicStyle.green)
      Text(model.title).font(MusicStyle.fonts.font(size: compact ? 30 : 38))
      Text(model.subtitle).foregroundStyle(MusicStyle.muted)
      LazyVGrid(columns: [GridItem(.adaptive(minimum: compact ? 120 : 145))], spacing: 16) {
        ForEach(MusicLibrary.playlists) { playlist in
          Button {
            model.navigate(to: .playlist(playlist.id))
          } label: {
            VStack(alignment: .leading, spacing: 8) {
              MusicArtwork(variant: playlist.artwork)
              Text(playlist.title).lineLimit(1)
              Text("\(playlist.trackIDs.count) tracks • Playlist")
                .font(MusicStyle.fonts.font(size: 11))
                .foregroundStyle(MusicStyle.muted)
            }
            .padding(9)
            .bevel95(.raised, background: MusicStyle.panel)
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("music.collection.\(playlist.id)")
        }
      }
      Text("ALL LOCAL TRACKS").font(MusicStyle.fonts.font(size: 12)).padding(.top, 8)
    }
    .foregroundStyle(.white)
    .padding(20)
  }

  private var trackHeader: some View {
    HStack(spacing: 12) {
      Text("#").frame(width: 22)
      Text("TITLE").frame(maxWidth: .infinity, alignment: .leading)
      if !compact { Text("ALBUM").frame(width: 135, alignment: .leading) }
      Image(systemName: "clock").frame(width: 42)
      Text("").frame(width: 24)
    }
    .font(MusicStyle.fonts.font(size: 11))
    .foregroundStyle(MusicStyle.muted)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .overlay(alignment: .bottom) {
      Rectangle().fill(MusicStyle.muted.opacity(0.25)).frame(height: 1)
    }
  }

  private func trackRow(_ track: MusicTrack, index: Int) -> some View {
    let selected = model.currentID == track.id
    return HStack(spacing: 12) {
      Button {
        model.play(track)
      } label: {
        HStack(spacing: 12) {
          Group {
            if selected {
              Image(systemName: model.isPlaying ? "speaker.wave.2.fill" : "play.fill")
            } else {
              Text("\(index + 1)")
            }
          }
          .font(MusicStyle.fonts.font(size: 12))
          .foregroundStyle(selected ? MusicStyle.green : MusicStyle.muted)
          .frame(width: 22)
          VStack(alignment: .leading, spacing: 4) {
            Text(track.title)
              .font(MusicStyle.fonts.font(size: 16))
              .foregroundStyle(selected ? MusicStyle.green : .white)
            Text(track.artist)
              .font(MusicStyle.fonts.font(size: 12))
              .foregroundStyle(MusicStyle.muted)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Play \(track.title) by \(track.artist)")
      .accessibilityIdentifier("music.track.\(track.id)")
      if !compact {
        Button(track.album) { model.navigate(to: .album(track.album)) }
          .buttonStyle(.plain)
          .font(MusicStyle.fonts.font(size: 12))
          .foregroundStyle(MusicStyle.muted)
          .frame(width: 135, alignment: .leading)
          .accessibilityLabel("Open album \(track.album)")
      }
      Text(track.durationLabel)
        .font(MusicStyle.fonts.font(size: 12))
        .foregroundStyle(MusicStyle.muted)
        .frame(width: 42)
      Button {
        model.toggleSaved(track.id)
      } label: {
        Image(systemName: model.savedIDs.contains(track.id) ? "heart.fill" : "heart")
          .foregroundStyle(model.savedIDs.contains(track.id) ? MusicStyle.green : MusicStyle.muted)
          .frame(width: 24, height: 40)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel("\(model.savedIDs.contains(track.id) ? "Unsave" : "Save") \(track.title)")
      .accessibilityIdentifier("music.save.\(track.id)")
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 6)
    .background(
      selected
        ? Color(red: 0.12, green: 0.24, blue: 0.22)
        : index % 2 == 0 ? MusicStyle.panel.opacity(0.35) : .clear)
  }
}
