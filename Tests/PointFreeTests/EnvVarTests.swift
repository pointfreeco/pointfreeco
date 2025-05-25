import EnvVars
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

class EnvVarTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testDecoding() async throws {
    let json = [
      "APP_ENV": "development",
      "APP_SECRET": "deadbeefdeadbeefdeadbeefdeadbeef",
      "BASE_URL": "http://localhost:8080",
      "BASIC_AUTH_PASSWORD": "world",
      "BASIC_AUTH_USERNAME": "hello",
      "CLOUDFLARE_ACCOUNT_ID": "deadbeef",
      "CLOUDFLARE_CUSTOMER_SUBDOMAIN": "customer-deadbeef.cloudflarestream.com",
      "CLOUDFLARE_STREAM_API_KEY": "deadbeef",
      "DATABASE_URL": "postgres://pointfreeco:@localhost:5432/pointfreeco_development",
      "GITHUB_CLIENT_ID": "deadbeef-client-id",
      "GITHUB_CLIENT_SECRET": "deadbeef-client-secret",
      "MAILGUN_DOMAIN": "mg.domain.com",
      "MAILGUN_PRIVATE_API_KEY": "deadbeef-mg-api-key",
      "PF_COMMUNITY_SLACK_INVITE_URL":
        "https://join.slack.com/t/pointfreecommunity/shared_invite/zt-1o8l02r36-lygnfRjdoCZA3GtpG9bo_Q",
      "PORT": "8080",
      "REGIONAL_DISCOUNT_COUPON_ID": "regional-discount",
      "RSS_USER_AGENT_WATCHLIST": "",
      "STRIPE_ENDPOINT_SECRET": "whsec_test",
      "STRIPE_PUBLISHABLE_KEY": "pk_test",
      "STRIPE_SECRET_KEY": "sk_test",
      "VIMEO_BEARER": "deadbeef",
      "VIMEO_USER_ID": "1234567890",
    ]

    let envVars = try JSONDecoder()
      .decode(EnvVars.self, from: try JSONSerialization.data(withJSONObject: json))

    let roundTrip =
      try JSONSerialization.jsonObject(with: try JSONEncoder().encode(envVars), options: [])
      as! [String: String]

    await assertSnapshot(matching: roundTrip.sorted(by: { $0.key < $1.key }), as: .customDump)
  }
}
