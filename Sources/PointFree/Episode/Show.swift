import Ccmark
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
import Tuple

let episodeResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple4<Either<String, Int>, Database.User?, Stripe.Subscription.Status?, Route?>, Data> =

  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >-> respond(episodeNotFoundView.contramap(lower))
    )
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: episodeView,
      layoutData: { episode, currentUser, subscriptionStatus, currentRoute in
        let isEpisodeViewable = !episode.subscriberOnly || subscriptionStatus == .some(.active)
        let navStyle: NavStyle = currentUser == nil ? .mountains : .minimal(.light)

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: subscriptionStatus,
          currentUser: currentUser,
          data: (episode, isEpisodeViewable),
          extraStyles: markdownBlockStyles <> pricingExtraStyles,
          navStyle: navStyle,
          title: "Episode #\(episode.sequence): \(episode.title)",
          useHighlightJs: true
        )
    }
)

let episodeView = View<(Episode, isEpisodeViewable: Bool)> { episode, isEpisodeViewable in
  [
    gridRow([
      gridColumn(sizes: [.mobile: 12], [`class`([Class.hide(.desktop)])], [
        div(episodeInfoView.view(episode))
        ])
      ]),

    gridRow([
      gridColumn(
        sizes: [.mobile: 12, .desktop: 7],
        leftColumnView.view((episode, isEpisodeViewable))
      ),

      gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        [`class`([Class.pf.colors.bg.purple150, Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        [
          div(
            [`class`([Class.position.sticky(.desktop), Class.position.top0])],
            rightColumnView.view((episode, isEpisodeViewable))
          )
        ]
      )
      ])
  ]
}

private let downloadsAndCredits =
  downloadsView
    <> creditsView.contramap(const(unit))

private let rightColumnView = View<(Episode, isEpisodeViewable: Bool)> { episode, isEpisodeViewable in

  videoView.view(unit)
    <> episodeTocView.view((episode.transcriptBlocks, isEpisodeViewable))
    <> downloadsAndCredits.view(episode.codeSampleDirectory)
}

private let videoView = View<Prelude.Unit> { _ in
  video(
    [
      `class`([Class.size.width100pct]),
      controls(true),
      playsInline(true),
      autoplay(true),
      poster("")
    ],
    [source(src: "https://www.videvo.net/videvo_files/converted/2017_08/videos/170724_15_Setangibeach.mp486212.mp4")]
  )
}

private let episodeTocView = View<(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool)> { blocks, isEpisodeViewable in
  div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .top: 4]])])], [
    h6(
      [`class`([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
      ["Chapters"]
    ),
    ]
    <> blocks
      .filter { $0.type == .title && $0.timestamp != nil }
      .flatMap { block in
        tocChapterView.view((block.content, block.timestamp ?? 0, isEpisodeViewable))
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

private let tocChapterView = View<(title: String, timestamp: Int, isEpisodeViewable: Bool)> { title, timestamp, isEpisodeViewable in
  gridRow([
    gridColumn(sizes: [.mobile: 10], [
      div(tocChapterLinkView.view((title, timestamp, isEpisodeViewable)))
      ]),

    gridColumn(sizes: [.mobile: 2], [
      div(
        [`class`([Class.pf.colors.fg.purple, Class.type.align.end, Class.pf.opacity75])],
        [text(timestampLabel(for: timestamp))]
      )
      ])
    ])
}

private let tocChapterLinkView = View<(title: String, timestamp: Int, active: Bool)> { title, timestamp, active -> Node in
  if active {
    return a(
      timestampLinkAttributes(timestamp) +
        [`class`([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])],
      [text(title)]
    )
  }

  return div(
    [`class`([Class.pf.colors.fg.green, Class.pf.type.body.regular])],
    [text(title)]
    )
}

private let downloadsView = View<String> { codeSampleDirectory in
  div([`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      [
        h6(
          [`class`([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
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
  div([`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]]), Class.padding([.mobile: [.topBottom: 3]])])],
      [
        h6(
          [`class`([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
          ["Credits"]
        ),
        p(
          [`class`([Class.pf.colors.fg.gray850])],
          [
            "Hosted by ",
            a(
              [`class`([Class.pf.colors.link.white]), mailto("brandon@pointfree.co")],
              [.text(unsafeUnencodedString("Brandon&nbsp;Williams"))]
            ),
            " and ",
            a(
              [`class`([Class.pf.colors.link.white]), mailto("stephen@pointfree.co")],
              [.text(unsafeUnencodedString("Stephen&nbsp;Celis"))]
            ),
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

private let leftColumnView = View<(Episode, isEpisodeViewable: Bool)> { episode, isEpisodeViewable in
  div(
    [div([`class`([Class.hide(.mobile)])], episodeInfoView.view(episode))]
      + dividerView.view(unit)
      + (isEpisodeViewable
        ? transcriptView.view(episode.transcriptBlocks)
        : subscribeView.view(episode)
    )
  )
}

private let subscribeView = View<Episode> { episode in
  div([`class`([Class.type.align.center, Class.margin([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.gray900])], [

    h3(
      [`class`([Class.pf.type.responsiveTitle4])],
      [.text(unsafeUnencodedString("Subscribe to Point&#8209;Free"))]
    ),

    p(
      [`class`([Class.pf.type.body.leading, Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
      ["Unlock full episodes and explore a new functional programming concept each week."]
    ),

    a(
      [href(path(to: .pricing(nil, nil))), `class`([Class.pf.components.button(color: .purple)])],
      ["See subscription options"]
    ),
    span([`class`([Class.padding([.mobile: [.left: 2]])])], ["or"]),
    a(
      [
        href(path(to: .login(redirect: url(to: .episode(.left(episode.slug)))))),
        `class`([Class.pf.components.button(color: .black, style: .underline)])
      ],
      ["Log in"]
    )
    ])
}

private let episodeInfoView = View<Episode> { ep in
  div(
    [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep)
  )
}

let topLevelEpisodeInfoView = View<Episode> { ep in
  [
    strong(
      [`class`([Class.pf.type.responsiveTitle8])],
      [text(episodeDateFormatter.string(from: ep.publishedAt))]
    ),
    h1(
      [`class`([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])],
      [a([href(path(to: .episode(.left(ep.slug))))], [text(ep.title)])]
    ),
    p([`class`([Class.pf.type.body.leading])], [text(ep.blurb)])
  ]
}

let dividerView = View<Prelude.Unit> { _ in
  hr([`class`([Class.pf.components.divider])])
}

private let transcriptView = View<[Episode.TranscriptBlock]> { blocks in
  div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
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
    return div(
      timestampLinkView.view(block.timestamp)
        + [markdownBlock(block.content)]
    )

  case .title:
    return h2([`class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])], [
      .text(encode(block.content))
      ])
  }
}

private let timestampLinkView = View<Int?> { timestamp -> [Node] in
  guard let timestamp = timestamp else { return [] }

  return  [
    a(
      timestampLinkAttributes(timestamp) + [
        `class`([Class.pf.components.videoTimeLink, Class.layout.left, Class.type.lineHeight(1)])
      ],
      [.text(encode(timestampLabel(for: timestamp)))]
    )
  ]
}

private let episodeNotFoundView = simplePageLayout(_episodeNotFoundView)
  .contramap { param, user, subscriptionStatus, route in
    SimplePageLayoutData(
      currentSubscriptionStatus: subscriptionStatus,
      currentUser: user,
      data: (param, user, subscriptionStatus, route),
      title: "Episode not found :("
    )
}

private let _episodeNotFoundView = View<(Either<String, Int>, Database.User?, Stripe.Subscription.Status?, Route?)> { _, _, _, _ in

  gridRow([`class`([Class.grid.center(.mobile)])], [
    gridColumn(sizes: [.mobile: 6], [
      div([style(padding(topBottom: .rem(12)))], [
        h5([`class`([Class.h5])], ["Episode not found :("]),
        pre([
          code([`class`([Class.pf.components.code(lang: "swift")])], [
            "f: (Episode) -> Never"
            ])
          ])
        ])
      ])
    ])
}

private func episode(forParam param: Either<String, Int>) -> Episode? {
  return AppEnvironment.current.episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id.unwrap)
    })
}

private let markdownContainerClass = CssSelector.class("md-ctn")
let markdownBlockStyles: Stylesheet =
  markdownContainerClass % (
    a % key("text-decoration", "underline")
      <> (a & .pseudo(.link)) % color(Colors.purple150)
      <> (a & .pseudo(.visited)) % color(Colors.purple150)
      <> (a & .pseudo(.hover)) % color(Colors.black)
      <> code % (
        fontFamily(["monospace"])
          <> padding(topBottom: .px(1), leftRight: .px(5))
          <> borderWidth(all: .px(1))
          <> borderRadius(all: .px(3))
          <> backgroundColor(Color.other("#f7f7f7"))
    )
)

func markdownBlock(_ markdown: String) -> Node {
  return div([`class`([markdownContainerClass])], [
    .text(unsafeUnencodedString(unsafeMark(from: markdown)))
    ])
}

func markdownBlock(_ attribs: [Attribute<Element.Div>] = [], _ markdown: String) -> Node {
  return div(addClasses([markdownContainerClass], to: attribs), [
    .text(unsafeUnencodedString(unsafeMark(from: markdown)))
    ])
}

private func unsafeMark(from markdown: String) -> String {
  guard let cString = cmark_markdown_to_html(markdown, markdown.utf8.count, 0)
    else { return markdown }
  defer { free(cString) }
  return String(cString: cString)
}
