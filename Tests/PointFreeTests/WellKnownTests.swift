import Either
import HttpPipeline
import InlineSnapshotTesting
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

final class WellKnownTests: TestCase {
  @MainActor
  func testAssociationFile() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .wellKnown(.appleDeveloperMerchantIdDomainAssociation)))
    )

    await assertSnapshot(matching: conn, as: .conn)
  }

  @MainActor
  func testAtProto() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .wellKnown(.atProto)))
    )

    await assertInlineSnapshot(of: conn, as: .conn) {
      """
      GET http://localhost:8080/.well-known/atproto-did
      Cookie: pf_session={}

      200 OK
      Content-Length: 32
      Content-Type: text/plain
      Referrer-Policy: strict-origin-when-cross-origin
      X-Content-Type-Options: nosniff
      X-Download-Options: noopen
      X-Frame-Options: SAMEORIGIN
      X-Permitted-Cross-Domain-Policies: none
      X-XSS-Protection: 1; mode=block

      did:plc:jij7pkovdqzb3vqdgm2w4ibh

      """
    }
  }
}
