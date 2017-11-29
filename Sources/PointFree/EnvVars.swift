import Foundation

public struct EnvVars: Codable {
  var airtable = Airtable()
  var appSecret = "deadbeefdeadbeefdeadbeefdeadbeef"
  var baseUrlString = "http://localhost:8080"
  var basicAuth = BasicAuth()
  var gitHub = GitHub()
  var mailgun = Mailgun()
  var postgres = Postgres()
  var stripe = Stripe()

  private enum CodingKeys: String, CodingKey {
    case appSecret = "APP_SECRET"
    case baseUrlString = "BASE_URL"
  }

  public struct Airtable: Codable {
    var base1 = "deadbeef-base-1"
    var base2 = "deadbeef-base-2"
    var base3 = "deadbeef-base-3"
    var bearer = "deadbeef-bearer"

    private enum CodingKeys: String, CodingKey {
      case base1 = "AIRTABLE_BASE_1"
      case base2 = "AIRTABLE_BASE_2"
      case base3 = "AIRTABLE_BASE_3"
      case bearer = "AIRTABLE_BEARER"
    }
  }

  public struct BasicAuth: Codable {
    var username = "hello"
    var password = "world"

    private enum CodingKeys: String, CodingKey {
      case username = "BASIC_AUTH_USERNAME"
      case password = "BASIC_AUTH_PASSWORD"
    }
  }

  public struct GitHub: Codable {
    var clientId = "deadbeef-client-id"
    var clientSecret = "deadbeef-client-secret"

    private enum CodingKeys: String, CodingKey {
      case clientId = "GITHUB_CLIENT_ID"
      case clientSecret = "GITHUB_CLIENT_SECRET"
    }
  }

  public struct Mailgun: Codable {
    var apiKey = "deadbeef-mg-api-key"
    var domain = "mg.domain.com"

    private enum CodingKeys: String, CodingKey {
      case apiKey = "MAILGUN_PRIVATE_API_KEY"
      case domain = "MAILGUN_DOMAIN"
    }
  }

  public struct Postgres: Codable {
    var databaseUrl = "postgres://pointfreeco:@localhost:5432/pointfreeco"

    private enum CodingKeys: String, CodingKey {
      case databaseUrl = "DATABASE_URL"
    }
  }

  public struct Stripe: Codable {
    var publishableKey = "pk_test"
    var secretKey = "sk_test"

    private enum CodingKeys: String, CodingKey {
      case publishableKey = "STRIPE_PUBLISHABLE_KEY"
      case secretKey = "STRIPE_SECRET_KEY"
    }
  }

  public var baseUrl: URL {
    return URL(string: self.baseUrlString)!
  }
}

extension EnvVars {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.airtable = try .init(from: decoder)
    self.appSecret = try values.decode(String.self, forKey: .appSecret)
    self.baseUrlString = try values.decode(String.self, forKey: .baseUrlString)
    self.basicAuth = try .init(from: decoder)
    self.gitHub = try .init(from: decoder)
    self.mailgun = try .init(from: decoder)
    self.postgres = try .init(from: decoder)
    self.stripe = try .init(from: decoder)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try self.airtable.encode(to: encoder)
    try container.encode(self.appSecret, forKey: .appSecret)
    try container.encode(self.baseUrlString, forKey: .baseUrlString)
    try self.basicAuth.encode(to: encoder)
    try self.gitHub.encode(to: encoder)
    try self.mailgun.encode(to: encoder)
    try self.postgres.encode(to: encoder)
    try self.stripe.encode(to: encoder)
  }
}
