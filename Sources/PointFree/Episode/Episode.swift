import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Prelude
import HttpPipelineHtmlSupport

struct Episode {
  var blurb: String
  var id: Int
  var slug: String
  var title: String
}

let episodes = [
  Episode(
    blurb: """
           What is a function really?!
           """,
    id: 1,
    slug: "ep1-introduction-to-functions",
    title: "Introduction to Functions"
  ),

  Episode(
    blurb: """
           We formulate predicates and sorting functions in terms of monoids \
           and show how they can lead to very composable constructions.
           """,
    id: 42,
    slug: "ep6-the-algebra-of-predicates-and-sorting-functions",
    title: "The Algebra of Predicates and Sorting Functions"
  )
]

let episodeResponse: Middleware<StatusLineOpen, ResponseEnded, Either<String, Int>, Data> =
  fetchEpisode
    >-> responseEpisode

private func fetchEpisode(_ conn: Conn<StatusLineOpen, Either<String, Int>>) -> IO<Conn<HeadersOpen, Episode?>> {

  let possibleEpisode = episodes.first(where: {
    conn.data.left == .some($0.slug)
      || conn.data.right == .some($0.id)
  })

  return conn.map(const(possibleEpisode))
    |> writeStatus(possibleEpisode == nil ? .notFound : .ok)
}

private func responseEpisode(_ conn: Conn<HeadersOpen, Episode?>) -> IO<Conn<ResponseEnded, Data>> {

  switch conn.data {
  case .none:
    return conn.map(const(unit))
      |> respond(notFoundView)
  case let .some(ep):
    return conn.map(const(ep))
      |> respond(view)
  }
}

private let view = View<Episode> { ep in
  document([
    html([
      head([
        style(reset)
        ]),
      body([
        h1([.text(encode(ep.title))]),
        p([.text(encode(ep.blurb))]),
        a([href(path(to: .episode(.left(ep.slug))))], ["Link!"])
        ])
      ])
    ])
}

private let notFoundView = View<Prelude.Unit> { _ in
  document([
    html([
      head([
        ]),
      body([
        "Not found..."
        ])
      ])
    ])
}
