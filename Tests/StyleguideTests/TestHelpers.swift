import SnapshotTesting
import XCTest

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
  func assertWebPageSnapshot(
    matching html: String,
    named name: String? = nil,
    record recording: Bool = SnapshotTesting.record,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line) {
    #if os(iOS)
      sizes.forEach { size in
        let webView = UIWebView(frame: .init(origin: .zero, size: size))
        webView.loadHTMLString(String(decoding: Data(html.utf8), as: UTF8.self), baseURL: nil)
        let exp = expectation(description: "webView")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          assertSnapshot(
            matching: webView,
            named: (name ?? "") + "_\(size.width)x\(size.height)",
            record: record,
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
