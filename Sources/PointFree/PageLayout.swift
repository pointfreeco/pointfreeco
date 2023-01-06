import Css
import Dependencies
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
        url: newLayoutData.currentRoute.map(siteRouter.url(for:))
      )
      >>> metaLayout(simplePageLayout(view))
      >>> addGoogleAnalytics

    return
      self
      .writeSessionCookie { $0.flash = nil }
      .respond(
        body: Current.renderHtml(pageLayout(newLayoutData)),
        contentType: .html
      )
  }
}

func respond<A, B>(
  view: @escaping (B) -> Node,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return { conn in
    IO { await conn.respond(view: view, layoutData: layoutData) }
  }
}

func simplePageLayout<A>(
  _ contentView: @escaping (A) -> Node
) -> (SimplePageLayoutData<A>) -> Node {
  simplePageLayout(
    cssConfig: Current.envVars.appEnv == .testing ? .pretty : .compact,
    date: { Current.date() },
    emergencyMode: Current.envVars.emergencyMode,
    contentView
  )
}
