import Foundation
import GitHub
import Stripe
import Tagged
import PointFreePrelude

public struct EmailSetting: Codable, Equatable {
  public var newsletter: Newsletter
  public var userId: User.Id

  public enum CodingKeys: String, CodingKey {
    case newsletter
    case userId = "user_id"
  }

  public enum Newsletter: String, RawRepresentable, Codable, Equatable {
    case announcements
    case newBlogPost
    case newEpisode
    case welcomeEmails

    public static let allNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode,
      .welcomeEmails
    ]

    public static let subscriberNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode
    ]
  }
}

public struct EpisodeCredit: Decodable, Equatable {
  public var episodeSequence: Int
  public var userId: User.Id

  public enum CodingKeys: String, CodingKey {
    case episodeSequence = "episode_sequence"
    case userId = "user_id"
  }
}

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

public struct Subscription: Decodable {
  public var id: Id
  public var stripeSubscriptionId: Stripe.Subscription.Id
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var userId: User.Id

  public typealias Id = Tagged<Subscription, UUID>

  private enum CodingKeys: String, CodingKey {
    case id
    case stripeSubscriptionId = "stripe_subscription_id"
    case stripeSubscriptionStatus = "stripe_subscription_status"
    case userId = "user_id"
  }
}

public struct TeamInvite: Decodable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Id
  public var inviterUserId: User.Id

  public typealias Id = Tagged<TeamInvite, UUID>

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case email
    case id
    case inviterUserId = "inviter_user_id"
  }
}
