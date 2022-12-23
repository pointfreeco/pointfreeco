import Either
import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

@MainActor
final class AppleDeveloperMerchantIdDomainAssociationTests: TestCase {
  func testAssociationFile() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .appleDeveloperMerchantIdDomainAssociation))
    )
    .performAsync()

    await assertSnapshot(matching: conn, as: .conn)
  }
}
