import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

struct Episode {
  var blurb: String
  var id: Int
  var sequence: Int
  var slug: String
  var title: String
}

let episodes = [
  Episode(
    blurb: """
           What is a function really?!
           """,
    id: 1,
    sequence: 1,
    slug: "ep1-introduction-to-functions",
    title: "Introduction to Functions"
  ),

  Episode(
    blurb: """
           We formulate predicates and sorting functions in terms of monoids \
           and show how they can lead to very composable constructions.
           """,
    id: 42,
    sequence: 2,
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
        style(reset <> styleguide)
        ]),
      body([
        div(
          [`class`("grid")],
          [
            div(
              [`class`("col-6 p5")],
              [
                strong(
                  [`class`("h6 h-caps")],
                  [.text(encode("Episode \(ep.sequence)"))]
                ),
                h1(
                  [`class`("h3")],
                  [.text(encode(ep.title))]
                ),
                p(
                  [`class`("h4")],
                  [.text(encode(ep.blurb))]
                )
              ]
            ),
            div(
              [`class`("col-6 p5 bg-dark")],
              [
                video(
                  [controls(true)],
                  [source(src: "video.ts")]
                )
              ]
            )
          ]
        )
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

// TODO: move to a support package in swift-web
@testable import Css

private func `class`<T>(_ selectors: [CssSelector]) -> Attribute<T> {
  return .init(
    "class",
    selectors.reduce("") { accum, sel in
      accum
        + renderSelector(inline, sel).replacingOccurrences(of: ".", with: "")
    }
  )
}
