import Testing

@testable import Spotify95

@MainActor
struct MusicLibraryModelTests {
  @Test func collectionNavigationAndSearch() {
    let model = MusicLibraryModel()
    model.navigate(to: .playlist("summer"))
    #expect(model.visibleTracks.map(\.id) == [5, 8, 2, 6])
    model.search = "pacific"
    #expect(model.visibleTracks.map(\.id) == [5, 8])
    model.navigate(to: .album("After Hours"))
    #expect(model.search.isEmpty)
    #expect(model.visibleTracks.map(\.id) == [1, 4])
    model.goBack()
    #expect(model.destination == .playlist("summer"))
  }

  @Test func collectionQueueStopsAtEndAndRepeatsWhenEnabled() {
    let model = MusicLibraryModel()
    model.navigate(to: .album("After Hours"))
    model.playCollection()
    #expect(model.queue == [1, 4])
    model.next()
    #expect(model.currentID == 4)
    model.next()
    #expect(!model.isPlaying)
    #expect(model.elapsed == model.currentTrack.duration)
    model.toggleRepeat()
    model.togglePlayback()
    model.next()
    #expect(model.currentID == 1)
    #expect(model.elapsed == 0)
    #expect(model.isPlaying)
  }

  @Test func playRestartsTrackAfterQueueReachesEnd() {
    let model = MusicLibraryModel()
    model.navigate(to: .album("After Hours"))
    model.playCollection()
    model.next()
    model.next()
    #expect(model.currentID == 4)
    #expect(!model.isPlaying)
    #expect(model.elapsed == model.currentTrack.duration)
    model.togglePlayback()
    #expect(model.isPlaying)
    #expect(model.elapsed == 0)
    model.tick()
    #expect(model.currentID == 4)
    #expect(model.elapsed == 1)
    #expect(model.isPlaying)
  }

  @Test func previousRestartsBeforeMovingToEarlierTrack() {
    let model = MusicLibraryModel()
    model.playCollection()
    model.next()
    model.seek(to: 10)
    model.previous()
    #expect(model.currentID == 2)
    #expect(model.elapsed == 0)
    model.previous()
    #expect(model.currentID == 1)
    model.previous()
    #expect(model.currentID == 1)
  }

  @Test func savedCollectionAndEmptyPlayback() {
    let model = MusicLibraryModel()
    model.navigate(to: .favorites)
    for id in [1, 3, 6] { model.toggleSaved(id) }
    #expect(model.visibleTracks.isEmpty)
    model.playCollection()
    #expect(!model.isPlaying)
    model.toggleSaved(2)
    #expect(model.visibleTracks.map(\.id) == [2])
  }

  @Test func seekVolumeAndClockRespectBoundaries() {
    let model = MusicLibraryModel()
    model.seek(to: -10)
    #expect(model.elapsed == 0)
    model.setVolume(4)
    #expect(model.volume == 1)
    model.setVolume(-2)
    #expect(model.volume == 0)
    model.tick()
    #expect(model.elapsed == 0)
    model.togglePlayback()
    model.tick()
    #expect(model.elapsed == 1)
    model.seek(to: model.currentTrack.duration - 1)
    model.tick()
    #expect(model.currentID == 2)
    #expect(model.elapsed == 0)
  }
}
