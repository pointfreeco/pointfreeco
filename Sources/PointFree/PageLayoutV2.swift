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
    layoutData.isGhosting = self.request.session.ghosteeId != nil

    let metadata = Metadata(
      description: layoutData.description,
      image: layoutData.image,
      title: layoutData.title,
      twitterCard: layoutData.twitterCard,
      twitterSite: "@pointfreeco",
      type: layoutData.openGraphType,
      url: siteRouter.url(for: siteRoute)  // TODO: should we have @Dependency(\.currentURL)?
    )

//    >>> metaLayout(simplePageLayout(view))
//    >>> addPlausibleAnalytics

    return self
      .writeSessionCookie { $0.flash = nil }
      .respond(
        body: renderHtml(
          PageLayout(
            layoutData: layoutData,
            metadata: metadata,
            cssConfig: .pretty, // TODO
            emergencyMode: false, // TODO,
            content: view
          )
          .body
        ),
        contentType: .html
      )
  }
}
