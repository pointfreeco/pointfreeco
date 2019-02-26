public struct EpisodeCredit: Decodable, Equatable {
  public var episodeSequence: Int
  public var userId: User.Id

  public enum CodingKeys: String, CodingKey {
    case episodeSequence = "episode_sequence"
    case userId = "user_id"
  }
}
