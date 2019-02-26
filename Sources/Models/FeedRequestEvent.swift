import Foundation
import Tagged

public struct FeedRequestEvent: Decodable, Equatable {
  public typealias Id = Tagged<FeedRequestEvent, UUID>

  public var id: Id
  public var type: FeedType
  public var userAgent: String
  public var userId: User.Id
  public var updatedAt: Date

  public enum CodingKeys: String, CodingKey {
    case id
    case type
    case userAgent = "user_agent"
    case userId = "user_id"
    case updatedAt = "updated_at"
  }

  public enum FeedType: String, Decodable {
    case privateEpisodesFeed
  }
}
