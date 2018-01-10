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

let secretHomeMiddleware: (Conn<StatusLineOpen, Tuple3<Database.User?, Stripe.Subscription.Status?, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: secretHomeView,
      layoutData: { currentUser, currentSubscriptionStatus, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: currentSubscriptionStatus,
          currentUser: currentUser,
          data: (currentUser, currentSubscriptionStatus),
          extraStyles: pricingExtraStyles,
          navStyle: .mountains,
          title: "Point-Free: A weekly video series on functional programming and the Swift programming language."
        )
    }
)

let secretHomeView = View<(Database.User?, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in
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
        div([style(lineHeight(0))], [
          a([href(path(to: .episode(.left(ep.slug))))], [
            img(
              src: "https://waltpaper.com/wp-content/uploads/2017/06/6c7b04501f6e98ab94982a2743ede747-1024x768.jpeg",
              alt: "",
              [style(objectFit(.contain) <> width(.pct(100)) <> height(.pct(100)))]
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
      div([`class`([Class.margin([.mobile: [.top: 2]])])], [
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
