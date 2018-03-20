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

let episodeResponse =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >-> respond(episodeNotFoundView.contramap(lower))
    )
    <| writeStatus(.ok)
    >-> userEpisodePermission
    >-> map(lower)
    >>> respond(
      view: episodeView,
      layoutData: { permission, episode, currentUser, subscriptionStatus, currentRoute in
        let navStyle: NavStyle = currentUser == nil ? .mountains : .minimal(.light)

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: subscriptionStatus,
          currentUser: currentUser,
          data: (permission, currentUser, subscriptionStatus, episode),
          description: episode.blurb,
          extraStyles: markdownBlockStyles <> pricingExtraStyles,
          image: episode.image,
          navStyle: navStyle,
          title: "Episode #\(episode.sequence): \(episode.title)",
          usePrismJs: true
        )
    }
)

let useCreditResponse =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >-> respond(episodeNotFoundView.contramap(lower))
    )
    <<< { userEpisodePermission >-> $0 }
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <<< validateCreditRequest
    <| applyCreditMiddleware

private func applyCreditMiddleware<Z>(
  _ conn: Conn<StatusLineOpen, T4<EpisodePermission, Episode, Database.User, Z>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (episode, user) = (get2(conn.data), get3(conn.data))

  guard user.episodeCreditCount > 0 else {
    return conn
      |> redirect(
        to: .episode(.left(episode.slug)),
        headersMiddleware: flash(.error, "You do not have any credits to use.")
    )
  }

  return AppEnvironment.current.database.redeemEpisodeCredit(episode.sequence, user.id)
    .flatMap { _ in
      AppEnvironment.current.database.updateUser(user.id, nil, nil, nil, user.episodeCreditCount - 1)
    }
    .run
    .flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .episode(.left(episode.slug)),
              headersMiddleware: flash(.warning, "Something went wrong.")
          )
        ),
        const(
          conn
            |> redirect(
              to: .episode(.left(episode.slug)),
              headersMiddleware: flash(.notice, "You now have access to this episode!")
          )
        )
      )
  )
}

private func validateCreditRequest<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, Database.User, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, Database.User, Z>, Data> {

  return { conn in
    let (permission, episode, user) = (get1(conn.data), get2(conn.data), get3(conn.data))

    guard user.episodeCreditCount > 0 else {
      return conn
        |> redirect(
          to: .episode(.left(episode.slug)),
          headersMiddleware: flash(.error, "You do not have any credits to use.")
      )
    }

    guard isEpisodeViewable(for: permission) else {
      return middleware(conn)
    }

    return conn
      |> redirect(
        to: .episode(.left(episode.slug)),
        headersMiddleware: flash(.warning, "This episode is already available to you.")
    )
  }
}

private func userEpisodePermission<I, Z>(
  _ conn: Conn<I, T4<Episode, Database.User?, Stripe.Subscription.Status?, Z>>
  )
  -> IO<Conn<I, T5<EpisodePermission, Episode, Database.User?, Stripe.Subscription.Status?, Z>>> {

    let (episode, currentUser, subscriptionStatus) = (get1(conn.data), get2(conn.data), get3(conn.data))

    guard let user = currentUser else {
      let permission: EpisodePermission = .loggedOut(isSubscriberOnly: episode.subscriberOnly)
      return pure(conn.map(const(permission .*. conn.data)))
    }

    let hasCredit = AppEnvironment.current.database.fetchEpisodeCredits(user.id)
      .map { credits in credits.contains { $0.episodeSequence == episode.sequence } }
      .run
      .map { $0.right ?? false }

    let isSubscribed = subscriptionStatus == .some(.active)

    let permission = hasCredit
      .map { hasCredit -> EpisodePermission in
        switch (hasCredit, isSubscribed) {
        case (_, true):
          return .loggedIn(user: user, subscriptionPermission: .isSubscriber)
        case (true, false):
          return .loggedIn(user: user, subscriptionPermission: .isNotSubscriber(creditPermission: .isCredit))
        case (false, false):
          return .loggedIn(
            user: user,
            subscriptionPermission: .isNotSubscriber(
              creditPermission: .isNotCredit(isSubscriberOnly: episode.subscriberOnly)
            )
          )
        }
    }

    return permission
      .map { conn.map(const($0 .*. conn.data)) }
}

private let episodeView = View<(EpisodePermission, Database.User?, Stripe.Subscription.Status?, Episode)> {
  permission, user, subscriptionStatus, episode in

  [
    gridRow([
      gridColumn(sizes: [.mobile: 12], [`class`([Class.hide(.desktop)])], [
        div(episodeInfoView.view(episode))
        ])
      ]),

    gridRow([
      gridColumn(
        sizes: [.mobile: 12, .desktop: 7],
        leftColumnView.view((permission, user, subscriptionStatus, episode))
      ),

      gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        [`class`([Class.pf.colors.bg.purple150, Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        [
          div(
            [`class`([Class.position.sticky(.desktop), Class.position.top0])],
            rightColumnView.view(
              (episode, isEpisodeViewable(for: permission))
            )
          )
        ]
      )
      ]),

    script(
      """
      var hasPlayed = false;
      var video = document.getElementsByTagName('video')[0];
      video.addEventListener('play', function () {
        hasPlayed = true;
      });
      document.addEventListener('keypress', function (event) {
        if (hasPlayed && event.key === ' ') {
          if (video.paused) {
            video.play();
          } else {
            video.pause();
          }
          event.preventDefault();
        }
      });
      """
    )
  ]
}

private let downloadsAndHosts =
  downloadsView
    <> hostsView.contramap(const(unit))

private let rightColumnView = View<(Episode, Bool)> { episode, isEpisodeViewable in

  videoView.view((episode, isEpisodeViewable))
    <> episodeTocView.view((episode.transcriptBlocks, isEpisodeViewable))
    <> downloadsAndHosts.view(episode.codeSampleDirectory)
}

private let videoView = View<(Episode, isEpisodeViewable: Bool)> { episode, isEpisodeViewable in
  video(
    [
      `class`([Class.size.width100pct]),
      controls(true),
      playsinline(true),
      autoplay(true),
      poster(episode.image)
    ],
    isEpisodeViewable
      ? episode.sourcesFull.map { source(src: $0) }
      : episode.sourcesTrailer.map { source(src: $0) }
  )
}

private let episodeTocView = View<(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool)> { blocks, isEpisodeViewable in
  div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4]])])], [
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

private func timestampLinkAttributes(timestamp: Int, useAnchors: Bool) -> [Attribute<Element.A>] {

  return [
    useAnchors
      ? href("#t\(timestamp)")
      : href("#"),

    onclick(unsafeJavascript: """
      var video = document.getElementsByTagName("video")[0];
      video.currentTime = event.target.dataset.t;
      video.play();
      """
      + (useAnchors
        ? ""
        : "event.preventDefault();"
      )
    ),

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

private let tocChapterLinkView = View<(title: String, timestamp: Int, active: Bool)> { title, timestamp, active -> [Node] in
  if active {
    return
      [
        div([`class`([Class.hide(.mobile)])], [
          a(
            timestampLinkAttributes(timestamp: timestamp, useAnchors: true) +
              [`class`([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])],
            [text(title)]
          )
          ]),

        div([`class`([Class.hide(.desktop)])], [
          a(
            timestampLinkAttributes(timestamp: timestamp, useAnchors: false) +
              [`class`([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])],
            [text(title)]
          )
          ]),
    ]
  }

  return [
    div(
      [`class`([Class.pf.colors.fg.green, Class.pf.type.body.regular])],
      [text(title)]
    )
  ]
}

private let downloadsView = View<String> { codeSampleDirectory -> [Node] in
  guard !codeSampleDirectory.isEmpty else { return [] }

  return [
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
  ]
}

private let hostsView = View<Prelude.Unit> { _ in
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

private let leftColumnView = View<(EpisodePermission, Database.User?, Stripe.Subscription.Status?, Episode)> {
  permission, user, subscriptionStatus, episode in
  div(
    [div([`class`([Class.hide(.mobile)])], episodeInfoView.view(episode))]
      + dividerView.view(unit)
      + (
        isSubscribeBannerVisible(for: permission)
          ? subscribeView.view((permission, user, episode))
          : []
      )
      + (
        isEpisodeViewable(for: permission)
          ? transcriptView.view(episode.transcriptBlocks)
          : []
    )
  )
}

private func subscribeBlurb(for permission: EpisodePermission) -> StaticString {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    fatalError("This should never be called.")

  case .loggedIn(_, .isNotSubscriber(.isCredit)):
    return """
    You have access to this episode because you used a free episode credit. To get access to all past and
    future episodes, become a subscriber today!
    """

  case .loggedIn(_, .isNotSubscriber(.isNotCredit(isSubscriberOnly: true))):
    return """
    This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber
    today!
    """

  case .loggedIn(_, .isNotSubscriber(.isNotCredit(isSubscriberOnly: false))):
    return """
    This episode is free to all users. To get access to all past and future episodes, become a
    subscriber today!
    """

  case .loggedOut(isSubscriberOnly: true):
    return """
    This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber
    today!
    """

  case .loggedOut(isSubscriberOnly: false):
    return """
    This episode is free to all users. To get access to all past and future episodes, become a
    subscriber today!
    """
  }
}

private let creditBlurb = View<(EpisodePermission, Episode)> { permission, episode -> [Node] in
  guard
    case let .loggedIn(user, .isNotSubscriber(.isNotCredit(true))) = permission,
    user.episodeCreditCount > 0
    else { return [] }

  return [
    p(
      [
        `class`(
          [
            Class.pf.type.body.regular,
            Class.padding([.mobile: [.top: 4, .bottom: 2]])
          ]
        )
      ],
      [
        text("""
          You currently have \(pluralizedEpisodeCredits(count: user.episodeCreditCount)) available. Do you
          want to use it to view this episode for free right now?
          """)
      ]
    ),

    form(
      [action(path(to: .useEpisodeCredit(episode.id))), method(.post)],
      [
        input(
          [
            type(.submit),
            `class`(
              [
                Class.pf.components.button(color: .black, size: .small)
              ]
            ),
            value("Use an episode credit")
          ]
        )
      ]
    )
  ]
}

private func pluralizedEpisodeCredits(count: Int) -> String {
  return count == 1
    ? "1 episode credit"
    : "\(count) episode credits"
}

private let signUpBlurb = View<(EpisodePermission, Episode)> { permission, episode -> [Node] in
  guard case .loggedOut = permission else { return [] }

  return [
    p(
      [`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.top: 4, .bottom: 2]])])],
      [
        """
        Sign up for our weekly newsletter to be notified of new episodes, and unlock access to any
        subscriber-only episode of your choosing!
        """
      ]
    ),

    a(
      [
        href(path(to: .login(redirect: path(to: .episode(.left(episode.slug)))))),
        `class`([Class.pf.components.button(color: .black)])
      ],
      ["Sign up for free episode"]
    )
  ]
}

private let subscribeView = View<(EpisodePermission, Database.User?, Episode)> { permission, user, episode -> [Node] in
  [
    div(
      [
        `class`(
          [
            Class.type.align.center,
            Class.margin([.mobile: [.all: 3], .desktop: [.all: 4]]),
            Class.padding([.mobile: [.top: 1, .leftRight: 1, .bottom: 3], .desktop: [.top: 2, .leftRight: 2]]),
            Class.pf.colors.bg.gray900
          ]
        )
      ],
      [
        h3(
          [`class`([Class.pf.type.responsiveTitle4])],
          [.text(unsafeUnencodedString("Subscribe to Point&#8209;Free"))]
        ),

        p(
          [`class`([Class.pf.type.body.leading, Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
          [.text(encode(String(describing: subscribeBlurb(for: permission))))]
        ),

        a(
          [href(path(to: .pricing(nil, expand: nil))), `class`([Class.pf.components.button(color: .purple)])],
          ["See subscription options"]
        )
        ]
        <> loginLink.view((user, episode))
        <> creditBlurb.view((permission, episode))
        <> signUpBlurb.view((permission, episode))
    ),
    divider
  ]
}

private let loginLink = View<(Database.User?, Episode)> { user, ep -> [Node] in
  guard user == nil else { return [] }

  return [
    span([`class`([Class.padding([.mobile: [.left: 2]])])], ["or"]),
    a(
      [
        href(path(to: .login(redirect: url(to: .episode(.left(ep.slug)))))),
        `class`([Class.pf.components.button(color: .black, style: .underline)])
      ],
      ["Log in"]
    )
  ]
}

private let episodeInfoView = View<Episode> { ep in
  div(
    [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep)
  )
}

private func topLevelEpisodeMetadata(_ ep: Episode) -> String {
  return [
      "#\(ep.sequence)",
      episodeDateFormatter.string(from: ep.publishedAt),
      ep.subscriberOnly ? "Subscriber-only" : nil
    ]
    .flatMap { $0 }
    .joined(separator: " • ")
}

let topLevelEpisodeInfoView = View<Episode> { ep in
  [
    strong(
      [`class`([Class.pf.type.responsiveTitle8])],
      [text(topLevelEpisodeMetadata(ep))]
    ),
    h1(
      [`class`([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])],
      [a([href(path(to: .episode(.left(ep.slug))))], [text(ep.title)])]
    ),
    p([`class`([Class.pf.type.body.leading])], [text(ep.blurb)])
  ]
}

let divider = hr([`class`([Class.pf.components.divider])])
let dividerView = View<Prelude.Unit>(const(divider))

private let transcriptView = View<[Episode.TranscriptBlock]> { blocks in
  div(
    [
      `class`(
        [
          Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
          Class.pf.colors.bg.white
        ]
      )
    ],
    blocks.filter((!) <<< ^\.type.isExercise).flatMap(transcriptBlockView.view)
      <> exercisesView.view(blocks.filter(^\.type.isExercise))
  )
}

private let exercisesView = View<[Episode.TranscriptBlock]> { exercises -> [Node] in
  guard !exercises.isEmpty else { return [] }

  return [
    h2(
      [`class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])],
      ["Exercises"]
    ),
    ol(
      exercises.map { li(transcriptBlockView.view($0)) }
    )
  ]
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

  case .exercise:
    return div(
      timestampLinkView.view(block.timestamp)
        + [markdownBlock(block.content)]
    )

  case .paragraph:
    return div(
      timestampLinkView.view(block.timestamp)
        + [markdownBlock(block.content)]
    )

  case .title:
    return h2(
      [
        `class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])]),
        block.timestamp.map { id("t\($0)") }
        ]
        .flatMap { $0 },
      [
        a(block.timestamp.map { [href("#t\($0)")] } ?? [], [
          text(block.content)
          ])
      ]
    )
  }
}

private let timestampLinkView = View<Int?> { timestamp -> [Node] in
  guard let timestamp = timestamp else { return [] }

  return [
    div([id("t\(timestamp)"), `class`([Class.display.block])], [
      a(
        timestampLinkAttributes(timestamp: timestamp, useAnchors: false) + [
          `class`([Class.pf.components.videoTimeLink])
        ],
        [text(timestampLabel(for: timestamp))])
      ])
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
  return markdownBlock([], markdown)
}

func markdownBlock(_ attribs: [Attribute<Element.Div>] = [], _ markdown: String) -> Node {
  return div(addClasses([markdownContainerClass], to: attribs), [
    .text(unsafeUnencodedString(unsafeMark(from: markdown)))
    ])
}

func unsafeMark(from markdown: String) -> String {
  guard let cString = cmark_markdown_to_html(markdown, markdown.utf8.count, CMARK_OPT_SMART)
    else { return markdown }
  defer { free(cString) }
  return String(cString: cString)
}

private func isEpisodeViewable(
  _ permission: EpisodePermission,
  _ episode: Episode,
  _ subscriptionStatus: Stripe.Subscription.Status?
  ) -> Bool {

  return !episode.subscriberOnly || subscriptionStatus == .some(.active)
}

private func isEpisodeViewable(for permission: EpisodePermission) -> Bool {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    return true
  case .loggedIn(_, .isNotSubscriber(.isCredit)):
    return true
  case let .loggedIn(_, .isNotSubscriber(.isNotCredit(isSubscriberOnly))):
    return !isSubscriberOnly
  case let .loggedOut(isSubscriberOnly):
    return !isSubscriberOnly
  }
}

private func isSubscribeBannerVisible(for permission: EpisodePermission) -> Bool {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    return false
  case .loggedIn(_, _), .loggedOut(_):
    return true
  }
}

private enum EpisodePermission {
  case loggedIn(user: Database.User, subscriptionPermission: SubscriptionPermission)
  case loggedOut(isSubscriberOnly: Bool)

  enum SubscriptionPermission {
    case isSubscriber
    case isNotSubscriber(creditPermission: CreditPermission)

    enum CreditPermission {
      case isCredit
      case isNotCredit(isSubscriberOnly: Bool)
    }
  }
}

extension EpisodePermission: Equatable {
  static func == (lhs: EpisodePermission, rhs: EpisodePermission) -> Bool {
    switch (lhs, rhs) {
    case let (.loggedIn(lhsUser, lhsPermission), .loggedIn(rhsUser, rhsPermission)):
      return lhsUser.id.unwrap == rhsUser.id.unwrap && lhsPermission == rhsPermission
    case let (.loggedOut(lhs), .loggedOut(rhs)):
      return lhs == rhs
    case (.loggedIn, _), (.loggedOut, _):
      return false
    }
  }
}

extension EpisodePermission.SubscriptionPermission: Equatable {
  fileprivate static func == (lhs: EpisodePermission.SubscriptionPermission, rhs: EpisodePermission.SubscriptionPermission) -> Bool {
    switch (lhs, rhs) {
    case (.isSubscriber, .isSubscriber):
      return true
    case let (.isNotSubscriber(lhs), .isNotSubscriber(rhs)):
      return lhs == rhs
    case (.isSubscriber, _), (.isNotSubscriber, _):
      return false
    }
  }
}

extension EpisodePermission.SubscriptionPermission.CreditPermission: Equatable {
  fileprivate static func == (lhs: EpisodePermission.SubscriptionPermission.CreditPermission, rhs: EpisodePermission.SubscriptionPermission.CreditPermission) -> Bool {
    switch (lhs, rhs) {
    case (.isCredit, .isCredit):
      return true
    case let (.isNotCredit(lhs), .isNotCredit(rhs)):
      return lhs == rhs
    case (.isCredit, _), (.isNotCredit, _):
      return false
    }
  }
}
