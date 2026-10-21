import Swift95
import SwiftUI

struct MusicPlayerBar: View {
  let model: MusicLibraryModel
  let compact: Bool

  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 12) {
        MusicArtwork(variant: model.currentTrack.artwork).frame(width: 48, height: 48)
          .bevel95(.sunken)
        VStack(alignment: .leading, spacing: 4) {
          Text(model.currentTrack.title).font(MusicStyle.fonts.font(size: 16))
          Text(model.currentTrack.artist).font(MusicStyle.fonts.font(size: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        if !compact { transport }
        if !compact {
          HStack(spacing: 7) {
            Image(systemName: model.volume == 0 ? "speaker.slash" : "speaker.wave.2")
            Slider95(value: Binding(get: { model.volume }, set: { model.setVolume($0) }))
              .accessibilityLabel("Volume")
              .accessibilityIdentifier("music.volume")
          }
          .frame(width: 150)
        }
      }
      if compact {
        transport
        HStack(spacing: 8) {
          Image(systemName: "speaker.wave.2")
          Slider95(value: Binding(get: { model.volume }, set: { model.setVolume($0) }))
            .accessibilityLabel("Volume")
            .accessibilityIdentifier("music.volume")
        }
      }
      HStack(spacing: 9) {
        Text(MusicTrack.timeLabel(model.elapsed)).frame(width: 32)
        Slider95(
          value: Binding(get: { model.elapsed }, set: { model.seek(to: $0) }),
          in: 0...model.currentTrack.duration
        )
        .accessibilityLabel("Playback position")
        .accessibilityIdentifier("music.seek")
        Text(model.currentTrack.durationLabel).frame(width: 32)
      }
      .font(MusicStyle.fonts.font(size: 12))
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 9)
    .bevel95(.raised)
  }

  private var transport: some View {
    HStack(spacing: 7) {
      Button95(action: model.previous) { Image(systemName: "backward.end.fill") }
        .accessibilityLabel("Previous track")
        .accessibilityIdentifier("music.previous")
      Button95(action: model.togglePlayback) {
        Label(
          model.isPlaying ? "Pause" : "Play",
          systemImage: model.isPlaying ? "pause.fill" : "play.fill"
        )
        .frame(minWidth: 52)
      }
      .accessibilityIdentifier("music.playPause")
      Button95(action: model.next) { Image(systemName: "forward.end.fill") }
        .accessibilityLabel("Next track")
        .accessibilityIdentifier("music.next")
      Button95(action: model.toggleRepeat) {
        Image(systemName: model.repeats ? "repeat.circle.fill" : "repeat")
      }
      .accessibilityLabel(model.repeats ? "Disable repeat collection" : "Repeat collection")
      .accessibilityValue(model.repeats ? "On" : "Off")
      .accessibilityIdentifier("music.repeat")
    }
  }
}

struct MusicNowPlaying: View {
  let model: MusicLibraryModel

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack {
        Text("ON YOUR TURNTABLE")
          .font(MusicStyle.fonts.font(size: 11))
        Spacer(minLength: 0)
        Image(systemName: "opticaldisc")
      }
      .foregroundStyle(MusicStyle.muted)
      MusicArtwork(variant: model.currentTrack.artwork)
        .padding(3)
        .bevel95(.raised)
      Text(model.currentTrack.title)
        .font(MusicStyle.fonts.font(size: 24))
        .foregroundStyle(.white)
      Text(model.currentTrack.artist)
        .font(MusicStyle.fonts.font(size: 16))
        .foregroundStyle(MusicStyle.muted)
      Button95 {
        model.navigate(to: .album(model.currentTrack.album))
      } label: {
        Label("View album", systemImage: "square.stack")
      }
      .accessibilityIdentifier("music.currentAlbum")
      Rectangle().fill(MusicStyle.muted.opacity(0.3)).frame(height: 1)
      Text("THE DESKTOP SESSIONS")
        .font(MusicStyle.fonts.font(size: 11))
        .foregroundStyle(MusicStyle.green)
      Text("For the songs you found on a mixtape and never forgot.")
        .font(MusicStyle.fonts.font(size: 16))
        .foregroundStyle(MusicStyle.muted)
        .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
      HStack(alignment: .bottom, spacing: 3) {
        ForEach(0..<24) { index in
          Rectangle()
            .fill(index < 18 ? MusicStyle.green.opacity(0.6) : MusicStyle.muted.opacity(0.3))
            .frame(width: 4, height: CGFloat([8, 16, 11, 25, 33, 21, 15, 29][index % 8]))
        }
      }
      .accessibilityHidden(true)
      Text(model.isPlaying ? "PLAYBACK SIMULATION" : "READY WHEN YOU ARE")
        .font(MusicStyle.fonts.font(size: 10))
        .foregroundStyle(MusicStyle.muted)
    }
    .padding(14)
    .frame(maxHeight: .infinity)
    .bevel95(.sunken, background: MusicStyle.panel)
    .theme95(MusicStyle.darkTheme)
  }
}
