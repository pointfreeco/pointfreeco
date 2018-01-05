import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import UrlFormEncoding

let secretHomeMiddleware: (Conn<StatusLineOpen, Database.User?>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> respond(
      view: secretHomeView.map(addGoogleAnalytics),
      layoutData: { currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: currentUser,
          showTopNav: false,
          title: "Point-Free: A weekly video series on functional programming and the Swift programming language.",
          useHighlightJs: false
        )
    }
)

let secretHomeView = View<Database.User?> { currentUser in
  headerView.view(unit)
    <> episodesListView.view(episodes.reversed())
    <> pricingOptionsView.view((.default, currentUser))
}

let headerView = View<Prelude.Unit> { _ in
  [
    gridRow([`class`([Class.padding([.mobile: [.leftRight: 3, .top: 3, .bottom: 1], .desktop: [.leftRight: 4, .top: 4, .bottom: 2]]), Class.grid.top(.desktop), Class.grid.middle(.mobile), Class.grid.between(.mobile)])], [
      gridColumn(sizes: [:], [
        div([
          a([href(path(to: .about)), `class`([Class.type.bold, Class.pf.colors.link.gray650])], ["About"])
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
        div([`class`([Class.grid.end(.mobile)])], [
          a([href(path(to: .pricing(nil, nil))), `class`([Class.pf.components.button(color: .purple)])], ["Subscribe"])
          ])
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
