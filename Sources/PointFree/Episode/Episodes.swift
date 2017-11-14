import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude

let episodesResponse: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  fetchEpisodes
    >-> respond(view)

private func fetchEpisodes(_ conn: Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<HeadersOpen, [Episode]>> {

  return conn.map(const(episodes))
    |> writeStatus(.ok)
}

private let view = View<[Episode]> { eps in
  document([
    html([
      head([
        ]),
      body([
        h1(
          [`class`("h1")],
          ["Episodes"]
        ),
        ul(
          eps.map(episodeView.view >>> li)
        ),
        a(
          [href(path(to: .secretHome))],
          ["Home"]
        )
        ])
      ])
    ])
}

private let episodeView = View<Episode> { ep in
  a(
    [href(path(to: .episode(.left(ep.slug))))],
    [.text(encode(ep.title))]
  )
}
