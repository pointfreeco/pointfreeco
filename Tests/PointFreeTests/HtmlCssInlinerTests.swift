import Css
import Html
import HtmlCssSupport
import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

class HtmlCssInlinerTests: TestCase {
  func testHtmlCssInliner() {
    let stylesheet1: Stylesheet =
      body % fontSize(.px(16))
        <> p % color(.black)
        <> "#hero" % maxWidth(.pct(100))
        <> "#some-id" % backgroundColor(.red)
        <> ".p1" % padding(all: .px(16))
    let stylesheet2: Stylesheet =
      ".bold" % fontWeight(.bold)
        <> ".leading" % fontSize(.px(18))
        <> (body | html) % height(.pct(100))
        <> ("#footer" | footer | ".footer") % display(.block)

    let stylesheet = stylesheet1 <> stylesheet2

    let doc = [
      doctype,
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
            ]),

          div([id("footer")], [
            "I'm a div footer with an id"
            ]),
          div([Html.`class`("footer")], [
            "I'm a div footer with a class"
            ]),
          footer([
            "I'm a footer element"
            ])
          ])
        ])
    ]

    assertSnapshot(matching: applyInlineStyles(nodes: doc, stylesheet: stylesheet), as: .html)
  }
}
