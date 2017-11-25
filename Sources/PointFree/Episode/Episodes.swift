import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

let episodesResponse: Middleware<StatusLineOpen, ResponseEnded, Tag?, Data> =
  fetchEpisodes
    >-> respond(view)

private func fetchEpisodes(_ conn: Conn<StatusLineOpen, Tag?>) -> IO<Conn<HeadersOpen, [Episode]>> {

  return conn.map(
    const(
      episodes
        .filter { conn.data.map($0.tags.contains) != .some(false) }
        .sorted(by: get(\.sequence))
        .reversed()
    )
    )
    |> writeStatus(.ok)
}

private let view = View<[Episode]> { eps in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        ]),
      body([

        div([`class`([Class.grid.row])], [
          div([`class`([Class.grid.col(.xs, 12), Class.padding.leftRight(4), Class.padding.topBottom(2)])], [
            div([
              h3(
                [`class`("h3")],
                ["Episodes"]
              ),
              ul([`class`([Class.type.list.reset])],
                 eps.map(episodeListItemView.view >>> li)
              )
              ])
            ])
          ])
        ] + footerView.view(unit))
      ])
    ])
}

let episodeImageStyles: Stylesheet =
  width(.pct(100))
    <> maxHeight(.px(200))
    <> objectFit(.cover)

private let episodeListItemView = View<Episode> { ep in
  div([`class`([Class.grid.row, Class.margin.bottom(4)])], [
    div([`class`([Class.grid.col, Class.grid.col(.xs, 4)])], [
      div([`class`([Class.padding.right(3)])], [
        img(
          base64: logoSvgBase64,
          mediaType: .image(.svg),
          alt: "",
          [`class`([Class.pf.colors.bg.white, Class.layout.fit]), style(episodeImageStyles)])
        ])
      ]),

    div([`class`([Class.grid.col, Class.grid.col(.xs, 8)])], [
      div([
        strong(
          [`class`([Class.h6, Class.type.caps, Class.type.lineHeight1])],
          [.text(encode("Episode \(ep.sequence)"))]
        ),
        h5([`class`([Class.h5, Class.type.lineHeight1, Class.margin.top(0), Class.margin.bottom(2)])], [
          a(
            [href(path(to: .episode(.left(ep.slug))))],
            [.text(encode(ep.title))])
          ]),
        p([.text(encode(ep.blurb))]),

        div(episodeTagsView.view(ep.tags))
        ])
      ])
    ])
}

extension Array {
  func sorted<A: Comparable>(by f: (Element) -> A) -> Array {
    return self.sorted { lhs, rhs in f(lhs) < f(rhs) }
  }
}

private let episodeTagsView = View<[Tag]> { tags in
  ol(
    [`class`([Class.layout.inlineBlock, Class.type.list.reset])],
    tags
      .sorted(by: get(\.name))
      .map(
        episodeTagView.view
          >>> li([`class`([Class.layout.inlineBlock, Class.margin.right(1), Class.margin.bottom(2)])])
    )
  )
}

private let episodeTagView = View<Tag> { tag in
  a(
    [
      href(   path(to: .episodes(tag: .some(tag)))   ),
      `class`([
        Class.h6,
        Class.padding.leftRight(2),
        Class.padding.topBottom(1),
        Class.border.pill,
        Class.pf.colors.bg.light,
        Class.pf.colors.fg.white,
        Class.type.textDecorationNone,
        ])
    ],
    [.text(encode(tag.name))]
  )
}
