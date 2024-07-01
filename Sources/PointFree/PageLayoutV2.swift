import Dependencies
import Foundation
import Html
import HttpPipeline
import StyleguideV2
import Views

extension Conn where Step == HeadersOpen {
  func respondV2(
    layoutData: SimplePageLayoutData<Void>,
    @HTMLBuilder view: () -> some HTML
  ) -> Conn<ResponseEnded, Data> {
    @Dependency(\.currentRoute) var siteRoute
    @Dependency(\.renderHtml) var renderHtml
    @Dependency(\.siteRouter) var siteRouter

    var layoutData = layoutData
    layoutData.flash = self.request.session.flash

    let metadata = Metadata(
      description: layoutData.description,
      image: layoutData.image,
      title: layoutData.title,
      twitterCard: layoutData.twitterCard,
      twitterSite: "@pointfreeco",
      type: layoutData.openGraphType,
      url: siteRouter.url(for: siteRoute)  // TODO: should we have @Dependency(\.currentURL)?
    )

    var printer = HTMLPrinter()
    PageLayout._render(
      PageLayout(
        layoutData: layoutData,
        metadata: metadata,
        cssConfig: .pretty, // TODO
        content: view
      ),
      into: &printer
    )
    return self
      .writeSessionCookie { $0.flash = nil }
      .respond(
        body: Data(printer.bytes),
        contentType: .html
      )
  }
}

extension Conn where Step == HeadersOpen {
  fileprivate func respond(body: Data, contentType: MediaType) -> Conn<ResponseEnded, Data> {
    return self.map { _ in body }
      .writeHeader(.contentType(contentType))
      .writeHeader(.contentLength(body.count))
      .closeHeaders()
      .end()
  }
}
