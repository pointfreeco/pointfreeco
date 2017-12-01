@testable import PointFree
import SnapshotTesting
import XCTest

class EnvVarTests: TestCase {
  func testDecoding() {
    let json = [
      "AIRTABLE_BASE_1": "deadbeef-base-1",
      "AIRTABLE_BASE_2": "deadbeef-base-2",
      "AIRTABLE_BASE_3": "deadbeef-base-3",
      "AIRTABLE_BEARER": "deadbeef-bearer",
      "APP_SECRET": "deadbeefdeadbeefdeadbeefdeadbeef",
      "BASE_URL": "http://localhost:8080",
      "BASIC_AUTH_PASSWORD": "world",
      "BASIC_AUTH_USERNAME": "hello",
      "DATABASE_URL": "postgres://hello:world@localhost:5432/pointfreeco",
      "GITHUB_CLIENT_ID": "deadbeef-client-id",
      "GITHUB_CLIENT_SECRET": "deadbeef-client-secret",
      "MAILGUN_DOMAIN": "mg.domain.com",
      "MAILGUN_PRIVATE_API_KEY": "deadbeef-mg-api-key",
      "STRIPE_PUBLISHABLE_KEY": "pk_test",
      "STRIPE_SECRET_KEY": "sk_test",
    ]

    assertSnapshot(
      matching: try! JSONDecoder()
        .decode(EnvVars.self, from: try! JSONSerialization.data(withJSONObject: json))
    )
  }
}
