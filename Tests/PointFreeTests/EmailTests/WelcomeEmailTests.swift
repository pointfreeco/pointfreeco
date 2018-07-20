import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

final class WelcomeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testWelcomeEmail1() {
    let emailNodes = welcomeEmailView("", welcomeEmail1Content).view(.newUser)

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testWelcomeEmail2() {
    let emailNodes = welcomeEmailView("", welcomeEmail2Content).view(.newUser)

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testWelcomeEmail3() {
    let emailNodes = welcomeEmailView("", welcomeEmail3Content).view(.newUser)

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }
}
