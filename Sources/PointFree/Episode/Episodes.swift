import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

let episodesResponse: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  fetchEpisodes
    >-> respond(view)

private func fetchEpisodes(_ conn: Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<HeadersOpen, [Episode]>> {

  return conn.map(const(Array(episodes.reversed())))
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
              ),
              a(
                [href(path(to: .secretHome))],
                ["Home"]
              )
              ])
            ])
          ])
        ])
      ])
    ])
}

let css: Stylesheet =
  width(.pct(100))
    <> maxHeight(.px(200))
    <> objectFit(.cover)

private let episodeListItemView = View<Episode> { ep in
  div([`class`([Class.grid.row, Class.margin.bottom(2)])], [
    div([`class`([Class.grid.col, Class.grid.col(.xs, 4)])], [
      div([`class`([Class.padding.right(3)])], [
        img(src: "https://d2sazdeahkz1yk.cloudfront.net/assets/W1siZiIsIjIwMTcvMTEvMTYvMTgvNDUvMDMvZTVlNWUyZGYtZTA4NC00ODAyLWEyYjAtMjNjY2ZhMmQ5YWVlLzc2IFVuZGVyc3RhbmRpbmcgUmVhY3RpdmUgR2xpdGNoZXMuanBnIl0sWyJwIiwidGh1bWIiLCIzMDB4MTY5IyJdXQ?sha=9a80d378dac6eaad", alt: "", [`class`([Class.pf.bgDark, Class.layout.fit]), style(css)])
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
            [.text(encode(ep.title))]
          )
          ]),
        p([.text(encode(ep.blurb))])
        ])
      ])
    ])
}
