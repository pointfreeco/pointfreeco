import Css
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

private let codeStyle = ".code" % (
  display(.block)
    <> backgroundColor(.rgba(250, 250, 250, 1))
    <> fontFamily(["monospace"])
    <> padding(all: .rem(2))
    <> overflow(x: .auto)
)

private let styles =
  video % maxWidth(.pct(100))
    <> ".bg-dark" % backgroundColor(.rgba(32, 32, 32, 1))
    <> codeStyle

private let view = View<Episode> { ep in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(
          styleguide
            <> styles
        )
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
                ),
                pre([
                  code(
                    [`class`("code")],
                    [
                      """
                      infix operator <>: AdditionPrecedence

                      protocol Semigroup {
                        // **AXIOM** Associativity
                        // For all a, b, c in Self:
                        //    a <> (b <> c) == (a <> b) <> c
                        static func <> (lhs: Self, rhs: Self) -> Self
                      }

                      protocol Monoid: Semigroup {
                        // **AXIOM** Identity
                        // For all a in Self:
                        //    a <> e == e <> a == a
                        static var e: Self { get }
                      }
                      """
                    ])
                  ]),
                p(["""
                   Types that conform to these protocols have some of the simplest forms of computation \
                   around. They know how to take two values of the type, and combine them into a single \
                   value. We know of quite a few types that are monoids:
                   """
                  ])
              ]
            ),
            div(
              [`class`("col-6 p5 bg-dark")],
              [
                video(
                  [controls(true)],
                  [source(src: "https://d2sazdeahkz1yk.cloudfront.net/videos/8aa19eff-1703-4377-866b-64660a04c6ee/1/720p00034.ts")]
                )
              ]
            )
          ]
        )
      ])
    ])
  ])
}

private let breadcrumbs = View<Prelude.Unit> { _ in
  [
    a(
      [`class`("h6"), href(path(to: .secretHome))],
      ["Home"]
    ),
    " > ",
    a(
      [`class`("h6"), href(path(to: .episodes))],
      ["Episodes"]
    ),
    br
  ]
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
