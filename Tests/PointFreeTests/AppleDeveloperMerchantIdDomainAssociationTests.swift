import Either
import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

final class AppleDeveloperMerchantIdDomainAssociationTests: TestCase {
  func testAssociationFile() {
    let conn =
      connection(from: request(to: .appleDeveloperMerchantIdDomainAssociation))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }
}
