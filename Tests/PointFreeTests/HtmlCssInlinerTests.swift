import Css
import Html
import HtmlCssSupport
import HtmlPrettyPrint
import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest
#if !os(Linux)
  import WebKit
#endif

class HtmlCssInlinerTests: TestCase {
  func testHtmlCssInliner() {
//    record = true
    let stylesheet =
      body % fontSize(.px(16))
        <> "#hero" % maxWidth(.pct(100))
        <> ".p1" % padding(all: .px(16))
        <> ".bold" % fontWeight(.bold)
        <> ".leading" % fontSize(.px(18))
        <> p % color(.black)
        <> "#some-id" % backgroundColor(.red)
        <> (body | html) % height(.pct(100))

    let doc = document([
      html([
        body([
          div([id("hero")], [
            h1(["Point-Free"])
            ]),

          p([Html.`class`("p1")], [
            "This p tag gets styles from the tag element and classes."
            ]),

          p([id("some-id"), Html.`class`("bold leading"), style(lineHeight(1.25))], [
            "This p tag gets styles from the id, classes, inline styles, and element tag!"
            ])
          ])
        ])
      ])

    assertSnapshot(matching: applyInlineStyles(node: doc, stylesheet: stylesheet))
  }
}
