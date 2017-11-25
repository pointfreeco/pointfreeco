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
        style(styleguide),
        title("Episode #\(ep.sequence): \(ep.title)")
        ]),
      body([`class`([Class.pf.colors.bg.dark])], [
        gridRow([
          gridColumn([
            `class`([
              Class.grid.col(.sm, 12),
              Class.grid.col(.md, 7),
              Class.pf.colors.bg.white])
            ], transcriptView.view(ep)
          ),

          gridColumn([
            `class`([
              Class.grid.col(.sm, 12),
              Class.grid.col(.md, 5),
              Class.grid.first(.xs),
              Class.grid.last(.md),
              Class.pf.colors.bg.dark])
            ], [video([
              `class`([
                Class.layout.fit,
                Class.position.sticky(breakpoint: .md),
                Class.position.top0]),
              controls(true)], [source(src: "")])
            ])
          ])
        ]
        + footerView.view(unit))
      ])
    ])
}

private let transcriptView = View<Episode> { ep in

  return div(
    [`class`([Class.padding.all(4)])],
    breadcrumbs.view(unit)
      <> [
        strong(
          [`class`([Class.h6, Class.type.caps, Class.type.lineHeight4])],
          [.text(encode("Episode \(ep.sequence)"))]
        ),
        h1(
          [`class`([Class.h3, Class.type.lineHeight2, Class.margin.top(1)])],
          [.text(encode(ep.title))]
        ),
        p([
          "Hello world. Here is some inline code: ",
          code(
            [`class`([Class.pf.inlineCode])],
            ["f(x)"]
          ),
          ". Let's also ",
          span([`class`([Class.type.bold])], ["try"]),
          " this bit of ",
          span([`class`([Class.type.italic])], ["inline"]),
          " styles!"
          ])
      ]
      <> ep.transcriptBlocks.flatMap(transcriptBlockView.view)
  )
}

private let transcriptBlockView = View<Episode.TranscriptBlock> { block -> Node in
  switch block.type {
  case .code:
    return pre([
      code([`class`([Class.pf.code])], [.text(encode(block.content))])
      ])

  case .paragraph:
    return p([.text(encode(block.content))])

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight3])], [
      .text(encode(block.content))
      ])
  }
}

private let breadcrumbs = View<Prelude.Unit> { _ in
  [
    a(
      [`class`([Class.h6]), href(path(to: .secretHome))],
      ["Home"]
    ),
    " > ",
    a(
      [`class`([Class.h6]), href(path(to: .episodes(tag: nil)))],
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
