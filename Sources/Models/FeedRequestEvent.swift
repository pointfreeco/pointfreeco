import Foundation
import Tagged

public struct FeedRequestEvent: Decodable, Equatable, Identifiable {
  public var id: Tagged<Self, UUID>
  public var type: FeedType
  public var userAgent: String
  public var userId: User.ID
  public var updatedAt: Date

  public enum FeedType: String, Decodable {
    case privateEpisodesFeed
  }
}
