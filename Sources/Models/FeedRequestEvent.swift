import Foundation
import Tagged

public struct FeedRequestEvent: Decodable, Equatable {
  public typealias Id = Tagged<FeedRequestEvent, UUID>

  public var id: Id
  public var type: FeedType
  public var userAgent: String
  public var userId: User.Id
  public var updatedAt: Date

  public enum FeedType: String, Decodable {
    case privateEpisodesFeed
  }
}
