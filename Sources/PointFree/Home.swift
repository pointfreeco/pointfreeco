import Css
import EpisodeTranscripts
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
          extraStyles: pricingExtraStyles <> blueGradientStyles <> reflectStyles,
          navStyle: nil,
          title: "Point-Free: A weekly video series on functional programming and the Swift programming language."
        )
    }
)

let secretHomeView = View<(Database.User?, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in
  headerView.view((currentUser, currentSubscriptionStatus, nil))
    <> episodesListView.view(AppEnvironment.current.episodes().reversed())
    <> (currentSubscriptionStatus == .some(.active) ? [] : pricingOptionsView.view((currentUser, .default)))
}

private let menuAndLogoHeaderView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in

  gridRow([`class`([Class.padding([.mobile: [.leftRight: 3, .top: 3, .bottom: 1], .desktop: [.leftRight: 4, .top: 4, .bottom: 4]]), Class.grid.top(.desktop), Class.grid.middle(.mobile), Class.grid.between(.mobile), blueGradientClass])], [

    gridColumn(sizes: [.mobile: 12], [
      gridRow([
        gridColumn(sizes: [.mobile: 0, .desktop: 6], [
          div([
            ])
          ]),
        gridColumn(sizes: [.mobile: 12, .desktop: 6], [
          div(
            [`class`([Class.grid.end(.mobile)])],
            headerLinks.view((currentUser, currentSubscriptionStatus, currentRoute))
          )
          ])
        ]),

      gridRow([`class`([Class.grid.center(.mobile), Class.padding([.mobile: [.topBottom: 2], .desktop: [.topBottom: 0]])])], [
        gridColumn(sizes: [:], [
          a([href(path(to: .secretHome))], [
            img(
              base64: pointFreeHeroSvgBase64,
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.pf.components.heroLogo])]
            )
            ])
          ])
        ])
      ])
    ])
}

let headerView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in

  menuAndLogoHeaderView.view((currentUser, currentSubscriptionStatus, currentRoute))
    + [
      gridRow([`class`([Class.grid.top(.mobile), Class.grid.between(.mobile), Class.padding([.mobile: [.top: 3], .desktop: [.top: 0]])])], [

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(base64: heroMountainSvgBase64, mediaType: .image(.svg), alt: "", [width(.pct(100))])
          ]),

        gridColumn(sizes: [.mobile: 2], [`class`([Class.position.z1])], [
          div([`class`([Class.type.align.center, Class.pf.type.body.leading]), style(margin(leftRight: .rem(-6)))], [
            "A new weekly Swift video series exploring functional programming and more."
            ])
          ]),

        gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
          img(
            base64: heroMountainSvgBase64,
            mediaType: .image(.svg),
            alt: "",
            [width(.pct(100)), `class`([reflectXClass])]
          )
          ]),
        ])
  ]
}

private let headerLinks = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in
  [
    a([href(path(to: .about)), `class`([Class.type.medium, Class.pf.colors.link.black, Class.margin([.mobile: [.right: 2], .desktop: [.right: 3]])])], ["About"]),

    currentSubscriptionStatus == .some(.active)
      ? nil
      : a([href(path(to: .pricing(nil, nil))), `class`([Class.type.medium, Class.pf.colors.link.black, Class.margin([.mobile: [.right: 2], .desktop: [.right: 3]])])], ["Subscribe"]),

    currentUser == nil
      ? gitHubLink(text: "Login", type: .black, redirectRoute: currentRoute)
      : a([href(path(to: .account(.index))), `class`([Class.type.medium, Class.pf.colors.link.black])], ["Account"]),
    ]
    .flatMap(id)
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

private let blueGradientClass = CssSelector.class("blue-gradient")
private let blueGradientStyles =
  blueGradientClass % (
    key("background", "rgba(128,219,255,0.85)")
      <> key("background", "-moz-linear-gradient(top, rgba(128,219,255,0.85) 0%, rgba(128,219,255,0) 100%)")
      <> key("background", "-webkit-gradient(left top, left bottom, color-stop(0%, rgba(128,219,255,0.85)), color-stop(100%, rgba(128,219,255,0)))")
      <> key("background", "-webkit-linear-gradient(top, rgba(128,219,255,0.85) 0%, rgba(128,219,255,0) 100%)")
      <> key("background", "-o-linear-gradient(top, rgba(128,219,255,0.85) 0%, rgba(128,219,255,0) 100%)")
      <> key("background", "-ms-linear-gradient(top, rgba(128,219,255,0.85) 0%, rgba(128,219,255,0) 100%)")
      <> key("background", "linear-gradient(to bottom, rgba(128,219,255,0.85) 0%, rgba(128,219,255,0) 100%)")
)

private let reflectXClass = CssSelector.class("reflect-x")
private let reflectStyles =
  reflectXClass % (
    key("transform", "scaleX(-1)")
      <> key("-webkit-transform", "scaleX(-1)")
      <> key("-moz-transform", "scaleX(-1)")
      <> key("-o-transform", "scaleX(-1)")
      <> key("-ms-transform", "scaleX(-1)")
)
