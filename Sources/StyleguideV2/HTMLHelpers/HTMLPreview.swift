#if canImport(SwiftUI) && canImport(WebKit)
  import SwiftUI
  import WebKit

  public struct HTMLPreview<Head: HTML, Body: HTML>: HTMLDocument {
    public let body: Body
    public let head: Head

    public init(
      @HTMLBuilder body: () -> Body,
      @HTMLBuilder head: () -> Head = { HTMLEmpty() }
    ) {
      self.body = body()
      self.head = head()
    }
  }

  extension HTMLPreview: NSViewRepresentable {
    public func makeNSView(context: Context) -> WKWebView {
      WKWebView(
        frame: NSRect(x: 0, y: 0, width: 640, height: 480),
        configuration: WKWebViewConfiguration()
      )
    }

    public func updateNSView(_ webView: WKWebView, context: Context) {
      var printer = HTMLPrinter()
      Self._render(
        Self {
          body
        } head: {
          head
        }, into: &printer)
      webView.loadHTMLString(String(decoding: printer.bytes, as: UTF8.self), baseURL: nil)
    }
  }
#endif
