import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
  import WebKit
#endif

class PaymentInfoTests: TestCase {
  func testRender() {
    let conn = connection(from: request(to: url(to: .paymentInfo)))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
}
