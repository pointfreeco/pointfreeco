import Foundation
import Tagged
import TaggedTime

public struct OfficeHourQuestion: Codable, Identifiable {
  public let id: Tagged<Self, UUID>
  public let answeredAtSeconds: Seconds<Int>?
  public let answeredOfficeHourID: OfficeHour.ID?
  public let createdAt: Date
  public let hasVoted: Bool
  public let question: String
  public let userID: User.ID?
  public let voteCount: Int

  public init(
    id: ID,
    answeredAtSeconds: Seconds<Int>? = nil,
    answeredOfficeHourID: OfficeHour.ID? = nil,
    createdAt: Date = Date(timeIntervalSince1970: 0),
    hasVoted: Bool = false,
    question: String,
    userID: User.ID?,
    voteCount: Int = 0
  ) {
    self.id = id
    self.answeredAtSeconds = answeredAtSeconds
    self.answeredOfficeHourID = answeredOfficeHourID
    self.createdAt = createdAt
    self.hasVoted = hasVoted
    self.question = question
    self.userID = userID
    self.voteCount = voteCount
  }

  public enum CodingKeys: String, CodingKey {
    case id
    case answeredAtSeconds = "answered_at_seconds"
    case answeredOfficeHourID = "answered_office_hour_id"
    case createdAt = "created_at"
    case hasVoted = "has_voted"
    case question
    case userID = "user_id"
    case voteCount = "vote_count"
  }
}
