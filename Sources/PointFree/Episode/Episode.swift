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
        [
          gridRow([
            gridColumn(
              sizes: [.xs: 12, .md: 7],
              leftColumnView.view(ctx.data)
            ),

            gridColumn(
              sizes: [.xs: 12, .md: 5],
              [`class`([Class.pf.colors.bg.dark, Class.grid.first(.xs), Class.grid.last(.md)])],
              [
                div(
                  [`class`([Class.position.sticky(.md), Class.position.top0])],
                  rightColumnView.view(ctx.data)
                )
              ]
            ),

            ])
          ]
          <> downloadsAndCredits.view((codeSampleDirectory: ctx.data.codeSampleDirectory, forDesktop: false))
          <> footerView.view(unit))
      ])
    ])
}

private let downloadsAndCredits = View<(codeSampleDirectory: String, forDesktop: Bool)> {

  div(
    [
      `class`([
        Class.pf.colors.bg.dark,
        $0.forDesktop ? Class.hide(.mobile) : Class.hide(.desktop)
        ])
    ],
    
    downloadsView.view($0.codeSampleDirectory)
      <> creditsView.view(unit)
  )
}

private let rightColumnView: View<Episode> =
  videoView.contramap(const(unit))
    <> episodeTocView.contramap(^\.transcriptBlocks)
    <> downloadsAndCredits.contramap({ ($0.codeSampleDirectory, forDesktop: true) })

private let videoView = View<Prelude.Unit> { _ in
  video(
    [
      `class`([Class.layout.fit]),
      controls(true),
      playsInline(true),
      autoplay(true),
      poster("https://d2sazdeahkz1yk.cloudfront.net/assets/W1siZiIsIjIwMTcvMDQvMjgvMDcvMzYvNTAvOTg2ZjI0N2UtZTU4YS00MTQzLTk4M2YtOGQxZDRiMDRkNGZhLzQ3IFZpZXcgTW9kZWxzIGF0IEtpY2tzdGFydGVyLmpwZyJdLFsicCIsInRodW1iIiwiMTkyMHgxMDgwIyJdXQ?sha=318940b4f059d474")
    ],
    [source(src: "https://www.videvo.net/videvo_files/converted/2017_08/videos/170724_15_Setangibeach.mp486212.mp4")]
  )
}

private let episodeTocView = View<[Episode.TranscriptBlock]> { blocks in
  div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .top: 4, .bottom: 0]])])],
    [
      h6(
        [`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
        ["Chapters"]
      ),
      ]
      <> blocks
        .filter { $0.type == .title && $0.timestamp != nil }
        .flatMap { block in
          tocChapterView.view((block.content, block.timestamp ?? 0))
    }
  )
}

private func timestampLinkAttributes(_ timestamp: Int) -> [Attribute<Element.A>] {
  return [
    href(""),

    onclick(javascript: """
    var video = document.getElementsByTagName("video")[0];
    video.currentTime = event.target.dataset.t;
    video.play();
    event.preventDefault();
    """),

    data("t", "\(timestamp)")
  ]
}

private let tocChapterView = View<(content: String, timestamp: Int)> { content, timestamp in
  gridRow([`class`([Class.margin([.mobile: [.bottom: 1]])])], [
    gridColumn(sizes: [.xs: 10], [
      div([
        a(
          timestampLinkAttributes(timestamp) + [
            `class`([Class.pf.colors.link.green, Class.type.textDecorationNone])
          ],
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
  div([`class`([Class.padding([.mobile: [.leftRight: 4, .top: 3]])])],
      [
        h6(
          [`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
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
            `class`([Class.pf.colors.link.yellow, Class.margin([.mobile: [.left: 1]]), Class.align.middle])
          ],
          [.text(encode("\(codeSampleDirectory).playground"))]
        )
    ]
  )
}

private let creditsView = View<Prelude.Unit> { _ in
  div([`class`([Class.padding([.mobile: [.leftRight: 4]]), Class.padding([.mobile: [.topBottom: 3]])])],
      [
        h6(
          [`class`([Class.pf.type.title6, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
          ["Credits"]
        ),
        p(
          [`class`([Class.pf.colors.fg.gray850])],
          [
            "Hosted by ",
            a(
              [`class`([Class.pf.colors.link.white]), mailto("brandon@pointfree.co")],
              ["Brandon Williams"]
            ),
            " and ",
            a([`class`([Class.pf.colors.link.white]), mailto("stephen@pointfree.co")], ["Stephen Celis"]),
            ". Recorded in Brooklyn, NY."
          ]
        )
    ]
  )
}

private func timestampLabel(for timestamp: Int) -> String {
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
    [`class`([Class.padding([.mobile: [.all: 4]]), Class.pf.colors.bg.white])],
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
      [`class`([Class.pf.type.title4, Class.margin([.mobile: [.top: 0]])])],
      [a([href(path(to: .episode(.left(ep.slug))))], [.text(encode(ep.title))])]
    ),
    p([`class`([Class.pf.type.body.regular])], [.text(encode(ep.blurb))]),
    ]
}

let dividerView = View<Prelude.Unit> { _ in
  hr([`class`([Class.pf.components.divider])])
}

private let transcriptView = View<[Episode.TranscriptBlock]> { blocks in
  div([`class`([Class.padding([.mobile: [.all: 4]]), Class.pf.colors.bg.white])],
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
        timestampLinkAttributes(block.timestamp ?? 0) + [
          `class`([Class.pf.components.videoTimeLink])
        ],
        [.text(encode(timestampLabel(for: block.timestamp ?? 0)))]
      ),
      .text(encode(block.content))
      ])

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])], [
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
            div([`class`([Class.padding([.mobile: [.all: 4]])])], [
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
