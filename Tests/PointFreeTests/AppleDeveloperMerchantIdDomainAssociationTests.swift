import Either
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class AppleDeveloperMerchantIdDomainAssociationTests: TestCase {
  func testNotLoggedIn_IndividualMonthly() {
    let conn = connection(from: request(to: .appleDeveloperMerchantIdDomainAssociation))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }
}
