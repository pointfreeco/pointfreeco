import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import View
import Views

let episodeResponse =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> respond(episodeNotFoundView.contramap(lower))
    )
    <| writeStatus(.ok)
    >=> userEpisodePermission
    >=> map(lower)
    >>> respond(
      view: episodeView,
      layoutData: { permission, episode, currentUser, subscriberState, currentRoute in
        let navStyle: NavStyle = currentUser == nil ? .mountains(.main) : .minimal(.light)

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (permission, currentUser, subscriberState, episode),
          description: episode.blurb,
          extraHead: videoJsHead,
          extraStyles: markdownBlockStyles <> pricingExtraStyles,
          image: episode.image,
          style: .base(navStyle),
          title: "Episode #\(episode.sequence): \(episode.title)",
          usePrismJs: true
        )
    }
)

let useCreditResponse =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> respond(episodeNotFoundView.contramap(lower))
    )
    <<< { userEpisodePermission >=> $0 }
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <<< validateCreditRequest
    <| applyCreditMiddleware

private func applyCreditMiddleware<Z>(
  _ conn: Conn<StatusLineOpen, T4<EpisodePermission, Episode, User, Z>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (episode, user) = (get2(conn.data), get3(conn.data))

  guard user.episodeCreditCount > 0 else {
    return conn
      |> redirect(
        to: .episode(.left(episode.slug)),
        headersMiddleware: flash(.error, "You do not have any credits to use.")
    )
  }

  return Current.database.redeemEpisodeCredit(episode.sequence, user.id)
    .flatMap { _ in
      Current.database.updateUser(user.id, nil, nil, nil, user.episodeCreditCount - 1)
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
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, User, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, User, Z>, Data> {

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
  _ conn: Conn<I, T4<Episode, User?, SubscriberState, Z>>
  )
  -> IO<Conn<I, T5<EpisodePermission, Episode, User?, SubscriberState, Z>>> {

    let (episode, currentUser, subscriberState) = (get1(conn.data), get2(conn.data), get3(conn.data))

    guard let user = currentUser else {
      let permission: EpisodePermission = .loggedOut(isEpisodeSubscriberOnly: episode.subscriberOnly)
      return pure(conn.map(const(permission .*. conn.data)))
    }

    let hasCredit = Current.database.fetchEpisodeCredits(user.id)
      .map { credits in credits.contains { $0.episodeSequence == episode.sequence } }
      .run
      .map { $0.right ?? false }

    let permission = hasCredit
      .map { hasCredit -> EpisodePermission in
        switch (hasCredit, subscriberState.isActiveSubscriber) {
        case (_, true):
          return .loggedIn(user: user, subscriptionPermission: .isSubscriber)
        case (true, false):
          return .loggedIn(user: user, subscriptionPermission: .isNotSubscriber(creditPermission: .hasUsedCredit))
        case (false, false):
          return .loggedIn(
            user: user,
            subscriptionPermission: .isNotSubscriber(
              creditPermission: .hasNotUsedCredit(isEpisodeSubscriberOnly: episode.subscriberOnly)
            )
          )
        }
    }

    return permission
      .map { conn.map(const($0 .*. conn.data)) }
}

private let episodeView = View<(EpisodePermission, User?, SubscriberState, Episode)> {
  permission, user, subscriberState, episode in

  [
    gridRow([
      gridColumn(sizes: [.mobile: 12], [`class`([Class.hide(.desktop)])], [
        div(episodeInfoView.view((permission, episode)))
        ])
      ]),

    gridRow([
      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        leftColumnView.view((permission, user, subscriberState, episode))
      ),

      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
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

private let rightColumnView = View<(Episode, Bool)> { episode, isEpisodeViewable in

  [videoView(forEpisode: episode, isEpisodeViewable: isEpisodeViewable)]
    <> episodeTocView.view((episode.transcriptBlocks, isEpisodeViewable))
    <> downloadsView.view(episode.codeSampleDirectory)
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

private let tocChapterView = View<(title: String, timestamp: Int, isEpisodeViewable: Bool)> { title, timestamp, isEpisodeViewable in
  gridRow([
    gridColumn(sizes: [.mobile: 10], [
      div(tocChapterLinkView.view((title, timestamp, isEpisodeViewable)))
      ]),

    gridColumn(sizes: [.mobile: 2], [
      div(
        [`class`([Class.pf.colors.fg.purple, Class.type.align.end, Class.pf.opacity75])],
        [.text(timestampLabel(for: timestamp))]
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
            [.text(title)]
          )
          ]),

        div([`class`([Class.hide(.desktop)])], [
          a(
            timestampLinkAttributes(timestamp: timestamp, useAnchors: false) +
              [`class`([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])],
            [.text(title)]
          )
          ]),
    ]
  }

  return [
    div(
      [`class`([Class.pf.colors.fg.green, Class.pf.type.body.regular])],
      [.text(title)]
    )
  ]
}

private let downloadsView = View<String> { codeSampleDirectory -> [Node] in
  guard !codeSampleDirectory.isEmpty else { return [] }

  return [
    div([`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]]), Class.padding([.mobile: [.bottom: 3]])])],
        [
          h6(
            [`class`([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
            ["Downloads"]
          ),
          img(
            base64: gitHubSvgBase64(fill: "#FFF080"),
            type: .image(.svg),
            alt: "",
            [`class`([Class.align.middle]), width(20), height(20)]
          ),
          a(
            [
              href(gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: codeSampleDirectory))),
              `class`([Class.pf.colors.link.yellow, Class.margin([.mobile: [.left: 1]]), Class.align.middle])
            ],
            [.text("\(codeSampleDirectory).playground")]
          )
      ]
    )
  ]
}

private let leftColumnView = View<(EpisodePermission, User?, SubscriberState, Episode)> {
  permission, user, subscriberState, episode -> Node in

  let subscribeNodes = isSubscribeBannerVisible(for: permission)
    ? subscribeView.view((permission, user, episode))
    : []
  let transcriptNodes = transcriptView.view((episode.transcriptBlocks, isEpisodeViewable(for: permission)))

  return div(
    [div([`class`([Class.hide(.mobile)])], episodeInfoView.view((permission, episode)))]
      + dividerView.view(unit)
      + subscribeNodes
      + transcriptNodes
      + exercisesView.view(episode.exercises)
      + referencesView.view(episode.references)
  )
}

private func subscribeBlurb(for permission: EpisodePermission) -> StaticString {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    fatalError("This should never be called.")

  case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
    return """
    You have access to this episode because you used a free episode credit. To get access to all past and
    future episodes, become a subscriber today!
    """

  case .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true))):
    return """
    This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber
    today!
    """

  case .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: false))):
    return """
    This episode is free to all users. To get access to all past and future episodes, become a
    subscriber today!
    """

  case .loggedOut(isEpisodeSubscriberOnly: true):
    return """
    This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber
    today!
    """

  case .loggedOut(isEpisodeSubscriberOnly: false):
    return """
    This episode is free to all users. To get access to all past and future episodes, become a
    subscriber today!
    """
  }
}

let useCreditCTA = "Use an episode credit"

private let creditBlurb = View<(EpisodePermission, Episode)> { permission, episode -> [Node] in
  guard
    case let .loggedIn(user, .isNotSubscriber(.hasNotUsedCredit(true))) = permission,
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
        .text("""
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
            `class`([Class.pf.components.button(color: .black, size: .small)]),
            value(useCreditCTA)
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

private let subscribeView = View<(EpisodePermission, User?, Episode)> { permission, user, episode -> [Node] in
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
          [.raw("Subscribe to Point&#8209;Free")]
        ),

        p(
          [`class`([Class.pf.type.body.leading, Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
          [.text(String(describing: subscribeBlurb(for: permission)))]
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

private let loginLink = View<(User?, Episode)> { user, ep -> [Node] in
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

private let episodeInfoView = View<(EpisodePermission, Episode)> { permission, ep in
  div(
    [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep)
    + sectionsMenu(episode: ep, permission: permission)
  )
}

private func topLevelEpisodeMetadata(_ ep: Episode) -> String {
  let components: [String?] = [
    "#\(ep.sequence)",
    episodeDateFormatter.string(from: ep.publishedAt),
    ep.subscriberOnly ? "Subscriber-only" : "Free Episode"
  ]

  return components
    .compactMap { $0 }
    .joined(separator: " • ")
}

let topLevelEpisodeInfoView = View<Episode> { ep in
  [
    strong(
      [`class`([Class.pf.type.responsiveTitle8])],
      [.text(topLevelEpisodeMetadata(ep))]
    ),
    h1(
      [`class`([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])],
      [a([href(path(to: .episode(.left(ep.slug))))], [.text(ep.title)])]
    ),
    div([`class`([Class.pf.type.body.leading])], [markdownBlock(ep.blurb)])
    ]
}

private func sectionsMenu(episode: Episode, permission: EpisodePermission?) -> [Node] {
  guard let permission = permission, isEpisodeViewable(for: permission) else { return [] }

  let exercisesNode: Node? = episode.exercises.isEmpty
    ? nil
    : a([`class`([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), href("#exercises")],
        ["Exercises"])

  let referencesNode: Node? = episode.references.isEmpty
    ? nil
    : a([`class`([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), href("#references")],
        ["References"])

  // Don't show quick link menu if at least one of exercises or references are present.
  guard exercisesNode != nil || referencesNode != nil else { return [] }

  return [
    div(
      [`class`([Class.padding([.mobile: [.top: 2], .desktop: [.top: 3]])])],
      [
        a(
          [`class`([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), href("#transcript")],
          ["Transcript"]
        ),
        exercisesNode,
        referencesNode
        ]
        .compactMap(id)
    )
  ]
}

let divider = hr([`class`([Class.pf.components.divider])])
let dividerView = View<Prelude.Unit>(const(divider))

private let transcriptView = View<([Episode.TranscriptBlock], Bool)> { blocks, isEpisodeViewable in
  div(
    [
      id("transcript"),
      `class`(
        [
          Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
          Class.pf.colors.bg.white
        ]
      )
    ],
    transcript(blocks: blocks, isEpisodeViewable: isEpisodeViewable)
  )
}

private func transcript(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool) -> [Node] {
  struct State { var nodes: [Node] = [], titleCount = 0 }

  return blocks
    .reduce(into: State()) { state, block in
      if case .title = block.type { state.titleCount += 1 }
      state.nodes += state.titleCount <= 1 || isEpisodeViewable
        ? transcriptBlockView.view(block)
        : []
    }
    .nodes + subscriberCalloutView(isEpisodeViewable: isEpisodeViewable)
}

private func subscriberCalloutView(isEpisodeViewable: Bool) -> [Node] {
  guard !isEpisodeViewable else { return [] }

  return [
    gridRow([
      gridColumn(
        sizes: [.mobile: 12],
        [style(margin(leftRight: .auto))],
        [
          div(
            [
              `class`(
                [
                  Class.margin([.mobile: [.top: 4]]),
                  Class.padding([.mobile: [.all: 3]]),
                  Class.pf.colors.bg.gray900
                ]
              )
            ],
            [
              h4(
                [
                  `class`(
                    [
                      Class.pf.type.responsiveTitle4,
                      Class.padding([.mobile: [.bottom: 2]])
                    ]
                  )
                ],
                ["Subscribe to Point-Free"]
              ),
              p(
                [
                  "👋 Hey there! Does this episode sound interesting? Well, then you may want to ",
                  a(
                    [
                      href(path(to: .pricing(nil, expand: nil))),
                      `class`([Class.pf.type.underlineLink])
                    ],
                    ["subscribe"]
                  ),
                  " so that you get access to this episodes and more!",
                  ]
              )
            ]
          )
        ]
      )
      ])
  ]
}

private let referencesView = View<[Episode.Reference]> { references -> [Node] in
  guard !references.isEmpty else { return [] }

  return dividerView.view(unit) + [
    div(
      [
        `class`(
          [
            Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
            Class.pf.colors.bg.white
          ]
        )
      ],
      [
        h2(
          [
            id("references"),
            `class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])
          ],
          ["References"]
        ),
        ul(
          zip(1..., references).map { idx, reference in
            li(
              [
                id("reference-\(idx)"),
                `class`([Class.margin([.mobile: [.bottom: 3]])])
              ],
              [
                h4(
                  [`class`([
                    Class.pf.type.responsiveTitle5,
                    Class.margin([.mobile: [.bottom: 0]])
                    ])],
                  [
                    a(
                      [
                        href(reference.link),
                        target(.blank),
                        rel(.init(rawValue: "noopener noreferrer"))
                      ],
                      [.text(reference.title)]
                    )
                  ]
                ),
                strong(
                  [`class`([Class.pf.type.body.small])],
                  [.text(topLevelReferenceMetadata(reference))]
                ),
                div([markdownBlock(reference.blurb ?? "")]),
                div(
                  [
                    a(
                      [
                        href(reference.link),
                        `class`([Class.pf.colors.link.purple]),
                        target(.blank),
                        rel(.init(rawValue: "noopener noreferrer"))
                      ],
                      [
                        img(
                          base64: newWindowSvgBase64(fill: "#974DFF"),
                          type: .image(.svg),
                          alt: "",
                          [
                            `class`([
                              Class.align.middle,
                              Class.margin([.mobile: [.right: 1]])
                              ]),
                            width(14),
                            height(14),
                            style(margin(top: .px(-2)))
                          ]
                        ),
                        .text(reference.link)
                      ]
                    )
                  ]
                )
              ]
            )
          }
        )
      ]
    )
  ]
}

private func topLevelReferenceMetadata(_ reference: Episode.Reference) -> String {
  return [
    reference.author,
    reference.publishedAt.map(episodeDateFormatter.string(from:))
    ]
    .compactMap(id)
    .joined(separator: " • ")
}

private let exercisesView = View<[Episode.Exercise]> { exercises -> [Node] in
  guard !exercises.isEmpty else { return [] }

  return dividerView.view(unit) + [
    div(
      [
        `class`(
          [
            Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
            Class.pf.colors.bg.white
          ]
        )
      ],
      [
        h2(
          [
            id("exercises"),
            `class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])
          ],
          ["Exercises"]
        ),
        ol(zip(1..., exercises).map(exercise(idx:exercise:)))
      ]
    )
  ]
}

private func exercise(idx: Int, exercise: Episode.Exercise) -> ChildOf<Tag.Ol> {
  return li(
    [Html.id("exercise-\(idx)")],
    [
      div(
        [markdownBlock(exercise.problem)]
          + solution(to: exercise)
      )
    ]
  )
}

private func solution(to exercise: Episode.Exercise) -> [Node] {
  guard let solution = exercise.solution else { return [] }

  return [
    details([
      summary(["Solution"]).rawValue, // todo: update details to take children of details
      div(
        [
          `class`([
            Class.pf.colors.bg.gray900,
            Class.padding([.mobile: [.topBottom: 1, .leftRight: 2]]),
            Class.margin([.mobile: [.bottom: 3]]),
            Class.layout.overflowAuto(.x)
            ])
        ],
        [markdownBlock(solution)]
      )
      ])
  ]
}

private let episodeNotFoundView = simplePageLayout(_episodeNotFoundView)
  .contramap { param, user, subscriberState, route in
    SimplePageLayoutData(
      currentSubscriberState: subscriberState,
      currentUser: user,
      data: (param, user, subscriberState, route),
      title: "Episode not found :("
    )
}

private let _episodeNotFoundView = View<(Either<String, Episode.Id>, User?, SubscriberState, Route?)> { _, _, _, _ in

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

private func episode(forParam param: Either<String, Episode.Id>) -> Episode? {
  return Current.episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id)
    })
}


private func isEpisodeViewable(for permission: EpisodePermission) -> Bool {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    return true
  case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
    return true
  case let .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isSubscriberOnly))):
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

private enum EpisodePermission: Equatable {
  case loggedIn(user: User, subscriptionPermission: SubscriberPermission)
  case loggedOut(isEpisodeSubscriberOnly: Bool)

  enum SubscriberPermission: Equatable {
    case isNotSubscriber(creditPermission: CreditPermission)
    case isSubscriber

    enum CreditPermission: Equatable {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit
    }
  }
}
