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

    public init<D: HTMLDocument>(
      @HTMLBuilder document: () -> D
    ) where Head == D.Head, Body == D.Content {
      let document = document()
      self.body = document.body
      self.head = document.head
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
      let bytes = Self {
        body
      } head: {
        head
      }
      .render()
      let htmlString = String(decoding: bytes, as: UTF8.self)
      print(htmlString)
      webView.loadHTMLString(htmlString, baseURL: nil)
    }
  }
#endif
