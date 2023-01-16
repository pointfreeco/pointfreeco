import Dependencies
import Models

private enum EpisodeProgressesKey: DependencyKey {
  static let liveValue: [Episode.Sequence: EpisodeProgress] = [:]
  static let testValue: [Episode.Sequence: EpisodeProgress] = [:]
}

extension DependencyValues {
  public var episodeProgresses: [Episode.Sequence: EpisodeProgress] {
    get { self[EpisodeProgressesKey.self] }
    set { self[EpisodeProgressesKey.self] = newValue }
  }
}
