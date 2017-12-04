import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport
#if !os(Linux)
  import WebKit
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
  func assertWebPageSnapshot<I>(
    matching conn: Conn<I, Data>,
    named name: String? = nil,
    record recording: Bool = SnapshotTesting.record,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line) {
    #if os(iOS)
      sizes.forEach { size in
        let webView = UIWebView(frame: .init(origin: .zero, size: size))
        webView.loadHTMLString(String(decoding: conn.response.body, as: UTF8.self), baseURL: nil)
        let exp = expectation(description: "webView")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          assertSnapshot(
            matching: webView,
            named: (name ?? "") + "_\(size.width)x\(size.height)",
            record: recording,
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

class LaunchSignupTests: TestCase {
  func testHome() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
    assertWebPageSnapshot(matching: result.perform())
  }

  func testHome_SuccessfulSignup() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/?success=true")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
    assertWebPageSnapshot(matching: result.perform())
  }

  func testSignup() {
    var request = URLRequest(url: URL(string: "http://localhost:8080/launch-signup")!)
    request.httpMethod = "POST"
    request.httpBody = Data("email=hello@pointfree.co".utf8)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testConfirmationEmail() {
    let emailNodes = launchSignupConfirmationEmailView.view(unit)

    assertSnapshot(matching: prettyPrint(nodes: emailNodes), pathExtension: "html")

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView)
      }
    #endif
  }
}
