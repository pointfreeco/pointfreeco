import Foundation

public struct EnvVars: Codable {
  public var appEnv = AppEnv.development
  public var appSecret = "deadbeefdeadbeefdeadbeefdeadbeef"
  public var baseUrl = URL(string: "http://localhost:8080")!
  public var basicAuth = BasicAuth()
  public var gitHub = GitHub()
  public var mailgun = Mailgun()
  public var port = 8080
  public var postgres = Postgres()
  public var stripe = Stripe()

  private enum CodingKeys: String, CodingKey {
    case appEnv = "APP_ENV"
    case appSecret = "APP_SECRET"
    case baseUrl = "BASE_URL"
    case port = "PORT"
  }

  public enum AppEnv: String, Codable {
    case development
    case production
    case staging
    case testing
  }

  public struct BasicAuth: Codable {
    public var username = "hello"
    public var password = "world"

    private enum CodingKeys: String, CodingKey {
      case username = "BASIC_AUTH_USERNAME"
      case password = "BASIC_AUTH_PASSWORD"
    }
  }

  public struct GitHub: Codable {
    public var clientId = "deadbeef-client-id"
    public var clientSecret = "deadbeef-client-secret"

    private enum CodingKeys: String, CodingKey {
      case clientId = "GITHUB_CLIENT_ID"
      case clientSecret = "GITHUB_CLIENT_SECRET"
    }
  }

  public struct Mailgun: Codable {
    public var apiKey = "key-deadbeefdeadbeefdeadbeefdeadbeef"
    public var domain = "mg.domain.com"

    private enum CodingKeys: String, CodingKey {
      case apiKey = "MAILGUN_PRIVATE_API_KEY"
      case domain = "MAILGUN_DOMAIN"
    }
  }

  public struct Postgres: Codable {
    public var databaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco_development"

    private enum CodingKeys: String, CodingKey {
      case databaseUrl = "DATABASE_URL"
    }
  }

  public struct Stripe: Codable {
    public var endpointSecret = "whsec_test"
    public var publishableKey = "pk_test"
    public var secretKey = "sk_test"

    private enum CodingKeys: String, CodingKey {
      case endpointSecret = "STRIPE_ENDPOINT_SECRET"
      case publishableKey = "STRIPE_PUBLISHABLE_KEY"
      case secretKey = "STRIPE_SECRET_KEY"
    }
  }
}

extension EnvVars {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.appEnv = try values.decode(AppEnv.self, forKey: .appEnv)
    self.appSecret = try values.decode(String.self, forKey: .appSecret)
    self.baseUrl = try values.decode(URL.self, forKey: .baseUrl)
    self.basicAuth = try .init(from: decoder)
    self.gitHub = try .init(from: decoder)
    self.mailgun = try .init(from: decoder)
    self.port = Int(try values.decode(String.self, forKey: .port))!
    self.postgres = try .init(from: decoder)
    self.stripe = try .init(from: decoder)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.appEnv, forKey: .appEnv)
    try container.encode(self.appSecret, forKey: .appSecret)
    try container.encode(self.baseUrl, forKey: .baseUrl)
    try self.basicAuth.encode(to: encoder)
    try self.gitHub.encode(to: encoder)
    try self.mailgun.encode(to: encoder)
    try container.encode(String(self.port), forKey: .port)
    try self.postgres.encode(to: encoder)
    try self.stripe.encode(to: encoder)
  }
}

extension EnvVars {
  public func assigningValuesFrom(_ env: [String: String]) -> EnvVars {
    let decoded = (try? encoder.encode(self))
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
