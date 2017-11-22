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

public struct Episode {
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
      |> respond(episodeView)
  }
}


public let episodeView = View<Episode> { ep in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide)
        ]),
      body([`class`([Class.pf.bgDark])], [
        div([
          div([`class`([Class.grid.row])], [
            div([`class`([Class.grid.col(.xs, 6), Class.pf.bgWhite])], [
              div([`class`([PaddingClass.all(4)])], [
                strong(
                  [`class`([Class.h6, Class.type.caps, Class.type.lineHeight4])],
                  [.text(encode("Episode \(ep.sequence)"))]
                ),
                h1(
                  [`class`([Class.h3, Class.type.lineHeight2, MarginClass.top(1)])],
                  [.text(encode(ep.title))]
                ),
                p([
                  """
In the article “Algebraic Structure and Protocols” we described how to use Swift protocols to describe some basic algebraic structures, such as semigroups and monoids, provided some simple examples, and then provided constructions to build new instances from existing. Here we apply those ideas to the concrete ideas of predicates and sorting functions, and show how they build a wonderful little algebra that is quite expressive.
"""
                  ]),
                h2([`class`([Class.h4, Class.type.lineHeight3])], [
                  "Recall from last time..."
                  ]),
                pre([
                  code(
                    [`class`([Class.pf.code])],
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
                ]),
              ]),
            div([`class`([Class.grid.col(.xs, 6), Class.pf.bgDark])], [
              video(
                [controls(true)],
                [source(src: "https://d2sazdeahkz1yk.cloudfront.net/videos/8aa19eff-1703-4377-866b-64660a04c6ee/1/720p00034.ts")]
              )
              ])
            ])
          ])
        ])
      ])
    ])
}

private let breadcrumbs = View<Prelude.Unit> { _ in
  [
    a(
      [`class`([Class.h6]), href(path(to: .secretHome))],
      ["Home"]
    ),
    " > ",
    a(
      [`class`([Class.h6]), href(path(to: .episodes))],
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
