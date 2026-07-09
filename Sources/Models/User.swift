import Either
import EmailAddress
import Foundation
import GitHub
import Stripe
import Tagged

public struct User: Decodable, Equatable, Identifiable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHub: GitHub?
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
    gitHub: GitHub?,
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
    self.gitHub = gitHub
    self.id = id
    self.isAdmin = isAdmin
    self.name = name
    self.referralCode = referralCode
    self.referrerId = referrerId
    self.rssSalt = rssSalt
    self.subscriptionId = subscriptionId
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.email = try container.decode(EmailAddress.self, forKey: .email)
    self.episodeCreditCount = try container.decode(Int.self, forKey: .episodeCreditCount)
    if let gitHubUserId = try container.decodeIfPresent(GitHubUser.ID.self, forKey: .gitHubUserId),
      let gitHubAccessToken = try container.decodeIfPresent(
        GitHubAccessToken.self, forKey: .gitHubAccessToken
      )
    {
      self.gitHub = GitHub(accessToken: gitHubAccessToken, userId: gitHubUserId)
    } else {
      self.gitHub = nil
    }
    self.id = try container.decode(ID.self, forKey: .id)
    self.isAdmin = try container.decode(Bool.self, forKey: .isAdmin)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.referralCode = try container.decode(ReferralCode.self, forKey: .referralCode)
    self.referrerId = try container.decodeIfPresent(ID.self, forKey: .referrerId)
    self.rssSalt = try container.decode(RssSalt.self, forKey: .rssSalt)
    self.subscriptionId = try container.decodeIfPresent(
      Subscription.ID.self, forKey: .subscriptionId
    )
  }

  public struct GitHub: Equatable {
    public var accessToken: GitHubAccessToken
    public var userId: GitHubUser.ID

    public init(
      accessToken: GitHubAccessToken,
      userId: GitHubUser.ID
    ) {
      self.accessToken = accessToken
      self.userId = userId
    }

    public var avatarUrl: URL {
      return URL(
        string: "https://avatars0.githubusercontent.com/u/\(self.userId.rawValue)?v=4")!
    }
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

  public enum SubscriberState {
    case nonSubscriber
    case subscriber
  }

  public var displayName: String {
    return name ?? email.rawValue
  }
}
