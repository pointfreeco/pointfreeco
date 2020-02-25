public struct EpisodeCredit: Decodable, Equatable {
  public var episodeSequence: Episode.Sequence
  public var userId: User.Id

  public init(episodeSequence: Episode.Sequence, userId: User.Id) {
    self.episodeSequence = episodeSequence
    self.userId = userId
  }

  public enum CodingKeys: String, CodingKey {
    case episodeSequence = "episode_sequence"
    case userId = "user_id"
  }
}
