import Foundation
import Tagged

public struct EpisodeProgress: Codable, Equatable, Identifiable {
  public let createdAt: Date
  public let episodeSequence: Episode.Sequence
  public let id: Tagged<Self, UUID>
  public let isFinished: Bool
  public let percent: Int
  public let userID: User.ID
  public let updatedAt: Date?

  public init(
    createdAt: Date,
    episodeSequence: Episode.Sequence,
    id: Tagged<Self, UUID>,
    isFinished: Bool,
    percent: Int,
    userID: User.ID,
    updatedAt: Date?
  ) {
    self.createdAt = createdAt
    self.episodeSequence = episodeSequence
    self.id = id
    self.isFinished = isFinished
    self.percent = percent
    self.userID = userID
    self.updatedAt = updatedAt
  }
}
