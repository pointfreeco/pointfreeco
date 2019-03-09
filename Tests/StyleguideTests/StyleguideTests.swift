import Css
import CssTestSupport
import Html
import HtmlSnapshotTesting
import SnapshotTesting
import Styleguide
import WebKit
import XCTest

class StyleguideTests: XCTestCase {
  override func setUp() {
    super.setUp()
    diffTool = "ksdiff"
  }

  func testStyleguide() {
    assertSnapshot(matching: styleguide, as: .css, named: "pretty")
    assertSnapshot(matching: styleguide, as: .css(.compact), named: "mini")
  }

  func testPointFreeStyles() {
    assertSnapshot(matching: pointFreeBaseStyles, as: .css, named: "pretty")
    assertSnapshot(matching: pointFreeBaseStyles, as: .css(.compact), named: "mini")
  }

  func testGitHubLink_Black() {
    let doc: [Node] = [
      .doctype("html"),
      html([
        head([
          style(unsafe: render(config: .compact, css: styleguide))
          ]),
        body([
          gitHubLink(text: "Login with GitHub", type: .black, redirect: "https://www.pointfree.co")
          ])
        ])
    ]

    assertSnapshot(matching: doc, as: .html)

    let webView = WKWebView.init(frame: NSRect(x: 0, y: 0, width: 190, height: 40))
    webView.loadHTMLString(render(doc), baseURL: nil)
    assertSnapshot(matching: webView, as: .image)
  }

  func testGitHubLink_White() {
    let doc: [Node] = [
      .doctype("html"),
      html([
        head([
          style(unsafe: render(config: .compact, css: styleguide))
          ]),
        body(
          [style("background: #000")],
          [gitHubLink(text: "Login with GitHub", type: .white, redirect: "https://www.pointfree.co")]
        )
        ])
    ]

    assertSnapshot(matching: doc, as: .html)

    let webView = WKWebView.init(frame: NSRect(x: 0, y: 0, width: 190, height: 40))
    webView.loadHTMLString(render(doc), baseURL: nil)
    assertSnapshot(matching: webView, as: .image)
  }

  func testTwitterLink() {
    let doc: [Node] = [
      .doctype("html"),
      html([
        head([
          style(unsafe: render(config: .compact, css: styleguide))
          ]),
        body(
          [twitterShareLink(text: "Tweet", url: "https://www.pointfree.co", via: "pointfreeco")]
        )
        ])
    ]

    assertSnapshot(matching: doc, as: .html)

    let webView = WKWebView.init(frame: NSRect(x: 0, y: 0, width: 80, height: 36))
    webView.loadHTMLString(render(doc), baseURL: nil)
    assertSnapshot(matching: webView, as: .image)
  }
}
