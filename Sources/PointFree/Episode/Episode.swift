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
        title("Episode #\(ep.sequence): \(ep.title)"),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
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
              div(
                [`class`([Class.position.sticky(breakpoint: .md), Class.position.top0])],
                topLevelEpisodeInfoView.view(ep)
              )
            ]
          ),
          
          ])
        ]
        + footerView.view(unit))
      ])
    ])
}

private let topLevelEpisodeInfoView: View<Episode> =
  videoView.contramap(const(unit))
    <>
    (
      (curry(div)([`class`([Class.padding.all(2)])]) >>> pure)
        <¢> topLevelBlurbView.contramap(get(\.blurb))
        <> topLevelTagsView.contramap(get(\.tags))
        <> episodeTocView.contramap(get(\.transcriptBlocks))
)

private let videoView = View<Prelude.Unit> { _ in
  video(
    [`class`([Class.layout.fit]), controls(true), playsInline(true), autoplay(true)],
    [source(src: "https://d2sazdeahkz1yk.cloudfront.net/previews/487300ce-c2f7-4b39-87c7-19a202f6ca88/1/hls.m3u8")]
  )
}

private let topLevelBlurbView = View<String> { blurb in
  gridRow([`class`([Class.padding.bottom(1)])], [
    gridColumn(sizes: [.xs: 12], [
      div([`class`([Class.pf.colors.fg.white])], [
        .text(encode(blurb))
        ])
      ])
    ])
}

private let topLevelTagsView = View<[Tag]> { tags in
  gridRow([`class`([Class.padding.bottom(2)])], [
    gridColumn(sizes: [.xs: 12], [
      div([], pillTagsView.view(tags))
      ])
    ])
}

private let episodeTocView = View<[Episode.TranscriptBlock]> { blocks in
  blocks
    .filter { $0.type == .title && $0.timestamp != nil }
    .flatMap { block in
      tocEntryView.view((block.content, block.timestamp ?? 0))
  }
}

private let tocEntryView = View<(content: String, timestamp: Double)> { content, timestamp in
  gridRow([`class`([Class.margin.bottom(1)])], [
    gridColumn(sizes: [.xs: 10], [
      div([
        a(
          [href("#"), `class`([Class.pf.colors.fg.white, Class.type.textDecorationNone])],
          [.text(encode(content))]
        ),
        ])
      ]),

    gridColumn(sizes: [.xs: 2], [
      div(
        [`class`([Class.pf.colors.fg.white, Class.type.align.end, Class.pf.colors.opacity75])],
        [.text(encode(timestampLabel(for: timestamp)))]
      )
      ])
    ])
}

func timestampLabel(for timestamp: Double) -> String {
  let minute = Int(timestamp / 60)
  let second = Int(timestamp) % 60
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(minuteString):\(secondString)"
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
      ]
      <> ep.transcriptBlocks.flatMap(transcriptBlockView.view)
  )
}

private let transcriptBlockView = View<Episode.TranscriptBlock> { block -> Node in
  switch block.type {
  case let .code(lang):
    return pre([
      code(
        [`class`([Class.pf.code, CssSelector.class(lang.identifier)])],
        [.text(encode(block.content))]
      )
      ])

  case .paragraph:
    return p([
      a(
        [
          href("#"),
          `class`([
            Class.type.textDecorationNone,
            Class.pf.colors.bg.light,
            Class.pf.colors.fg.white,
            Class.border.rounded,
            Class.h6,
            Class.padding.leftRight(1),
            Class.padding.topBottom(1),
            ]),
          style(padding(all: .rem(0.25)) <> margin(right: .rem(0.25)))
        ],
        ["0:00"]
      ),
      .text(encode(block.content))
      ])

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
