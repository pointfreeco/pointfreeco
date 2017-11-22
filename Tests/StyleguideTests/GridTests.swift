import Css
import CssReset
import CssTestSupport
import Html
import HtmlCssSupport
import Prelude
import SnapshotTesting
@testable import Styleguide
import XCTest

class GridTests: XCTestCase {
  func testGrid() {
    assertSnapshot(matching: flexGridStyles, record: true)
  }

  func testSampleGrid() {

  }
}

let testStyles =
  ".grid" % backgroundColor(.rgba(250, 250, 250, 1))
    <> ".col" % backgroundColor(.rgba(220, 220, 220, 1))

private let doc = document([
  html([
    head([
      style(reset <> testStyles)
      ]),
    body([
      div([`class`("grid")], [
        div([`class`("col col-3")], [
          ]),
        div([`class`("col col-3")], [
          ]),
        div([`class`("col col-3")], [
          ]),
        div([`class`("col col-3")], [
          ])
        ])
      ])
    ])
  ])

#if os(Linux)
  extension GridTests {
    static var allTests : [(String, GridTests -> () throws -> Void)] {
      return [
        ("testGrid", testGrid),
        ("testSampleGrid", testSampleGrid)
      ]
    }
  }
#endif
