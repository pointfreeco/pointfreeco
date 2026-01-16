import Dependencies
import Foundation
import GitHub
import Mailgun
import Models
import Stripe
import Tagged

public typealias GitHubClientId = GitHub.Client.ID
public typealias GitHubClientSecret = GitHub.Client.Secret

public typealias MailgunApiKey = Mailgun.Client.ApiKey
public typealias MailgunDomain = Mailgun.Client.Domain

public typealias StripeEndpointSecret = Stripe.Client.EndpointSecret
public typealias StripePublishableKey = Stripe.Client.PublishableKey
public typealias StripeSecretKey = Stripe.Client.SecretKey

public struct EnvVars: Codable {
  public var appEnv: AppEnv
  public var appSecret: AppSecret
  public var baseUrl: URL
  public var basicAuth: BasicAuth
  public var cloudflare: Cloudflare
  public var emergencyMode: Bool
  public var gitHub: GitHub
  public var mailgun: Mailgun
  public var port: Int
  public var postgres: Postgres
  public var regionalDiscountCouponId: Coupon.ID
  public var rssUserAgentWatchlist: [String]
  public var slackInviteURL: String
  public var stripe: Stripe
  public var yearlyGiftCoupon: Coupon.ID?
  public var youtubeChannelID: String

  public init(
    appEnv: AppEnv = .development,
    appSecret: AppSecret = "deadbeefdeadbeefdeadbeefdeadbeef",
    baseUrl: URL = URL(string: "http://localhost:8080")!,
    basicAuth: BasicAuth = BasicAuth(),
    cloudflare: Cloudflare = Cloudflare(),
    emergencyMode: Bool = false,
    gitHub: GitHub = GitHub(),
    mailgun: Mailgun = Mailgun(),
    port: Int = 8080,
    postgres: Postgres = Postgres(),
    regionalDiscountCouponId: Coupon.ID = "regional-discount",
    rssUserAgentWatchlist: [String] = [],
    slackInviteURL: String = "http://slack.com",
    stripe: Stripe = Stripe(),
    yearlyGiftCoupon: Coupon.ID? = nil,
    youtubeChannelID: String = "deadbeef"
  ) {
    self.appEnv = appEnv
    self.appSecret = appSecret
    self.baseUrl = baseUrl
    self.basicAuth = basicAuth
    self.cloudflare = cloudflare
    self.emergencyMode = emergencyMode
    self.gitHub = gitHub
    self.mailgun = mailgun
    self.port = port
    self.postgres = postgres
    self.regionalDiscountCouponId = regionalDiscountCouponId
    self.rssUserAgentWatchlist = rssUserAgentWatchlist
    self.slackInviteURL = slackInviteURL
    self.stripe = stripe
    self.yearlyGiftCoupon = yearlyGiftCoupon
    self.youtubeChannelID = youtubeChannelID
  }

  private enum CodingKeys: String, CodingKey {
    case appEnv = "APP_ENV"
    case appSecret = "APP_SECRET"
    case baseUrl = "BASE_URL"
    case emergencyMode = "EMERGENCY_MODE"
    case port = "PORT"
    case rssUserAgentWatchlist = "RSS_USER_AGENT_WATCHLIST"
    case regionalDiscountCouponId = "REGIONAL_DISCOUNT_COUPON_ID"
    case slackInviteURL = "PF_COMMUNITY_SLACK_INVITE_URL"
    case yearlyGiftCoupon = "YEARLY_GIFT_COUPON"
    case youtubeChannelID = "YOUTUBE_CHANNEL_ID"
  }

  public enum AppEnv: String, Codable {
    case development
    case production
    case staging
    case testing
  }

  public struct BasicAuth: Codable {
    public var username: String
    public var password: String

    public init(
      username: String = "hello",
      password: String = "world"
    ) {
      self.username = username
      self.password = password
    }

    private enum CodingKeys: String, CodingKey {
      case username = "BASIC_AUTH_USERNAME"
      case password = "BASIC_AUTH_PASSWORD"
    }
  }

  public struct Cloudflare: Codable {
    public var accountID: String
    public var customerSubdomain: String
    public var streamAPIKey: String
    public init(
      accountID: String = "deadbeef",
      customerSubdomain: String = "customer-deadbeef.cloudflarestream.com",
      streamAPIKey: String = "deadbeef"
    ) {
      self.accountID = accountID
      self.customerSubdomain = customerSubdomain
      self.streamAPIKey = streamAPIKey
    }
    private enum CodingKeys: String, CodingKey {
      case accountID = "CLOUDFLARE_ACCOUNT_ID"
      case customerSubdomain = "CLOUDFLARE_CUSTOMER_SUBDOMAIN"
      case streamAPIKey = "CLOUDFLARE_STREAM_API_KEY"
    }
  }

  public struct GitHub: Codable {
    public var clientId: GitHubClientId
    public var clientSecret: GitHubClientSecret
    public var pfwDownloadsAccessToken: GitHubAccessToken

    public init(
      clientId: GitHubClientId = "deadbeef-client-id",
      clientSecret: GitHubClientSecret = "deadbeef-client-secret",
      pfwDownloadsAccessToken: GitHubAccessToken = "github_pat_deadbeef"
    ) {
      self.clientId = clientId
      self.clientSecret = clientSecret
      self.pfwDownloadsAccessToken = pfwDownloadsAccessToken
    }

    private enum CodingKeys: String, CodingKey {
      case clientId = "GITHUB_CLIENT_ID"
      case clientSecret = "GITHUB_CLIENT_SECRET"
      case pfwDownloadsAccessToken = "PFW_DOWNLOADS_ACCESS_TOKEN"
    }
  }

  public struct Mailgun: Codable {
    public var apiKey: MailgunApiKey
    public var domain: MailgunDomain

    public init(
      apiKey: MailgunApiKey = "key-deadbeefdeadbeefdeadbeefdeadbeef",
      domain: MailgunDomain = "mg.domain.com"
    ) {
      self.apiKey = apiKey
      self.domain = domain
    }

    private enum CodingKeys: String, CodingKey {
      case apiKey = "MAILGUN_PRIVATE_API_KEY"
      case domain = "MAILGUN_DOMAIN"
    }
  }

  public struct Postgres: Codable {
    public typealias DatabaseUrl = Tagged<Self, String>

    public var databaseUrl: DatabaseUrl

    public init(
      databaseUrl: DatabaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco_development"
    ) {
      self.databaseUrl = databaseUrl
    }

    private enum CodingKeys: String, CodingKey {
      case databaseUrl = "DATABASE_URL"
    }
  }

  public struct Stripe: Codable {
    public var endpointSecret: StripeEndpointSecret = "whsec_test"
    public var publishableKey: StripePublishableKey = "pk_test"
    public var secretKey: StripeSecretKey = "sk_test"

    public init(
      endpointSecret: StripeEndpointSecret = "whsec_test",
      publishableKey: StripePublishableKey = "pk_test",
      secretKey: StripeSecretKey = "sk_test"
    ) {
      self.endpointSecret = endpointSecret
      self.publishableKey = publishableKey
      self.secretKey = secretKey
    }

    private enum CodingKeys: String, CodingKey {
      case endpointSecret = "STRIPE_ENDPOINT_SECRET"
      case publishableKey = "STRIPE_PUBLISHABLE_KEY"
      case secretKey = "STRIPE_SECRET_KEY"
    }
  }
}

extension EnvVars {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.appEnv = try container.decode(AppEnv.self, forKey: .appEnv)
    self.appSecret = try container.decode(AppSecret.self, forKey: .appSecret)
    self.baseUrl = try container.decode(URL.self, forKey: .baseUrl)
    self.basicAuth = try .init(from: decoder)
    self.cloudflare = try Cloudflare(from: decoder)
    self.emergencyMode = try container.decodeIfPresent(String.self, forKey: .emergencyMode) == "1"
    self.gitHub = try .init(from: decoder)
    self.mailgun = try .init(from: decoder)
    self.port = Int(try container.decode(String.self, forKey: .port))!
    self.postgres = try .init(from: decoder)
    self.regionalDiscountCouponId = try container.decode(
      Coupon.ID.self, forKey: .regionalDiscountCouponId)
    self.rssUserAgentWatchlist = (try container.decode(String.self, forKey: .rssUserAgentWatchlist))
      .split(separator: ",")
      .map(String.init)
    self.slackInviteURL = try container.decode(String.self, forKey: .slackInviteURL)
    self.stripe = try .init(from: decoder)
    self.yearlyGiftCoupon = try container.decodeIfPresent(Coupon.ID.self, forKey: .yearlyGiftCoupon)
    self.youtubeChannelID = try container.decode(String.self, forKey: .youtubeChannelID)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.appEnv, forKey: .appEnv)
    try container.encode(self.appSecret, forKey: .appSecret)
    try container.encode(self.baseUrl, forKey: .baseUrl)
    try container.encode("\(self.emergencyMode)", forKey: .emergencyMode)
    try self.basicAuth.encode(to: encoder)
    try self.gitHub.encode(to: encoder)
    try self.mailgun.encode(to: encoder)
    try container.encode(String(self.port), forKey: .port)
    try self.postgres.encode(to: encoder)
    try container.encode(
      String(self.rssUserAgentWatchlist.joined(separator: ",")), forKey: .rssUserAgentWatchlist
    )
    try container.encode(self.regionalDiscountCouponId, forKey: .regionalDiscountCouponId)
    try container.encode(self.slackInviteURL, forKey: .slackInviteURL)
    try self.stripe.encode(to: encoder)
    try container.encodeIfPresent(self.yearlyGiftCoupon, forKey: .yearlyGiftCoupon)
    try container.encode(self.youtubeChannelID, forKey: .youtubeChannelID)
  }
}

extension EnvVars {
  public func assigningValuesFrom(_ env: [String: String]) -> EnvVars {
    let decoded =
      (try? encoder.encode(self))
      .flatMap { try? decoder.decode([String: String].self, from: $0) }
      ?? [:]

    let assigned = decoded.merging(env, uniquingKeysWith: { $1 })

    return (try? JSONSerialization.data(withJSONObject: assigned))
      .flatMap { try? decoder.decode(EnvVars.self, from: $0) }
      ?? self
  }
}

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension EnvVars: DependencyKey {
  public static var liveValue: Self {
    let envFilePath = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent(".pf-env")

    let defaultEnvVarDict =
      withErrorReporting {
        try decoder.decode([String: String].self, from: encoder.encode(Self()))
      }
      ?? [:]

    let localEnvVarDict =
      withErrorReporting {
        try decoder.decode([String: String].self, from: Data(contentsOf: envFilePath))
      }
      ?? [:]

    let envVarDict =
      defaultEnvVarDict
      .merging(localEnvVarDict, uniquingKeysWith: { $1 })
      .merging(ProcessInfo.processInfo.environment, uniquingKeysWith: { $1 })

    return withErrorReporting {
      try decoder.decode(Self.self, from: JSONSerialization.data(withJSONObject: envVarDict))
    }
      ?? Self()
  }

  public static var testValue: EnvVars {
    var envVars = Self()
    envVars.appEnv = EnvVars.AppEnv.testing
    envVars.postgres.databaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco_test"
    return envVars
  }
}

extension DependencyValues {
  public var envVars: EnvVars {
    get { self[EnvVars.self] }
    set { self[EnvVars.self] = newValue }
  }
}
