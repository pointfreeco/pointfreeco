import EmailAddress
import Foundation
import GitHub
import Stripe
import Tagged

public struct User: Decodable, Equatable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHubUserId: GitHubUser.Id
  public var gitHubAccessToken: String
  public var id: Id
  public var isAdmin: Bool
  public var name: String?
  public var referralCode: ReferralCode
  public var referrerId: Id?
  public var rssSalt: RssSalt
  public var subscriptionId: Subscription.Id?
  public var teamInviteCode: TeamInviteCode

  public init(
    email: EmailAddress,
    episodeCreditCount: Int,
    gitHubUserId: GitHubUser.Id,
    gitHubAccessToken: String,
    id: Id,
    isAdmin: Bool,
    name: String?,
    referralCode: ReferralCode,
    referrerId: Id?,
    rssSalt: RssSalt,
    subscriptionId: Subscription.Id?,
    teamInviteCode: TeamInviteCode
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
    self.teamInviteCode = teamInviteCode
  }

  public typealias Id = Tagged<User, UUID>
  public typealias ReferralCode = Tagged<(User, referralCode: ()), String>
  public typealias TeamInviteCode = Tagged<(User, teamInviteCode: ()), String>
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
    case referralCode = "referral_code"
    case referrerId = "referrer_id"
    case subscriptionId = "subscription_id"
    case teamInviteCode = "team_invite_code"
  }

  public var displayName: String {
    return name ?? email.rawValue
  }

  public var gitHubAvatarUrl: URL {
    return URL(string: "https://avatars0.githubusercontent.com/u/\(self.gitHubUserId.rawValue)?v=4")!
  }
}
