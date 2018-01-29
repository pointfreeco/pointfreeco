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
import UrlFormEncoding

let homeMiddleware: (Conn<StatusLineOpen, Tuple3<Database.User?, Stripe.Subscription.Status?, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: homeView,
      layoutData: { currentUser, currentSubscriptionStatus, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: currentSubscriptionStatus,
          currentUser: currentUser,
          data: (currentUser, currentSubscriptionStatus),
          description: "Point-Free is a video series exploring functional programming and Swift.",
          extraStyles: pricingExtraStyles,
          image: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
          navStyle: .mountains,
          openGraphType: .website,
          title: "Point-Free: A video series on functional programming and the Swift programming language.",
          twitterCard: .summaryLargeImage
        )
    }
)

let homeView = View<(Database.User?, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in
  episodesListView.view(AppEnvironment.current.episodes().reversed())
    <> (currentSubscriptionStatus == .some(.active) ? [] : pricingOptionsView.view((currentUser, .default)))
}

private let episodesListView = View<[Episode]> { eps in
  eps.flatMap(episodeRowView.view)
}

private let episodeRowView = View<Episode> { ep in

  dividerView.view(unit) + [
    gridRow([
      gridColumn(sizes: [.mobile: 12, .desktop: 7], episodeInfoColumnView.view(ep)),

      gridColumn(sizes: [.mobile: 12, .desktop: 5], [`class`([Class.grid.first(.mobile), Class.grid.last(.desktop)])], [
        div([`class`([Class.size.height100pct]), style(lineHeight(0) <> gradient <> minHeight(.px(300)))], [
          a([href(path(to: .episode(.left(ep.slug))))], [
            img(
              src: ep.image,
              alt: "",
              [`class`([Class.size.width100pct, Class.size.height100pct]),
               style(objectFit(.cover))]
            )
            ])
          ])
        ])
      ])
  ]
}

private let episodeInfoColumnView = View<Episode> { ep in
  div(
    [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep) + [
      div([`class`([Class.margin([.mobile: [.top: 3]])])], [
        a(
          [href(path(to: .episode(.left(ep.slug)))), `class`([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular])],
          [
            "Watch episode",
            img(
              base64: rightArrowSvgBase64(fill: "#974DFF"),
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), width(16), height(16)]
            )
          ]
        ),
        ])
    ]
  )
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
