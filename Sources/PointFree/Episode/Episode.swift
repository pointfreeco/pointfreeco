import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
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
      |> respond(episodeView.map(addHighlightJs))
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

          gridColumn(
            sizes: [.sm: 12, .md: 7],
            transcriptView.view(ep)
          ),

          gridColumn(
            sizes: [.sm: 12, .md: 5],
            [`class`([Class.grid.first(.xs), Class.grid.last(.md)])],
            [
              div([`class`([Class.position.sticky(breakpoint: .md), Class.position.top0])], [
                video([
                  `class`([Class.layout.fit]),
                  controls(true)], [source(src: "https://d2sazdeahkz1yk.cloudfront.net/previews/487300ce-c2f7-4b39-87c7-19a202f6ca88/1/hls.m3u8")])
                ])
            ]
          ),
          
          ])
        ]
        + footerView.view(unit))
      ])
    ])
}

private let transcriptView = View<Episode> { ep in

  return div(
    [`class`([Class.padding.all(4), Class.pf.colors.bg.white])],
    [
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
  case let .code(lang):
    return pre([
      code([`class`([Class.pf.code, CssSelector.class(lang.identifier)])], [.text(encode(block.content))])
      ])

  case .paragraph:
    return p([.text(encode(block.content))])

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight3])], [
      .text(encode(block.content))
      ])
  }
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

private let highlightJsHead: [ChildOf<Element.Head>] = [
  link([rel(.stylesheet), href("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css")]),
  script([src("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js")]),
  script("hljs.initHighlightingOnLoad();")
]

/// Walks the node tree looking for the <head> tag, and once found adds the necessary script and stylesheet
/// tags for highlight.js
private func addHighlightJs(_ nodes: [Node]) -> [Node] {
  return nodes.map { node in
    switch node {
    case .comment:
      return node
    case let .document(doc):
      return .document(addHighlightJs(doc))
    case let .element(element):
      return element.name == "head"
        ? .element(element |> \.content %~ { ($0 ?? []) + highlightJsHead.map(get(\.node)) })
        : .element(element |> \.content %~ { $0.map(addHighlightJs) })
    case .text:
      return node
    }
  }
}
