import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

class EnvVarTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }

  func testDecoding() throws {
    let json = [
      "APP_ENV": "development",
      "APP_SECRET": "deadbeefdeadbeefdeadbeefdeadbeef",
      "BASE_URL": "http://localhost:8080",
      "BASIC_AUTH_PASSWORD": "world",
      "BASIC_AUTH_USERNAME": "hello",
      "DATABASE_URL": "postgres://hello:world@localhost:5432/pointfreeco",
      "GITHUB_CLIENT_ID": "deadbeef-client-id",
      "GITHUB_CLIENT_SECRET": "deadbeef-client-secret",
      "MAILGUN_DOMAIN": "mg.domain.com",
      "MAILGUN_PRIVATE_API_KEY": "deadbeef-mg-api-key",
      "PORT": "8080",
      "REGIONAL_DISCOUNT_COUPON_ID": "regional-discount",
      "RSS_USER_AGENT_WATCHLIST": "blob,gob",
      "STRIPE_ENDPOINT_SECRET": "whsec_test",
      "STRIPE_PUBLISHABLE_KEY": "pk_test",
      "STRIPE_SECRET_KEY": "sk_test",
    ]

    let envVars = try JSONDecoder()
      .decode(EnvVars.self, from: try JSONSerialization.data(withJSONObject: json))

    let roundTrip =
      try JSONSerialization.jsonObject(with: try JSONEncoder().encode(envVars), options: [])
      as! [String: String]

    assertSnapshot(matching: roundTrip.sorted(by: { $0.key < $1.key }), as: .customDump)
  }
}
