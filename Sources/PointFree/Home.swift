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
          showTopNav: false,
          title: "Point-Free: A weekly video series on functional programming and the Swift programming language."
        )
    }
)

let secretHomeView = View<(Database.User?, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in
  headerView.view((currentUser, currentSubscriptionStatus, nil))
    <> episodesListView.view(episodes.reversed())
    <> (currentSubscriptionStatus == .some(.active) ? [] : pricingOptionsView.view((currentUser, .default)))
}

let headerView = View<(Database.User?, Stripe.Subscription.Status?, Route?)> { currentUser, currentSubscriptionStatus, currentRoute in
  [
    gridRow([`class`([Class.padding([.mobile: [.leftRight: 3, .top: 3, .bottom: 1], .desktop: [.leftRight: 4, .top: 4, .bottom: 2]]), Class.grid.top(.desktop), Class.grid.middle(.mobile), Class.grid.between(.mobile)])], [
      gridColumn(sizes: [:], [
        div([
          ])
        ]),
      gridColumn(sizes: [:], [
        a([href(path(to: .secretHome))], [
          img(
            base64: pointFreeHeroSvgBase64,
            mediaType: .image(.svg),
            alt: "",
            [`class`([Class.pf.components.heroLogo])]
          )
          ])
        ]),
      gridColumn(sizes: [:], [
        div(
          [`class`([Class.grid.end(.mobile)])],
          headerLinks.view((currentUser, currentSubscriptionStatus, currentRoute))
        )
        ])
      ]),

    gridRow([`class`([Class.grid.top(.mobile), Class.grid.between(.mobile), Class.padding([.mobile: [.top: 3], .desktop: [.top: 0]])])], [

      gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
        img(base64: heroLeftMountainSvgBase64, mediaType: .image(.svg), alt: "", [width(.pct(100))])
        ]),

      gridColumn(sizes: [.mobile: 2], [`class`([Class.position.z1])], [
        div([`class`([Class.type.align.center, Class.pf.type.body.leading]), style(margin(leftRight: .rem(-6)))], [
          "A new weekly Swift video series exploring functional programming and more."
          ])
        ]),

      gridColumn(sizes: [.mobile: 5], [`class`([Class.padding([.mobile: [.top: 4], .desktop: [.top: 0]])]), style(lineHeight(0))], [
        img(base64: heroRightMountainSvgBase64, mediaType: .image(.svg), alt: "", [width(.pct(100))])
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
      gridColumn(sizes: [.mobile: 7], episodeInfoColumnView.view(ep)),

      gridColumn(sizes: [.mobile: 5], [
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
      ]),
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
