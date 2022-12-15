import Either
import EmailAddress
import Foundation
import GitHub
import Stripe
import Tagged

public struct User: Decodable, Equatable, Identifiable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHubUserId: GitHubUser.ID
  public var gitHubAccessToken: String
  public var id: Tagged<Self, UUID>
  public var isAdmin: Bool
  public var name: String?
  public var referralCode: ReferralCode
  public var referrerId: ID?
  public var rssSalt: RssSalt
  public var subscriptionId: Subscription.ID?

  public init(
    email: EmailAddress,
    episodeCreditCount: Int,
    gitHubUserId: GitHubUser.ID,
    gitHubAccessToken: String,
    id: ID,
    isAdmin: Bool,
    name: String?,
    referralCode: ReferralCode,
    referrerId: ID?,
    rssSalt: RssSalt,
    subscriptionId: Subscription.ID?
  ) {
    self.email = email
    self.episodeCreditCount = episodeCreditCount
    self.gitHubUserId = gitHubUserId
    self.gitHubAccessToken = gitHubAccessToken
    self.id = id
    self.isAdmin = isAdmin
    self.name = name
    self.referralCode = referralCode
    self.referrerId = referrerId
    self.rssSalt = rssSalt
    self.subscriptionId = subscriptionId
  }

  public typealias ReferralCode = Tagged<(Self, referralCode: ()), String>
  public typealias RssSalt = Tagged<(Self, rssSalt: ()), String>

  public enum CodingKeys: String, CodingKey {
    case email
    case episodeCreditCount = "episode_credit_count"
    case gitHubUserId = "github_user_id"
    case gitHubAccessToken = "github_access_token"
    case id
    case isAdmin = "is_admin"
    case name
    case rssSalt = "rss_salt"
    case referralCode = "referral_code"
    case referrerId = "referrer_id"
    case subscriptionId = "subscription_id"
  }

  public var displayName: String {
    return name ?? email.rawValue
  }

  public var gitHubAvatarUrl: URL {
    return URL(
      string: "https://avatars0.githubusercontent.com/u/\(self.gitHubUserId.rawValue)?v=4")!
  }
}
