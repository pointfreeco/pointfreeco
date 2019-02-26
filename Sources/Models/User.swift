import Foundation
import GitHub
import PointFreePrelude
import Stripe
import Tagged

public struct User: Decodable, Equatable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHubUserId: GitHub.User.Id
  public var gitHubAccessToken: String
  public var id: Id
  public var isAdmin: Bool
  public var name: String?
  public var rssSalt: RssSalt
  public var subscriptionId: Subscription.Id?

  public typealias Id = Tagged<User, UUID>
  public typealias RssSalt = Tagged<(User, rssSalt: ()), UUID>

  public enum CodingKeys: String, CodingKey {
    case email
    case episodeCreditCount = "episode_credit_count"
    case gitHubUserId = "github_user_id"
    case gitHubAccessToken = "github_access_token"
    case id
    case isAdmin = "is_admin"
    case name
    case rssSalt = "rss_salt"
    case subscriptionId = "subscription_id"
  }

  public var displayName: String {
    return name ?? email.rawValue
  }
}
