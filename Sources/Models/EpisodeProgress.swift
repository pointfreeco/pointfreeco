import Foundation
import Tagged

public struct EpisodeProgress: Codable, Equatable, Identifiable {
  public let episodeSequence: Episode.Sequence
  public let id: Tagged<Self, UUID>
  public let isFinished: Bool
  public let percent: Int
  public let userID: User.ID

  public init(
    episodeSequence: Episode.Sequence,
    id: Tagged<Self, UUID>,
    isFinished: Bool,
    percent: Int,
    userID: User.ID
  ) {
    self.episodeSequence = episodeSequence
    self.id = id
    self.isFinished = isFinished
    self.percent = percent
    self.userID = userID
  }
}
