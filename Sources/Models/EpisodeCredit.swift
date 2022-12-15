public struct EpisodeCredit: Decodable, Equatable {
  public var episodeSequence: Episode.Sequence
  public var userId: User.ID

  public init(episodeSequence: Episode.Sequence, userId: User.ID) {
    self.episodeSequence = episodeSequence
    self.userId = userId
  }
}
