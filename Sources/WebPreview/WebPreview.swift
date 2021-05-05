#if DEBUG && os(macOS)
  @_exported import SwiftUI
  import WebKit

  public struct WebPreview {
    public let html: String

    public init(html: String) {
      self.html = html
    }
  }

  extension WebPreview: NSViewRepresentable {
    public typealias NSViewType = WKWebView

    public func makeNSView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
      webView.loadHTMLString(self.html, baseURL: nil)
      return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) {}
  }
#endif
