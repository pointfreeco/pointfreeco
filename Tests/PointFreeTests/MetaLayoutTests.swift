import Html
import HtmlSnapshotTesting
@testable import HttpPipeline
import Prelude
import SnapshotTesting
@testable import PointFree
import PointFreeTestSupport
import View
import XCTest

class MetaLayoutTests: TestCase {
  func testMetaTagsWithStyleTag() {

    let view = View<Prelude.Unit> { _ in
      [
        doctype,
        html([
          head([title("Point-Free")]),
          body(["Hello world!"])
          ])
      ]
    }

    let layoutView = metaLayout(view)

    assertSnapshot(
      matching: layoutView.view(
        .init(
          description: "A video series on functional programming.",
          image: "http://www.example.com/image.jpg",
          rest: unit,
          title: "Point-Free",
          twitterCard: .summaryLargeImage,
          twitterSite: "pointfreeco",
          type: .website,
          url: "http://www.pointfree.co"
        )
      ),
      as: .html
    )
  }
}
