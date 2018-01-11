import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

enum NavStyle {
  case minimal(MinimalStyle)
  case mountains

  enum MinimalStyle {
    case dark
    case light
  }
}

struct SimplePageLayoutData<A> {
  private(set) var currentRoute: Route?
  private(set) var currentSubscriptionStatus: Stripe.Subscription.Status?
  private(set) var currentUser: Database.User?
  private(set) var data: A
  private(set) var description: String?
  private(set) var extraStyles: Stylesheet
  private(set) var flash: Flash?
  private(set) var image: String?
  private(set) var navStyle: NavStyle?
  private(set) var openGraphType: OpenGraphType
  private(set) var title: String
  private(set) var twitterCard: TwitterCard
  private(set) var useHighlightJs: Bool

  init(
    currentRoute: Route? = nil,
    currentSubscriptionStatus: Stripe.Subscription.Status? = nil,
    currentUser: Database.User?,
    data: A,
    description: String? = nil,
    extraStyles: Stylesheet = .empty,
    image: String? = nil,
    navStyle: NavStyle? = .some(.minimal(.light)),
    openGraphType: OpenGraphType = .website,
    title: String,
    twitterCard: TwitterCard = .summaryLargeImage,
    useHighlightJs: Bool = false
    ) {

    self.currentRoute = currentRoute
    self.currentSubscriptionStatus = currentSubscriptionStatus
    self.currentUser = currentUser
    self.data = data
    self.description = description
    self.extraStyles = extraStyles
    self.flash = nil
    self.image = image
    self.navStyle = navStyle
    self.openGraphType = openGraphType
    self.title = title
    self.twitterCard = twitterCard
    self.useHighlightJs = useHighlightJs
  }
}

func respond<A, B>(
  view: View<B>,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
  )
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return { conn in
      let newLayoutData = layoutData(conn.data) |> \.flash .~ conn.request.session.flash
      let pageLayout = metaLayout(simplePageLayout(view))
        .map(addGoogleAnalytics)
        .contramap(
          Metadata.create(
            description: newLayoutData.description,
            image: newLayoutData.image,
            title: newLayoutData.title,
            twitterCard: newLayoutData.twitterCard,
            twitterSite: "@pointfreeco",
            type: newLayoutData.openGraphType,
            url: newLayoutData.currentRoute.map(url(to:))
          )
      )

      return conn
        |> writeSessionCookieMiddleware(\.flash .~ nil)
        >-> respond(
          body: pageLayout.rendered(with: newLayoutData),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(_ contentView: View<A>) -> View<SimplePageLayoutData<A>> {
  return View { layoutData in
    document([
      html([
        head([
          title(layoutData.title),
          style(renderedNormalizeCss),
          style(styleguide),
          style(layoutData.extraStyles),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          link([
            href(url(to: .feed(.atom))),
            rel(.alternate),
            title("Point-Free Episodes"),
            type(.application(.atom)),
            ])
          ]
          <> (layoutData.useHighlightJs ? highlightJsHead : [])
        ),
        body(
          (layoutData.flash.map(flashView.view) ?? [])
            <> (layoutData.navStyle.map { navView.view(($0, layoutData.currentUser, layoutData.currentSubscriptionStatus, layoutData.currentRoute)) } ?? [])
            <> contentView.view(layoutData.data)
            <> footerView.view(layoutData.currentUser)
        )
        ])
      ])
  }
}

private let navView = View<(NavStyle, Database.User?, Stripe.Subscription.Status?, Route?)> { navStyle, currentUser, currentSubscriptionStatus, currentRoute -> [Node] in

  switch navStyle {
  case .mountains:
    return mountainNavView.view((currentUser, currentSubscriptionStatus, currentRoute))
  case let .minimal(minimalStyle):
    return minimalNavView.view((minimalStyle, currentUser, currentSubscriptionStatus, currentRoute))
  }
}

let flashView = View<Flash> { flash in
  gridRow([`class`([flashClass(for: flash.priority)])], [
    gridColumn(sizes: [.mobile: 12], [text(flash.message)])
    ])
}

private func flashClass(for priority: Flash.Priority) -> CssSelector {
  let base = Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 1]])

  switch priority {
  case .notice:
    return base
      | Class.pf.colors.fg.black
      | Class.pf.colors.bg.green
  case .warning:
    return base
      | Class.pf.colors.fg.black
      | Class.pf.colors.bg.yellow
  case .error:
    return base
      | Class.pf.colors.fg.white
      | Class.pf.colors.bg.red
  }
}

private let highlightJsHead: [ChildOf<Element.Head>] = [
  link(
    [rel(.stylesheet), href("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css")]
  ),
  script([src("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js")]),
  script("hljs.initHighlightingOnLoad();")
]
