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

class EpisodesTests: TestCase {
  func testEpisodesList_NoTagSelected() {
    let request = URLRequest(url: URL(string: url(to: .episodes(tag: nil)))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]
    
    let conn = connection(from: request)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
    
    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 2000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")
        
        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }
  
  func testEpisodesList_TagSelected() {
    let request = URLRequest(url: URL(string: url(to: .episodes(tag: Tag.all.serverSideSwift)))!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]
    
    let conn = connection(from: request)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
    
    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1000))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")
        
        webView.frame.size = .init(width: 500, height: 800)
        assertSnapshot(matching: webView, named: "mobile")
      }
    #endif
  }
}
