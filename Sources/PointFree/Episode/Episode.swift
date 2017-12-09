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
        [
          gridRow([
            gridColumn(
              sizes: [.xs: 12, .md: 7],
              leftColumnView.view(ctx.data)
            ),

            gridColumn(
              sizes: [.xs: 12, .md: 5],
              [`class`([Class.grid.first(.xs), Class.grid.last(.md)])],
              [
                div(
                  [`class`([Class.position.sticky(.md), Class.position.top0])],
                  rightColumnView.view(ctx.data)
                )
              ]
            ),

            ])
          ] <> footerView.view(unit))
      ])
    ])
}

private let rightColumnView: View<Episode> =
  videoView.contramap(const(unit))
    <> episodeTocView.contramap(^\.transcriptBlocks)
    <> downloadsView.contramap(^\.codeSampleDirectory)
    <> creditsView.contramap(const(unit))


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

private let episodeTocView = View<[Episode.TranscriptBlock]> { blocks in
  div([`class`([Class.padding.leftRight(4), Class.padding.top(4)])],
    [
      h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding.bottom(1)])], ["Chapters"]),
      ]
      <> blocks
        .filter { $0.type == .title && $0.timestamp != nil }
        .flatMap { block in
          tocChapterView.view((block.content, block.timestamp ?? 0))
    }
  )
}

private let tocChapterView = View<(content: String, timestamp: Double)> { content, timestamp in
  gridRow([`class`([Class.margin.bottom(1)])], [
    gridColumn(sizes: [.xs: 10], [
      div([
        a(
          [href("#"), `class`([Class.pf.colors.link.green, Class.type.textDecorationNone])],
          [.text(encode(content))]
        ),
        ])
      ]),

    gridColumn(sizes: [.xs: 2], [
      div(
        [`class`([Class.pf.colors.fg.purple, Class.type.align.end, Class.pf.opacity75])],
        [.text(encode(timestampLabel(for: timestamp)))]
      )
      ])
    ])
}

private let downloadsView = View<String> { codeSampleDirectory in
  div([`class`([Class.padding.leftRight(4), Class.padding.top(3)])],
      [
        h6(
          [`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding.bottom(1)])],
          ["Downloads"]
        ),
        img(
          base64: gitHubSvgBase64(fill: "#FFF080"),
          mediaType: .image(.svg),
          alt: "",
          [`class`([Class.align.middle]), width(20), height(20)]
        ),
        a(
          [
            href(gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: codeSampleDirectory))),
            `class`([Class.pf.colors.link.yellow, Class.margin.left(1), Class.align.middle])
          ],
          [.text(encode("\(codeSampleDirectory).playground"))]
        )
    ]
  )
}

private let creditsView = View<Prelude.Unit> { _ in
  div([`class`([Class.padding.leftRight(4), Class.padding.topBottom(3)])],
      [
        h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding.bottom(1)])], ["Credits"]),
        p(
          [`class`([Class.pf.colors.fg.gray850])],
          ["Hosted by Brandon Williams and Stephen Celis. Recorded in Brooklyn, NY."]
        )
    ]
  )
}

private func timestampLabel(for timestamp: Double) -> String {
  let minute = Int(timestamp / 60)
  let second = Int(timestamp) % 60
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(minuteString):\(secondString)"
}

private let leftColumnView =
  (curry(div)([]) >>> pure)
    <¢> episodeInfoView
    <> dividerView.contramap(const(unit))
    <> transcriptView.contramap(^\.transcriptBlocks)

private let episodeInfoView = View<Episode> { ep in
  div(
    [`class`([Class.padding.all(4), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep)
  )
}

let topLevelEpisodeInfoView = View<Episode> { ep in
  [
    strong(
      [`class`([Class.h6, Class.type.caps, Class.type.lineHeight(4)])],
      [.text(encode("Episode \(ep.sequence)"))]
    ),
    h1(
      [`class`([Class.h4, Class.margin.top(0)])],
      [.text(encode(ep.title))]
    ),
    p([`class`([Class.pf.type.body.regular])], [.text(encode(ep.blurb))]),
    ]
}

let dividerView = View<Prelude.Unit> { _ in
  hr([`class`([Class.pf.components.divider])])
}

private let transcriptView = View<[Episode.TranscriptBlock]> { blocks in
  div([`class`([Class.padding.all(4), Class.pf.colors.bg.white])],
      blocks.flatMap(transcriptBlockView.view)
  )
}

private let transcriptBlockView = View<Episode.TranscriptBlock> { block -> Node in
  switch block.type {
  case let .code(lang):
    return pre([
      code(
        [`class`([Class.pf.components.code(lang: lang.identifier)])],
        [.text(encode(block.content))]
      )
      ])

  case .paragraph:
    return p([
      a(
        [
          href("#"),
          `class`([Class.pf.components.videoTimeLink]),
          style(padding(all: .rem(0.25)) <> margin(right: .rem(0.25)))
        ],
        [.text(encode(timestampLabel(for: block.timestamp ?? 0)))]
      ),
      .text(encode(block.content))
      ])

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight(3), Class.padding.top(2)])], [
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
                code([`class`([Class.pf.components.code(lang: "swift")])], [
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
