import Dependencies

public struct EpisodesStats {
  public var allEpisodes: Int = 0
  public var allHours: Int = 0
  public var freeEpisodes: Int = 0

  public init() {
    @Dependency(\.episodes) var episodes
    @Dependency(\.envVars.emergencyMode) var emergencyMode
    @Dependency(\.date.now) var now

    var allSeconds = 0
    for episode in episodes() {
      guard episode.publishedAt < now else { continue }
      allEpisodes += 1
      allSeconds += episode.length.rawValue
      if !episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) {
        freeEpisodes += 1
      }
    }
    allHours = allSeconds / 3600
  }
}
