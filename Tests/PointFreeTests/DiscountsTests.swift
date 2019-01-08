import Either
import Html
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest

private func secureRequest(_ urlString: String) -> URLRequest {
  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ ["X-Forwarded-Proto": "https"]
}

class DiscountsTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testDiscounts_LoggedOut() {
    assertSnapshot(
      matching: connection(from: request(with: secureRequest("http://localhost:8080/discounts/blobfest")))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    assertSnapshot(
      matching: connection(from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }
}
