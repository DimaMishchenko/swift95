import Foundation

struct MusicTrack: Identifiable, Equatable, Sendable {
  let id: Int
  let title: String
  let artist: String
  let album: String
  let duration: Double
  let artwork: Int

  var durationLabel: String { Self.timeLabel(duration) }

  static func timeLabel(_ seconds: Double) -> String {
    let value = Int(max(0, seconds))
    return "\(value / 60):\(String(format: "%02d", value % 60))"
  }
}

struct MusicPlaylist: Identifiable, Equatable, Sendable {
  let id: String
  let title: String
  let subtitle: String
  let artwork: Int
  let trackIDs: [Int]
}

enum LibraryDestination: Equatable, Sendable {
  case home
  case library
  case favorites
  case playlist(String)
  case album(String)
}

enum MusicLibrary {
  static let tracks: [MusicTrack] = [
    MusicTrack(
      id: 1, title: "Midnight City", artist: "Neon Avenue", album: "After Hours", duration: 244,
      artwork: 0),
    MusicTrack(
      id: 2, title: "Soft Focus", artist: "The Daydreams", album: "Polaroid Summer", duration: 216,
      artwork: 1),
    MusicTrack(
      id: 3, title: "Digital Rain", artist: "Mono / Stereo", album: "Computer Love", duration: 283,
      artwork: 2),
    MusicTrack(
      id: 4, title: "Last Train Home", artist: "Neon Avenue", album: "After Hours", duration: 197,
      artwork: 0),
    MusicTrack(
      id: 5, title: "Windows Down", artist: "Pacific Coast", album: "Golden State", duration: 231,
      artwork: 3),
    MusicTrack(
      id: 6, title: "A Place Between", artist: "The Daydreams", album: "Polaroid Summer",
      duration: 258, artwork: 1),
    MusicTrack(
      id: 7, title: "Dial Tone", artist: "Mono / Stereo", album: "Computer Love", duration: 188,
      artwork: 2),
    MusicTrack(
      id: 8, title: "Stay Awhile", artist: "Pacific Coast", album: "Golden State", duration: 224,
      artwork: 3)
  ]

  static let playlists: [MusicPlaylist] = [
    MusicPlaylist(
      id: "night", title: "Late Night Drive", subtitle: "City lights. Open roads. One more song.",
      artwork: 0, trackIDs: [1, 2, 3, 4, 5, 6, 7, 8]),
    MusicPlaylist(
      id: "focus", title: "Deep Focus", subtitle: "Find your flow, one track at a time.",
      artwork: 2, trackIDs: [3, 7, 6, 2]),
    MusicPlaylist(
      id: "summer", title: "Endless Summer", subtitle: "A little sunshine for your hard drive.",
      artwork: 3, trackIDs: [5, 8, 2, 6]),
    MusicPlaylist(
      id: "dream", title: "Daydream FM", subtitle: "Soft edges and familiar frequencies.",
      artwork: 1, trackIDs: [2, 6, 4, 8])
  ]
}
