#if canImport(SwiftUI) && canImport(WebKit)
  import SwiftUI
  import WebKit

  public struct HTMLPreview<Content: HTML>: NSViewRepresentable {
    let content: Content

    public init(@HTMLBuilder content: () -> Content) {
      self.content = content()
    }

    public func makeNSView(context: Context) -> WKWebView {
      WKWebView(
        frame: NSRect(x: 0, y: 0, width: 640, height: 480),
        configuration: WKWebViewConfiguration()
      )
    }

    public func updateNSView(_ webView: WKWebView, context: Context) {
      var printer = HTMLPrinter()
      Content._render(content, into: &printer)
      webView.loadHTMLString(String(decoding: printer.bytes, as: UTF8.self), baseURL: nil)
    }
  }

  import Html

  public struct NodePreview: NSViewRepresentable {
    let content: Node

    public init(@NodeBuilder content: () -> Node) {
      self.content = content()
    }

    public func makeNSView(context: Context) -> WKWebView {
      WKWebView(
        frame: NSRect(x: 0, y: 0, width: 640, height: 480),
        configuration: WKWebViewConfiguration()
      )
    }

    public func updateNSView(_ webView: WKWebView, context: Context) {
      webView.loadHTMLString(render(content), baseURL: nil)
    }
  }
#endif
