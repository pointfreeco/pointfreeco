import Either
import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

final class AppleDeveloperMerchantIdDomainAssociationTests: TestCase {
  @MainActor
  func testAssociationFile() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .appleDeveloperMerchantIdDomainAssociation))
    )

    await assertSnapshot(matching: conn, as: .conn)
  }
}
