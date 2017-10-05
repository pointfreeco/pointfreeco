import Foundation

enum EnvVars {
  private static var env: [String: String] {
    return ProcessInfo.processInfo.environment
  }

  static let appSecret = env["APP_SECRET"] ?? "deadbeefdeadbeefdeadbeefdeadbeef"

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
    static let clientId = env["GITHUB_CLIENT_ID"] ?? "bf71e3ff1937fcd066d8"
    static let clientSecret = env["GITHUB_CLIENT_SECRET"] ?? "94fb563ec0c21222db5d0254f228120030bf5bab"
  }

  enum Stripe {
    static let publishableKey = env["STRIPE_PUBLISHABLE_KEY"] ?? "pk_test_1DKkPO2BfCeBmrIorOSsCpxK"
    static let secretKey = env["STRIPE_SECRET_KEY"] ?? "sk_test_93K0AimNIXqK8aUZDKWcceYF"
  }
}
