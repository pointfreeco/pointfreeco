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

let secretHomeResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> respond(secretHomeView.map(addGoogleAnalytics))

let secretHomeView = View<Prelude.Unit> { _ in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(
        headerView.view(unit)
          <> episodesListView.view(episodes.reversed())
          <> _pricingView.view(unit)
          <> footerView.view(unit)
      )
      ])
    ])
}

private let headerView = View<Prelude.Unit> { _ in
  [
    gridRow([`class`([Class.padding([.mobile: [.leftRight: 3, .top: 3, .bottom: 1], .desktop: [.leftRight: 4, .top: 4, .bottom: 2]]), Class.grid.top(.desktop), Class.grid.middle(.mobile), Class.grid.between(.mobile)])], [
      gridColumn(sizes: [:], [
        div([
          a([href("#"), `class`([Class.type.bold, Class.pf.colors.link.gray650])], ["About"])
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
        div([
          a([href(path(to: .pricing(nil))), `class`([Class.pf.components.buttons.purple])], ["Subscribe"])
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
