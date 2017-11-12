import Css
import CssReset
import CssTestSupport
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import Prelude
import SnapshotTesting
@testable import Styleguide
import XCTest

let typographyDoc = document([
  html([
    head([
      style(reset <> typography)
      ]),
    body([
      h1([`class`(".h1 fw-bold")], ["The Algebra of Predicates and Sorting Functions"]),
      h1([`class`(".h2 fw-bold")], ["The Algebra of Predicates and Sorting Functions"]),
      h1([`class`(".h3 fw-bold")], ["The Algebra of Predicates and Sorting Functions"]),
      h1([`class`(".h4 fw-bold")], ["The Algebra of Predicates and Sorting Functions"]),
      h1([`class`(".h5 fw-bold")], ["The Algebra of Predicates and Sorting Functions"]),
      h1([`class`(".h6 fw-bold h-caps")], ["The Algebra of Predicates and Sorting Functions"]),

      p([
        """
        In the article “Algebraic Structure and Protocols” we described how to use Swift protocols to \
        describe some basic algebraic structures, such as semigroups and monoids, provided some simple \
        examples, and then provided constructions to build new instances from existing. Here we apply those \
        ideas to the concrete ideas of predicates and sorting functions, and show how they build a wonderful \
        little algebra that is quite expressive.
        """
        ])
      ])
    ])
  ])


class TypographyTests: XCTestCase {
  func testTypography() {
    assertSnapshot(matching: typography, record: true)
    assertWebPageSnapshot(matching: prettyPrint(node: typographyDoc), record: true)
  }
}

#if os(Linux)
  extension TypographyTests {
    static var allTests : [(String, TypographyTests -> () throws -> Void)] {
      return [
        ("testTypography", testTypography),
      ]
    }
  }
#endif









#if os(iOS)
  import UIKit

let sizes = [
  CGSize(width: 320, height: 568),
  CGSize(width: 375, height: 667),
  CGSize(width: 768, height: 1024),
  CGSize(width: 800, height: 600),
]
#endif

extension XCTestCase {
  func assertWebPageSnapshot(
    matching html: String,
    named name: String? = nil,
    record recording: Bool = SnapshotTesting.record,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line) {
    #if os(iOS)
      sizes.forEach { size in
        let webView = UIWebView(frame: .init(origin: .zero, size: size))
        webView.loadHTMLString(String(decoding: Data(html.utf8), as: UTF8.self), baseURL: nil)
        let exp = expectation(description: "webView")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          assertSnapshot(
            matching: webView,
            named: (name ?? "") + "_\(size.width)x\(size.height)",
            record: record,
            file: file,
            function: function,
            line: line
          )
          exp.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
      }
    #endif
  }
}































































