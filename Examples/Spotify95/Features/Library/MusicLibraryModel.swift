import Foundation
import Observation

@MainActor @Observable
final class MusicLibraryModel {
  private(set) var destination: LibraryDestination = .playlist("night")
  private(set) var history: [LibraryDestination] = []
  private(set) var queue = MusicLibrary.tracks.map(\.id)
  private(set) var currentID = 1
  private(set) var isPlaying = false
  private(set) var elapsed: Double = 83
  private(set) var volume: Double = 0.72
  private(set) var savedIDs: Set<Int> = [1, 3, 6]
  private(set) var repeats = false
  var search = ""

  var currentTrack: MusicTrack {
    MusicLibrary.tracks.first { $0.id == currentID } ?? MusicLibrary.tracks[0]
  }
  var currentPlaylist: MusicPlaylist? {
    guard case .playlist(let id) = destination else { return nil }
    return MusicLibrary.playlists.first { $0.id == id }
  }
  var title: String {
    switch destination {
    case .home: "Made for your desktop"
    case .library: "Your Library"
    case .favorites: "Liked Songs"
    case .playlist: currentPlaylist?.title ?? "Playlist"
    case .album(let title): title
    }
  }
  var subtitle: String {
    switch destination {
    case .favorites: "All your favorites, always close by."
    case .album: visibleTracks.first?.artist ?? "Album"
    case .library: "Your music. Your little corner of the internet."
    case .home: "Good music never goes out of style."
    case .playlist: currentPlaylist?.subtitle ?? ""
    }
  }
  var artwork: Int {
    currentPlaylist?.artwork ?? visibleTracks.first?.artwork ?? 0
  }
  var visibleTracks: [MusicTrack] {
    let tracks: [MusicTrack]
    switch destination {
    case .playlist:
      let ids = currentPlaylist?.trackIDs ?? []
      tracks = ids.compactMap { id in MusicLibrary.tracks.first { $0.id == id } }
    case .favorites: tracks = MusicLibrary.tracks.filter { savedIDs.contains($0.id) }
    case .album(let album): tracks = MusicLibrary.tracks.filter { $0.album == album }
    case .home, .library: tracks = MusicLibrary.tracks
    }
    guard !search.isEmpty else { return tracks }
    return tracks.filter {
      "\($0.title) \($0.artist) \($0.album)".localizedCaseInsensitiveContains(search)
    }
  }

  func navigate(to destination: LibraryDestination) {
    guard destination != self.destination else { return }
    history.append(self.destination)
    self.destination = destination
    search = ""
  }

  func goBack() {
    guard let previous = history.popLast() else { return }
    destination = previous
    search = ""
  }

  func play(_ track: MusicTrack) {
    queue = visibleTracks.map(\.id)
    if !queue.contains(track.id) { queue = [track.id] }
    currentID = track.id
    elapsed = 0
    isPlaying = true
  }

  func playCollection() {
    guard let track = visibleTracks.first else { return }
    play(track)
  }

  func togglePlayback() {
    if !isPlaying && elapsed >= currentTrack.duration { elapsed = 0 }
    isPlaying.toggle()
  }
  func toggleRepeat() { repeats.toggle() }
  func toggleSaved(_ id: Int) {
    if !savedIDs.insert(id).inserted { savedIDs.remove(id) }
  }
  func seek(to seconds: Double) { elapsed = min(max(seconds, 0), currentTrack.duration) }
  func setVolume(_ value: Double) { volume = min(max(value, 0), 1) }

  func next() {
    guard let index = queue.firstIndex(of: currentID) else { return }
    guard index + 1 < queue.count else {
      if repeats, let first = queue.first {
        currentID = first
        elapsed = 0
      } else {
        elapsed = currentTrack.duration
        isPlaying = false
      }
      return
    }
    currentID = queue[index + 1]
    elapsed = 0
  }

  func previous() {
    guard elapsed <= 3, let index = queue.firstIndex(of: currentID), index > 0 else {
      elapsed = 0
      return
    }
    currentID = queue[index - 1]
    elapsed = 0
  }

  func tick() {
    guard isPlaying else { return }
    if elapsed + 1 >= currentTrack.duration { next() } else { elapsed += 1 }
  }
}
