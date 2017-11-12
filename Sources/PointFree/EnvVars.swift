import Foundation

enum EnvVars {
  private static let env: [String: String] = {
    let envFilePath = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent(".env")

    let localEnvVars = (try? Data(contentsOf: envFilePath))
      .flatMap { try? JSONDecoder().decode([String: String].self, from: $0) }

    return localEnvVars ?? ProcessInfo.processInfo.environment
  }()

  static let appSecret = env["APP_SECRET"] ?? "deadbeefdeadbeefdeadbeefdeadbeef"
  static let baseUrl = URL(string: env["BASE_URL"] ?? "http://localhost:8080")

  enum Airtable {
    static let base1 = env["AIRTABLE_BASE_1"] ?? "deadbeef-base-1"
    static let base2 = env["AIRTABLE_BASE_2"] ?? "deadbeef-base-2"
    static let base3 = env["AIRTABLE_BASE_3"] ?? "deadbeef-base-3"
    static let bearer = env["AIRTABLE_BEARER"] ?? "deadbeef-bearer"
  }

  enum BasicAuth {
    static let username = env["BASIC_AUTH_USERNAME"] ?? "hello"
    static let password = env["BASIC_AUTH_PASSWORD"] ?? "world"
  }

  enum GitHub {
    static let clientId = env["GITHUB_CLIENT_ID"] ?? "deadbeef-client-id"
    static let clientSecret = env["GITHUB_CLIENT_SECRET"] ?? "deadbeef-client-secret"
  }

  enum Mailgun {
    static let apiKey = env["MAILGUN_PRIVATE_API_KEY"] ?? "deadbeef-mg-api-key"
  }

  enum Stripe {
    static let publishableKey = env["STRIPE_PUBLISHABLE_KEY"] ?? "pk_test"
    static let secretKey = env["STRIPE_SECRET_KEY"] ?? "sk_test"
  }

  enum PostgreSQL {
    static let url = env["DATABASE_URL"] ?? "postgres://pointfreeco:@localhost:5432/pointfreeco"
  }
}
