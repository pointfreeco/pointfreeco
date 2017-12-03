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

let episodeResponse =
  map(episode(for:))
    >>> (
      requireSome(notFoundView: episodeNotFoundView)
        <| requestContextMiddleware
        >-> writeStatus(.ok)
        >-> respond(
          episodeView.map(addHighlightJs >>> addGoogleAnalytics)
      )
)

private func episode(for param: Either<String, Int>) -> Episode? {
  return episodes.first(where: {
    param.left == .some($0.slug) || param.right == .some($0.id)
  })
}

let episodeView = View<RequestContext<Episode>> { ctx in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        title("Episode #\(ctx.data.sequence): \(ctx.data.title)"),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),

      body(
        [`class`([Class.pf.colors.bg.dark])],
        navView.view(ctx.map(const(unit))) <> [
          gridRow([
            gridColumn(
              sizes: [.xs: 12, .md: 7],
              transcriptView.view(ctx.data)
            ),

            gridColumn(
              sizes: [.xs: 12, .md: 5],
              [`class`([Class.grid.first(.xs), Class.grid.last(.md)])],
              [
                div(
                  [`class`([Class.position.sticky(.md), Class.position.top0])],
                  topLevelEpisodeInfoView.view(ctx.data)
                )
              ]
            ),

            ])
          ] <> footerView.view(unit))
      ])
    ])
}

private let topLevelEpisodeInfoView: View<Episode> =
  videoView.contramap(const(unit))
    <>
    (
      (curry(div)([`class`([Class.padding.all(2)])]) >>> pure)
        <¢> episodeTocView.contramap(get(\.transcriptBlocks))
)

private let videoView = View<Prelude.Unit> { _ in
  video(
    [
      `class`([Class.layout.fit]),
      controls(true),
      playsInline(true),
      autoplay(true),
      poster("https://d2sazdeahkz1yk.cloudfront.net/assets/W1siZiIsIjIwMTcvMDQvMjgvMDcvMzYvNTAvOTg2ZjI0N2UtZTU4YS00MTQzLTk4M2YtOGQxZDRiMDRkNGZhLzQ3IFZpZXcgTW9kZWxzIGF0IEtpY2tzdGFydGVyLmpwZyJdLFsicCIsInRodW1iIiwiMTkyMHgxMDgwIyJdXQ?sha=318940b4f059d474")
    ],
    [source(src: "")]
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
        [`class`([Class.pf.colors.fg.white, Class.type.align.end, Class.pf.opacity75])],
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
        [`class`([Class.h6, Class.type.caps, Class.type.lineHeight(4)])],
        [.text(encode("Episode \(ep.sequence)"))]
      ),
      h1(
        [`class`([Class.h3, Class.type.lineHeight(2), Class.margin.top(1)])],
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
        [`class`([Class.pf.code(lang: lang.identifier)])],
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
            Class.border.rounded.all,
            Class.h6,
            Class.padding.leftRight(1),
            Class.padding.topBottom(1),
            ]),
          style(padding(all: .rem(0.25)) <> margin(right: .rem(0.25)))
        ],
        [.text(encode(timestampLabel(for: block.timestamp ?? 0)))]
      ),
      .text(encode(block.content))
      ])

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight(3)])], [
      .text(encode(block.content))
      ])
  }
}

private let episodeNotFoundView = View<Prelude.Unit> { _ in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        ]),
      body(
        minimalNavView.view(unit) <> [
        gridRow([`class`([Class.grid.center(.xs)])], [
          gridColumn(sizes: [:], [
            div([`class`([Class.padding.all(4)])], [
              h5([`class`([Class.h5])], ["Episode not found :("]),
              pre([
                code([`class`([Class.pf.code(lang: "swift")])], [
                  "f: (Episode) -> Never"
                  ])
                ])
              ])
            ])
          ])
        ] <> footerView.view(unit))
      ])
    ])
}
