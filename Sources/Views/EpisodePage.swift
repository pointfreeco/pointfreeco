import Css
import FunctionalCss
import Either
import Foundation
import HtmlUpgrade
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func episodeView(
  permission: EpisodePermission,
  user: User?,
  subscriberState: SubscriberState,
  episode: Episode,
  date: () -> Date
  ) -> Node {

  return [
    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [.class([Class.hide(.desktop)])],
        .div(episodeInfoView(permission: permission, ep: episode, date: date))
      )
    ),

    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        leftColumnView(
          permission: permission,
          user: user,
          subscriberState: subscriberState,
          episode: episode,
          date: date
        )
      ),

      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        attributes: [.class([Class.pf.colors.bg.purple150, Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        [
          .div(
            attributes: [.class([Class.position.sticky(.desktop), Class.position.top0])],
            rightColumnView(
              episode: episode, isEpisodeViewable: isEpisodeViewable(for: permission)
            )
          )
        ]
      )
    )
  ]
}

private func rightColumnView(episode: Episode, isEpisodeViewable: Bool) -> Node {
  return [
    upgrade(node: videoView(forEpisode: episode, isEpisodeViewable: isEpisodeViewable)),
    episodeTocView(blocks: episode.transcriptBlocks, isEpisodeViewable: isEpisodeViewable),
    downloadsView(codeSampleDirectory: episode.codeSampleDirectory)
  ]
}

private func episodeTocView(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool) -> Node {
  return [
    .div(
      attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4]])])],
      .h6(
        attributes: [.class([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
        "Chapters"
      ),
      .fragment(
        blocks
          .filter { $0.type == .title && $0.timestamp != nil }
          .map { block in
            tocChapterView(title: block.content, timestamp: block.timestamp ?? 0, isEpisodeViewable: isEpisodeViewable)
        }
      )
    )
  ]
}

private func tocChapterView(title: String, timestamp: Int, isEpisodeViewable: Bool) -> Node {
  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 10],
      .div(tocChapterLinkView(title: title, timestamp: timestamp, active: isEpisodeViewable))
    ),

    .gridColumn(
      sizes: [.mobile: 2],
      .div(
        attributes: [.class([Class.pf.colors.fg.purple, Class.type.align.end, Class.pf.opacity75])],
        .text(timestampLabel(for: timestamp))
      )
    )
  )
}

private func tocChapterLinkView(title: String, timestamp: Int, active: Bool) -> Node {
  if active {
    return [
      .div(
        attributes: [.class([Class.hide(.mobile)])],
        .a(
          attributes: [ // TODO: timestampLinkAttributes(timestamp: timestamp) +
            .href("#t\(timestamp)"),
            .class([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])
          ],
          .text(title)
        )
      ),

      .div(
        attributes: [.class([Class.hide(.desktop)])],
        .a(
          attributes: [ // TODO: timestampLinkAttributes(timestamp: timestamp) +
            .href("#t\(timestamp)"),
            .class([Class.pf.colors.link.green, Class.type.textDecorationNone, Class.pf.type.body.regular])
          ],
          .text(title)
        )
      ),
    ]
  }

  return .div(
    attributes: [.class([Class.pf.colors.fg.green, Class.pf.type.body.regular])],
    .text(title)
  )
}

private func downloadsView(codeSampleDirectory: String) -> Node {
  guard !codeSampleDirectory.isEmpty else { return [] }

  return .div(
    attributes: [.class([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]]), Class.padding([.mobile: [.bottom: 3]])])],
    .h6(
      attributes: [.class([Class.pf.type.responsiveTitle8, Class.pf.colors.fg.gray850, Class.padding([.mobile: [.bottom: 1]])])],
      "Downloads"
    ),
    .img(
      base64: gitHubSvgBase64(fill: "#FFF080"),
      type: .image(.svg),
      alt: "",
      attributes: [.class([Class.align.middle]), .width(20), .height(20)]
    ),
    .a(
      attributes: [
        .href(gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: codeSampleDirectory))),
        .class([Class.pf.colors.link.yellow, Class.margin([.mobile: [.left: 1]]), Class.align.middle])
      ],
      .text("\(codeSampleDirectory).playground")
    )
  )
}

private func leftColumnView(
  permission: EpisodePermission,
  user: User?,
  subscriberState: SubscriberState,
  episode: Episode,
  date: () -> Date
  ) -> Node {

  let subscribeNodes = isSubscribeBannerVisible(for: permission)
    ? subscribeView(permission: permission, user: user, episode: episode)
    : []
  let transcriptNodes = transcriptView(blocks: episode.transcriptBlocks, isEpisodeViewable: isEpisodeViewable(for: permission))

  return [
    .div(
      attributes: [.class([Class.hide(.mobile)])],
      episodeInfoView(permission: permission, ep: episode, date: date)
    ),
    divider,
    subscribeNodes,
    transcriptNodes,
    exercisesView(exercises: episode.exercises),
    referencesView(references: episode.references)
  ]
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

private func creditBlurb(permission: EpisodePermission, episode: Episode) -> Node {
  guard
    case let .loggedIn(user, .isNotSubscriber(.hasNotUsedCredit(true))) = permission,
    user.episodeCreditCount > 0
    else { return [] }

  return [
    .p(
      attributes: [
        .class(
          [
            Class.pf.type.body.regular,
            Class.padding([.mobile: [.top: 4, .bottom: 2]])
          ]
        )
      ],
      .text("""
        You currently have \(pluralizedEpisodeCredits(count: user.episodeCreditCount)) available. Do you
        want to use it to view this episode for free right now?
        """)
    ),

    .form(
      attributes: [.action(path(to: .useEpisodeCredit(episode.id))), .method(.post)],
      .input(
        attributes: [
          .type(.submit),
          .class([Class.pf.components.button(color: .black, size: .small)]),
          .value(useCreditCTA)
        ]
      )
    )
  ]
}

private func pluralizedEpisodeCredits(count: Int) -> String {
  return count == 1
    ? "1 episode credit"
    : "\(count) episode credits"
}

private func signUpBlurb(permission: EpisodePermission, episode: Episode) -> Node {
  guard case .loggedOut = permission else { return [] }

  return [
    .p(
      attributes: [.class([Class.pf.type.body.regular, Class.padding([.mobile: [.top: 4, .bottom: 2]])])],
      """
        Sign up for our weekly newsletter to be notified of new episodes, and unlock access to any
        subscriber-only episode of your choosing!
        """
    ),

    .a(
      attributes: [
        .href(path(to: .login(redirect: path(to: .episode(.left(episode.slug)))))),
        .class([Class.pf.components.button(color: .black)])
      ],
      "Sign up for free episode"
    )
  ]
}

private func subscribeView(permission: EpisodePermission, user: User?, episode: Episode) -> Node {
  return [
    .div(
      attributes: [
        .class(
          [
            Class.type.align.center,
            Class.margin([.mobile: [.all: 3], .desktop: [.all: 4]]),
            Class.padding([.mobile: [.top: 1, .leftRight: 1, .bottom: 3], .desktop: [.top: 2, .leftRight: 2]]),
            Class.pf.colors.bg.gray900
          ]
        )
      ],
      .h3(
        attributes: [.class([Class.pf.type.responsiveTitle4])],
        .raw("Subscribe to Point&#8209;Free")
      ),
      .p(
        attributes: [.class([Class.pf.type.body.leading, Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
        .text(String(describing: subscribeBlurb(for: permission)))
      ),
      .a(
        attributes: [.href(path(to: .pricingLanding)), .class([Class.pf.components.button(color: .purple)])],
        "See subscription options"
      ),
      loginLink(user: user, ep: episode),
      creditBlurb(permission: permission, episode: episode),
      signUpBlurb(permission: permission, episode: episode),
    ),
    divider
  ]
}

private func loginLink(user: User?, ep: Episode) -> Node {
  guard user == nil else { return [] }

  return [
    .span(attributes: [.class([Class.padding([.mobile: [.left: 2]])])], "or"),
    .a(
      attributes: [
        .href(path(to: .login(redirect: url(to: .episode(.left(ep.slug)))))),
        .class([Class.pf.components.button(color: .black, style: .underline)])
      ],
      "Log in"
    )
  ]
}

private func episodeInfoView(
  permission: EpisodePermission,
  ep: Episode,
  date: () -> Date
  ) -> Node {
  return .div(
    attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView(episode: ep, date: date),
    previousEpisodes(of: ep),
    sectionsMenu(episode: ep, permission: permission)
  )
}

private func previousEpisodes(of ep: Episode) -> Node {
  let previousEps: [Episode] = [] // TODO: = ep.previousEpisodes
  guard !previousEps.isEmpty else { return [] }

  return [
    .p(
      attributes: [.class([Class.padding([.mobile: [.top: 1], .desktop: [.top: 1]]), Class.pf.colors.bg.white, Class.pf.type.body.leading])],
      "This episode builds on concepts introduced previously:"
    ),
    .ul(
      attributes: [.class([
        Class.type.list.styleNone,
        Class.padding([.mobile: [.left: 2]])
        ])],
      .fragment(
        previousEps.map {
          .li(
            attributes: [.class([Class.pf.type.body.leading])],
            "#",
            .text(String($0.sequence)),
            ": ",
            .a(
              attributes: [
                .class([Class.pf.colors.link.purple]),
                .href(url(to: .episode(.left($0.slug))))
              ],
              .text($0.title)
            )
          )
        }
      )
    )
  ]
}

private func sectionsMenu(episode: Episode, permission: EpisodePermission?) -> Node {
  guard let permission = permission, isEpisodeViewable(for: permission) else { return [] }

  let exercisesNode: Node? = episode.exercises.isEmpty
    ? nil
    : .a(attributes: [.class([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), .href("#exercises")],
        "Exercises")

  let referencesNode: Node? = episode.references.isEmpty
    ? nil
    : .a(attributes: [.class([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), .href("#references")],
        "References")

  // Don't show quick link menu if at least one of exercises or references are present.
  guard exercisesNode != nil || referencesNode != nil else { return [] }

  return .div(
    attributes: [.class([Class.padding([.mobile: [.top: 2], .desktop: [.top: 3]])])],
    .fragment([
      .a(
        attributes: [.class([Class.pf.colors.link.purple, Class.margin([.mobile: [.right: 2]])]), .href("#transcript")],
        "Transcript"
      ),
      exercisesNode,
      referencesNode
      ]
      .compactMap(id)
    )
  )
}

let divider = [Node.hr(attributes: [.class([Class.pf.components.divider])])]

private func transcriptView(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool) -> Node {
  return .div(
    attributes: [
      .id("transcript"),
      .class(
        [
          Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
          Class.pf.colors.bg.white
        ]
      )
    ],
    transcript(blocks: blocks, isEpisodeViewable: isEpisodeViewable)
  )
}

private func transcript(blocks: [Episode.TranscriptBlock], isEpisodeViewable: Bool) -> Node {
  struct State { var nodes: [Node] = [], titleCount = 0 }

  return .fragment(
    blocks
      .reduce(into: State()) { state, block in
        if case .title = block.type { state.titleCount += 1 }
        state.nodes += state.titleCount <= 1 || isEpisodeViewable
          ? transcriptBlockView(block)
          : []
      }
      .nodes + subscriberCalloutView(isEpisodeViewable: isEpisodeViewable)
  )
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
                      href(path(to: .pricingLanding)),
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

private func referencesView(references: [Episode.Reference]) -> [Node] {
  guard !references.isEmpty else { return [] }

  return divider + [
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
                        style("word-break: break-all;"),
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

private func exercisesView(exercises: [Episode.Exercise]) -> [Node] {
  guard !exercises.isEmpty else { return [] }

  return divider + [
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

private func episode(
  forParam param: Either<String, Episode.Id>,
  episodes: [Episode]
  ) -> Episode? {
  return episodes
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

public enum EpisodePermission: Equatable {
  case loggedIn(user: User, subscriptionPermission: SubscriberPermission)
  case loggedOut(isEpisodeSubscriberOnly: Bool)

  public enum SubscriberPermission: Equatable {
    case isNotSubscriber(creditPermission: CreditPermission)
    case isSubscriber

    public enum CreditPermission: Equatable {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit
    }
  }
}
