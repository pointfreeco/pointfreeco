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

    let doc: Node = [
      .doctype,
      .html(
        .body(
          .div(
            attributes: [.id("hero")],
            .h1("Point-Free")
          ),
          .p(
            attributes: [.class("p1")],
            "This p tag gets styles from the tag element and classes."
          ),
          .p(
            attributes: [.id("some-id"), .class("bold leading"), .style(lineHeight(1.25))],
            "This p tag gets styles from the id, classes, inline styles, and element tag!"
          ),
          .div(
            attributes: [.id("footer")],
            "I'm a div footer with an id"
          ),
          .div(
            attributes: [.class("footer")],
            "I'm a div footer with a class"
          ),
          .footer("I'm a footer element")
        )
      )
    ]

    assertSnapshot(matching: applyInlineStyles(node: doc, stylesheet: stylesheet), as: .html)
  }
}
