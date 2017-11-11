@testable import PointFree
import SnapshotTesting
import XCTest

class EnvVarTests: TestCase {
  func testEncoding() {
    let prettyEncoder = JSONEncoder()
    prettyEncoder.outputFormatting = .prettyPrinted
    assertSnapshot(
      matching: String(data: try! prettyEncoder.encode(EnvVars()), encoding: .utf8)!
    )
  }

  func testDecoding() {
    let json = [
      "AIRTABLE_BASE_1": "deadbeef-base-1",
      "BASIC_AUTH_USERNAME": "hello",
      "GITHUB_CLIENT_ID": "deadbeef-client-id",
      "AIRTABLE_BASE_3": "deadbeef-base-3",
      "STRIPE_PUBLISHABLE_KEY": "pk_test",
      "MAILGUN_PRIVATE_API_KEY": "deadbeef-mg-api-key",
      "BASE_URL": "http://localhost:8080",
      "BASIC_AUTH_PASSWORD": "world",
      "AIRTABLE_BEARER": "deadbeef-bearer",
      "AIRTABLE_BASE_2": "deadbeef-base-2",
      "GITHUB_CLIENT_SECRET": "deadbeef-client-secret",
      "STRIPE_SECRET_KEY": "sk_test",
      "APP_SECRET": "deadbeefdeadbeefdeadbeefdeadbeef"
    ]

    assertSnapshot(
      matching: try! JSONDecoder()
        .decode(EnvVars.self, from: try! JSONSerialization.data(withJSONObject: json))
    )
  }
}
