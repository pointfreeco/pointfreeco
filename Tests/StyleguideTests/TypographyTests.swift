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

class TypographyTests: XCTestCase {
  func testTypography() {
    assertSnapshot(matching: typography, record: true)
    assertWebPageSnapshot(matching: prettyPrint(node: typographyDoc), record: true)
  }
}

private let typographyDoc = document([
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

#if os(Linux)
  extension TypographyTests {
    static var allTests : [(String, TypographyTests -> () throws -> Void)] {
      return [
        ("testTypography", testTypography),
      ]
    }
  }
#endif







































































