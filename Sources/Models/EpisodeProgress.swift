public struct EpisodeProgress: Equatable, Codable {
  public let episodeSequence: Episode.Sequence
  public let isFinished: Bool
  public let percent: Int
  public let userID: User.ID

  public init(
    episodeSequence: Episode.Sequence,
    isFinished: Bool,
    percent: Int,
    userID: User.ID
  ) {
    self.episodeSequence = episodeSequence
    self.isFinished = isFinished
    self.percent = percent
    self.userID = userID
  }
}
