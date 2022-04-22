import Css
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import FunctionalCss
import HtmlCssSupport
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

func respond<A, B>(
  view: @escaping (B) -> Node,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
  )
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return { conn in
      var newLayoutData = layoutData(conn.data)
      newLayoutData.flash = conn.request.session.flash
      newLayoutData.isGhosting = conn.request.session.ghosteeId != nil

      let pageLayout = Metadata
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

      return conn
        |> writeSessionCookieMiddleware { $0.flash = nil }
        >=> respond(
          body: Current.renderHtml(pageLayout(newLayoutData)),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(
  _ contentView: @escaping (A) -> Node
) -> (SimplePageLayoutData<A>) -> Node {
  simplePageLayout(
    cssConfig: Current.envVars.appEnv == .testing ? .pretty : .compact,
    date: Current.date,
    emergencyMode: Current.envVars.emergencyMode,
    contentView
  )
}
