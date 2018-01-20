import Either
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
  import WebKit
#endif

class PricingTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }
  
  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
  
  func testPricing() {
    let request = URLRequest(url: URL(string: url(to: .pricing(nil)))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]
    
    let conn = connection(from: request)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
    
    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1900))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")
        
        webView.evaluateJavaScript(
          """
          document.getElementById("tab0").checked = false;
          document.getElementById("tab1").checked = true;
          var quantity = document.getElementsByName("pricing[team]")[0];
          quantity.value = 10;
          quantity.onchange();
          """, completionHandler: nil)
        assertSnapshot(matching: webView, named: "desktop-team")
        
        webView.frame.size.width = 400
        assertSnapshot(matching: webView, named: "mobile")
        
      }
    #endif
  }
  
  func testPricingLoggedIn_NonSubscriber() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .pricing(nil), session: .loggedIn))
      let result = conn |> siteMiddleware
      
      assertSnapshot(matching: result.perform())
      
      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1900))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")
          
          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
          
        }
      #endif
    }
  }

  func testPricingLoggedIn_Subscriber() {
    let conn = connection(from: request(to: .pricing(nil), session: .loggedIn))
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }
}
