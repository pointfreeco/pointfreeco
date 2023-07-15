import Css
import Dependencies
import EnvVars
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Conn where Step == HeadersOpen {
  func respond<B>(
    view: @escaping (B) -> Node,
    layoutData: @escaping (A) -> SimplePageLayoutData<B>
  ) -> Conn<ResponseEnded, Data> {
    @Dependency(\.currentRoute) var siteRoute
    @Dependency(\.renderHtml) var renderHtml
    @Dependency(\.siteRouter) var siteRouter

    var newLayoutData = layoutData(self.data)
    newLayoutData.flash = self.request.session.flash
    newLayoutData.isGhosting = self.request.session.ghosteeId != nil

    let pageLayout =
      Metadata
      .create(
        description: newLayoutData.description,
        image: newLayoutData.image,
        title: newLayoutData.title,
        twitterCard: newLayoutData.twitterCard,
        twitterSite: "@pointfreeco",
        type: newLayoutData.openGraphType,
        url: siteRouter.url(for: siteRoute)  // TODO: should we have @Dependency(\.currentURL)?
      )
      >>> metaLayout(simplePageLayout(view))
      >>> addGoogleAnalytics

    return
      self
      .writeSessionCookie { $0.flash = nil }
      .respond(
        body: renderHtml(pageLayout(newLayoutData)),
        contentType: .html
      )
  }
}

func respond<A, B>(
  view: @escaping (B) -> Node,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return { conn in
    IO { conn.respond(view: view, layoutData: layoutData) }
  }
}

func simplePageLayout<A>(
  _ contentView: @escaping (A) -> Node
) -> (SimplePageLayoutData<A>) -> Node {
  @Dependency(\.envVars) var envVars

  return simplePageLayout(
    cssConfig: envVars.appEnv == .testing ? .pretty : .compact,
    emergencyMode: envVars.emergencyMode,
    contentView
  )
}
