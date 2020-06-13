import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

public struct EpisodePageData {
  var context: Context
  var date: () -> Date
  var episode: Episode
  var episodeProgress: Int?
  var permission: EpisodePermission
  var subscriberState: SubscriberState
  var user: User?

  public enum Context {
    case collection(Episode.Collection)
    case direct(previousEpisode: Episode?, nextEpisode: Episode?)
  }

  public init(
    context: Context,
    date: @escaping () -> Date,
    episode: Episode,
    episodeProgress: Int?,
    permission: EpisodePermission,
    subscriberState: SubscriberState,
    user: User?
  ) {
    self.context = context
    self.date = date
    self.episode = episode
    self.episodeProgress = episodeProgress
    self.permission = permission
    self.subscriberState = subscriberState
    self.user = user
  }

  public var collection: Episode.Collection? {
    guard case let .collection(collection) = self.context else { return nil }
    return collection
  }

  public var section: Episode.Collection.Section? {
    guard
      let collection = self.collection,
      let section = collection.sections
        .first(where: { $0.coreLessons.contains(where: { $0.episode == self.episode }) })
    else { return nil }
    return section
  }

  public var route: Route {
    switch context {
    case let .collection(collection):
      guard
        let section = collection.sections.first(where: {
          $0.coreLessons.contains(where: {
            $0.episode == self.episode
          })
        })
      else { return .episode(.show(.left(self.episode.slug))) }
      return .collections(.episode(collection.slug, section.slug, .left(self.episode.slug)))
    case .direct:
      return .episode(.show(.left(self.episode.slug)))
    }
  }
}

public func episodePageView(
  episodePageData data: EpisodePageData
) -> Node {
  [
    zip(data.collection, data.section)
      .map { collection, section in
        collectionNavigation(
          left: [
            .a(
              attributes: [
                .href(path(to: .collections(.section(collection.slug, section.slug)))),
                .class([
                  Class.pf.colors.link.gray650
                ]),
              ],
              .text(section.title)
            ),
          ]
        )
      }
      ?? [],
    episodeHeader(
      episode: data.episode,
      date: data.date
    ),
    video(
      forEpisode: data.episode,
      isEpisodeViewable: isEpisodeViewable(for: data.permission),
      episodeProgress: data.episodeProgress
    ),
    mainContent(
      data: data,
      isEpisodeViewable: isEpisodeViewable(for: data.permission)
    ),
  ]
}

private func sideBar(
  data: EpisodePageData
) -> Node {
  switch data.context {
  case let .collection(collection):
    guard
      let section = collection.sections
        .first(where: { section in
          section.coreLessons.contains(where: { lesson in
            // TODO: equatable
            lesson.episode.id == data.episode.id
          })
        })
      // TODO: is it possible for a section to not be found?
    else { return [] }
    guard
      let currentEpisodeIndex = section.coreLessons.firstIndex(where: {
        $0.episode.id == data.episode.id
      })
    else { return [] }

    let previousEpisodes = section.coreLessons[0..<currentEpisodeIndex].map(\.episode)
    let nextEpisodes = section.coreLessons[(currentEpisodeIndex + 1)...].map(\.episode)

    return .div(
      attributes: [.class([sideBarClasses])],
      collectionHeaderRow(collection: collection, section: section),
      sequentialEpisodes(
        episodes: previousEpisodes, collection: collection, section: section, type: .previous),
      currentEpisodeInfoRow(data: data),
      sequentialEpisodes(
        episodes: nextEpisodes, collection: collection, section: section, type: .next),
      collectionFooterRow(
        collection: collection, section: section, isOnLastEpisode: nextEpisodes.isEmpty)
    )
  case let .direct(previousEpisode: previousEpisode, nextEpisode: nextEpisode):
    return .div(
      attributes: [.class([sideBarClasses])],
      sequentialEpisodeRow(episode: previousEpisode, type: .previous),
      currentEpisodeInfoRow(data: data),
      sequentialEpisodeRow(episode: nextEpisode, type: .next)
    )
  }
}

private let sideBarClasses =
  Class.border.all
  | Class.border.rounded.all
  | Class.pf.colors.border.gray850
  | Class.layout.overflowHidden
  | Class.margin([
    .mobile: [.leftRight: 2],
    .desktop: [.left: 3, .right: 0],
  ])

private func sequentialEpisodes(
  episodes: [Episode],
  collection: Episode.Collection,
  section: Episode.Collection.Section,
  type: SequentialEpisodeType
) -> Node {
  .fragment(
    episodes.map { episode in
      .gridRow(
        attributes: [
          .class([
            Class.padding([.mobile: [.all: 2]]),
            Class.border.top,
            Class.pf.colors.border.gray850,
            Class.grid.middle(.mobile),
          ])
        ],
        .gridColumn(
          sizes: [.mobile: 1],
          attributes: [
            .class([Class.type.align.center])
          ],
          .a(
            attributes: [.href(url(to: .episode(.show(.left(episode.slug)))))],
            .img(
              base64: playIconSvgBase64(),
              type: .image(.svg),
              alt: "",
              attributes: [
                .class([Class.align.middle]),
                .style(margin(top: .px(-2))),
              ]
            )
          )
        ),
        .gridColumn(
          sizes: [.mobile: 11],
          attributes: [
            .class([
              Class.padding([.mobile: [.left: 1]]),
            ])
          ],
          .p(
            attributes: [
              .class([
                Class.padding([.mobile: [.all: 0]]),
                Class.margin([.mobile: [.all: 0]]),
                Class.type.lineHeight(1),
              ])
            ],
            .a(
              attributes: [
                .class([
                  Class.pf.type.body.regular,
                  Class.type.lineHeight(1),
                ]),
                .href(
                  url(
                    to: .collections(.episode(collection.slug, section.slug, .left(episode.slug))))),
              ],
              .text(episode.subtitle ?? episode.title)
            )
          )
        )
      )
    })
}

private func collectionHeaderRow(
  collection: Episode.Collection,
  section: Episode.Collection.Section
) -> Node {
  .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.leftRight: 2]]),
        Class.pf.colors.border.gray850,
        Class.grid.middle(.mobile),
      ]),
      .style(padding(topBottom: .rem(1.5))),
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      .h6(
        attributes: [
          .class([
            sidebarShoutTitleClass
          ])
        ],
        "Collection"
      ),
      .p(
        attributes: [
          .class([
            Class.padding([.mobile: [.all: 0]]),
            Class.margin([.mobile: [.all: 0]]),
          ])
        ],
        .a(
          attributes: [
            .class([
              Class.pf.colors.fg.black,
              Class.h5,
              Class.type.medium,
              Class.type.lineHeight(1),
            ]),
            .href(url(to: .collections(.section(collection.slug, section.slug)))),
          ],
          .text(
            collection.sections.count == 1
              ? section.title
              : collection.title + " › " + section.title
          )
        )
      )
    )
  )
}

private func collectionFooterRow(
  collection: Episode.Collection,
  section: Episode.Collection.Section,
  isOnLastEpisode: Bool
) -> Node {
  guard
    isOnLastEpisode,
    let currentIndex = collection.sections.firstIndex(where: { $0 == section }),
    currentIndex != collection.sections.index(before: collection.sections.endIndex)
  else { return [] }

  let nextSection = collection.sections[collection.sections.index(after: currentIndex)]

  return .gridRow(
    attributes: [
      .class([
        Class.border.top,
        Class.padding([.mobile: [.leftRight: 2]]),
        Class.pf.colors.border.gray850,
        Class.grid.middle(.mobile),
      ]),
      .style(padding(topBottom: .rem(1.5))),
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      .h6(
        attributes: [
          .class([
            sidebarShoutTitleClass
          ])
        ],
        "Next Up"
      ),
      .p(
        attributes: [
          .class([
            Class.padding([.mobile: [.all: 0]]),
            Class.margin([.mobile: [.all: 0]]),
          ])
        ],
        .a(
          attributes: [
            .class([
              Class.pf.colors.fg.black,
              Class.h5,
              Class.type.medium,
              Class.type.lineHeight(1),
            ]),
            .href(url(to: .collections(.section(collection.slug, nextSection.slug)))),
          ],
          .text(
            nextSection.title
          )
        )
      )
    )
  )
}

private enum SequentialEpisodeType {
  case next
  case previous

  var label: String {
    switch self {
    case .next: return "Next episode"
    case .previous: return "Previous episode"
    }
  }
}

private func sequentialEpisodeRow(
  episode: Episode?,
  type: SequentialEpisodeType
) -> Node {
  guard let episode = episode else { return [] }

  return [
    .gridRow(
      attributes: [
        .class(
          [
            Class.padding([.mobile: [.all: 2]]),
            type == .next ? Class.border.top : nil,
            Class.pf.colors.border.gray850,
            Class.grid.middle(.mobile),
          ].compactMap { $0 })
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        .h6(
          attributes: [
            .class([
              sidebarShoutTitleClass
            ])
          ],
          .text(type.label)
        )
      ),
      .gridColumn(
        sizes: [.mobile: 1],
        attributes: [
          .class([Class.type.align.center])
        ],
        .a(
          attributes: [.href(url(to: .episode(.show(.left(episode.slug)))))],
          .img(
            base64: playIconSvgBase64(),
            type: .image(.svg),
            alt: "",
            attributes: [
              .class([Class.align.middle]),
              .style(margin(top: .px(-2))),
            ]
          )
        )
      ),
      .gridColumn(
        sizes: [.mobile: 11],
        attributes: [
          .class([
            Class.padding([.mobile: [.left: 1]]),
          ]),
          .style(
            unsafe: type == .previous
              ? """
              white-space: nowrap;
              overflow: hidden;
              text-overflow: ellipsis;
              """ : ""),
        ],
        .a(
          attributes: [
            .class([
              Class.pf.type.body.regular,
              Class.type.lineHeight(1),
              Class.padding([.mobile: [.all: 0]]),
              Class.margin([.mobile: [.all: 0]]),
            ]),
            .href(url(to: .episode(.show(.left(episode.slug))))),
          ],
          .text(episode.fullTitle)
        )
      )
    )
  ]
}

private func currentEpisodeInfoRow(
  data: EpisodePageData
) -> Node {
  .div(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        Class.border.top,
        Class.pf.colors.border.gray850,
      ]),
      .style(backgroundColor(.rgba(250, 250, 250, 1.0))),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.margin([.mobile: [.bottom: 2]]),
          Class.grid.middle(.mobile),
        ])
      ],
      .gridColumn(
        sizes: [.mobile: 1],
        attributes: [
          .class([Class.type.align.center])
        ],
        .img(
          base64: playIconSvgBase64(),
          type: .image(.svg),
          alt: "",
          attributes: [
            .class([Class.align.middle]),
            .style(margin(top: .px(-2))),
          ]
        )
      ),
      .gridColumn(
        sizes: [.mobile: 11],
        attributes: [
          .class([
            Class.pf.type.body.regular,
            Class.padding([.mobile: [.left: 1]]),
            Class.type.lineHeight(1),
          ])
        ],
        .raw(nonBreaking(title: data.episode.subtitle ?? data.episode.title))
      )
    ),
    chaptersRow(data: data),
    exercisesRow(episode: data.episode),
    referencesRow(episode: data.episode),
    downloadRow
  )
}

private func chaptersRow(data: EpisodePageData) -> Node {
  let episode = data.episode

  let titleBlocks = episode.transcriptBlocks
    .filter { $0.type == .title && $0.timestamp != nil }

  return .div(
    attributes: [
      .class([
        Class.margin([.mobile: [.bottom: 1]]),
      ])
    ],
    .fragment(
      titleBlocks.map { block in
        .gridRow(
          .gridColumn(
            sizes: [.mobile: 1],
            attributes: [
              .class([Class.type.align.center])
            ],
            .div(
              attributes: [
                .class([
                  Class.pf.colors.bg.gray850,
                  Class.display.inlineBlock,
                ]),
                .style(
                  width(.px(2))
                    <> height(.pct(100))
                ),
              ],
              []
            )
          ),
          .gridColumn(
            sizes: [.mobile: 9],
            attributes: [
              .class([
                Class.padding([.mobile: [.leftRight: 1]]),
                Class.pf.type.body.small,
              ])
            ],
            timestampChapterLink(
              isEpisodeViewable: isEpisodeViewable(for: data.permission),
              timestamp: block.timestamp,
              title: block.content
            )
          ),
          .gridColumn(
            sizes: [.mobile: 2],
            attributes: [
              .class([
                Class.pf.type.body.small,
                Class.pf.colors.fg.gray650,
                Class.type.align.end,
              ])
            ],
            block.timestamp
              .map {
                timestampLink(
                  isEpisodeViewable: isEpisodeViewable(for: data.permission),
                  timestamp: $0
                )
              }
              ?? []
          )
        )
      }
    )
  )
}

private func timestampChapterLink(
  isEpisodeViewable: Bool,
  timestamp: Int?,
  title: String
) -> Node {
  assert(timestamp != nil)
  guard let timestamp = timestamp else { return [] }
  if isEpisodeViewable {
    return .a(
      attributes: [
        .href("#t\(timestamp)"),
      ],
      .text(title)
    )
  } else {
    return .text(title)
  }
}

private func timestampLink(
  isEpisodeViewable: Bool,
  timestamp: Int
) -> Node {
  if isEpisodeViewable {
    return .a(
      attributes: [
        .href("#t\(timestamp)"),
        .class([
          Class.pf.type.body.small,
          Class.pf.colors.link.gray650,
        ]),
        .style(safe: "font-variant-numeric: tabular-nums"),
      ],
      .text(timestampLabel(for: timestamp))
    )
  } else {
    return .span(
      attributes: [
        .class([
          Class.pf.type.body.small,
          Class.pf.colors.fg.gray650,
        ]),
        .style(safe: "font-variant-numeric: tabular-nums"),
      ],
      .text(timestampLabel(for: timestamp))
    )
  }
}

private func exercisesRow(episode: Episode) -> Node {
  guard !episode.exercises.isEmpty else { return [] }
  return .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.top: 1]]),
        Class.grid.middle(.mobile),
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 1],
      attributes: [
        .class([Class.type.align.center])
      ],
      .img(
        base64: exercisesIconSvgBase64,
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([Class.align.middle]),
          .style(margin(top: .px(-4))),
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.regular,
          Class.padding([.mobile: [.left: 1]]),
        ])
      ],
      .a(
        attributes: [
          .href("#exercises")
        ],
        "Exercises"
      )
    )
  )
}

private func referencesRow(episode: Episode) -> Node {
  guard !episode.references.isEmpty else { return [] }

  return .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.top: 1]]),
        Class.grid.middle(.mobile),
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 1],
      attributes: [
        .class([Class.type.align.center])
      ],
      .img(
        base64: referencesIconSvgBase64,
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([Class.align.middle]),
          .style(margin(top: .px(-2))),
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.regular,
          Class.padding([.mobile: [.left: 1]]),
        ])
      ],
      .a(
        attributes: [
          .href("#references")
        ],
        "References"
      )
    )
  )
}

private let downloadRow = Node.gridRow(
  attributes: [
    .class([
      Class.padding([.mobile: [.top: 1]]),
      Class.grid.middle(.mobile),
    ])
  ],
  .gridColumn(
    sizes: [.mobile: 1],
    attributes: [
      .class([Class.type.align.center])
    ],
    .img(
      base64: downloadIconSvgBase64,
      type: .image(.svg),
      alt: "",
      attributes: [
        .class([Class.align.middle]),
        .style(margin(top: .px(-2))),
      ]
    )
  ),
  .gridColumn(
    sizes: [.mobile: 11],
    attributes: [
      .class([
        Class.pf.type.body.regular,
        Class.padding([.mobile: [.left: 1]]),
      ])
    ],
    .a(
      attributes: [
        .href("#downloads")
      ],
      "Downloads"
    )
  )
)

private func mainContent(
  data: EpisodePageData,
  isEpisodeViewable: Bool
) -> Node {
  .article(
    .gridRow(
      attributes: [
        .class([
          Class.grid.top(.desktop),
          Class.padding([
            .desktop: [.leftRight: 0, .top: 0],
            .mobile: [.leftRight: 0, .top: 3, .bottom: 2],
          ]),
        ]),
        .style(
          maxWidth(.px(1080))
            <> margin(topBottom: nil, leftRight: .auto)
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 4],
        attributes: [
          .class([
            Class.padding([.desktop: [.top: 3]]),
            Class.position.sticky(.desktop),
            Class.position.top0,
          ])
        ],
        sideBar(data: data)
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 8],
        topCallout(data: data),
        transcriptView(data: data),
        exercisesView(exercises: data.episode.exercises),
        referencesView(references: data.episode.references),
        downloadsView(episode: data.episode)
      )
    )
  )
}

private func topCallout(data: EpisodePageData) -> Node {
  func pad(_ node: Node) -> Node {
    .div(
      attributes: [
        .class([
          Class.padding([
            .mobile: [.leftRight: 3, .top: 3],
            .desktop: [.left: 4, .right: 3],
          ]),
        ])
      ],
      node
    )
  }

  switch data.permission {
  case .loggedIn(_, .isSubscriber):
    return []
  case .loggedOut(isEpisodeSubscriberOnly: true):
    return pad(unlockLoggedOutCallout(data: data))
  case .loggedIn(let user, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true)))
  where user.episodeCreditCount > 0:
    return pad(unlockLoggedInCallout(user: user, data: data))
  case .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true))):
    return pad(subscribeCallout(data: data))
  case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
    return pad(creditSubscribeCallout(data: data))
  case .loggedOut(isEpisodeSubscriberOnly: false),
    .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: false))):
    return pad(subscribeFreeCallout(data: data))
  }
}

private func bottomCallout(data: EpisodePageData) -> Node {
  func pad(_ node: Node) -> Node {
    .div(
      attributes: [
        .class([
          Class.padding([
            .desktop: [.topBottom: 3],
            .mobile: [.topBottom: 2],
          ]),
        ])
      ],
      node
    )
  }

  switch data.permission {
  case .loggedIn(_, .isSubscriber):
    return []
  case .loggedOut(isEpisodeSubscriberOnly: true),
    .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true))):
    return pad(subscribeCallout(data: data))
  case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
    return pad(creditSubscribeCallout(data: data))
  case .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(false))), .loggedOut(false):
    return pad(subscribeFreeCallout(data: data))
  }
}

private func calloutBar(
  icon svgBase64: String,
  _ content: String
) -> Node {
  .gridRow(
    attributes: [
      .class([
        Class.border.bottom,
        Class.flex.items.center,
        Class.flex.justify.center,
        Class.h6,
        Class.padding([
          .mobile: [.topBottom: 1, .leftRight: 2]
        ]),
        Class.pf.colors.bg.gray900,
        Class.pf.colors.border.gray850,
        Class.pf.colors.fg.gray650,
        Class.type.align.center,
        Class.type.lineHeight(4),
        Class.type.semiBold,
      ]),
    ],
    .img(
      base64: svgBase64, type: .image(.svg), alt: "",
      attributes: [
        .class([
          Class.padding([
            .mobile: [.right: 1],
          ])
        ]),
      ]),
    .text(content)
  )
}

private func callout(
  bar: Node = [],
  icon svgBase64: String? = nil,
  title: String,
  body: String,
  _ cta: Node...
) -> Node {

  .div(
    attributes: [
      .class([
        Class.border.all,
        Class.border.rounded.all,
        Class.pf.colors.border.gray850,
      ])
    ],
    bar,
    .div(
      attributes: [
        .class([
          Class.padding([
            .desktop: [.leftRight: 4],
            .mobile: [.all: 3],
          ]),
          Class.type.align.center,
        ]),
      ],
      svgBase64
        .map { .img(base64: $0, type: .image(.svg), alt: "") }
        ?? [],
      .h3(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle5
          ])
        ],
        .text(title)
      ),
      .p(
        attributes: [
          .class([
            Class.padding([.mobile: [.bottom: 3]]),
            Class.pf.colors.fg.gray650,
          ]),
        ],
        .text(body)
      ),
      .div(
        attributes: [
          .class([
            Class.margin([.mobile: [.bottom: 2]]),
          ]),
        ],
        .fragment(cta)
      )
    )
  )
}

private func downloadsView(episode: Episode) -> Node {
  .div(
    attributes: [
      .class([
        Class.padding([
          .mobile: [.all: 3],
          .desktop: [.left: 4, .right: 3, .bottom: 4, .top: 2],
        ]),
      ])
    ],
    .h3(
      attributes: [
        .id("downloads"),
        .class([Class.h3]),
      ],
      "Downloads"
    ),
    .div(
      attributes: [
        .class([
          Class.border.all,
          Class.border.rounded.all,
          Class.pf.colors.border.gray850,
          Class.padding([.mobile: [.all: 2]]),
        ])
      ],
      .h3(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle5
          ])
        ],
        "Sample Code"
      ),
      .img(
        base64: gitHubSvgBase64(fill: "#974dff"),
        type: .image(.svg),
        alt: "",
        attributes: [.class([Class.align.middle]), .width(20), .height(20)]
      ),
      .a(
        attributes: [
          .href(
            gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: episode.codeSampleDirectory))),
          .class([
            Class.pf.colors.link.purple, Class.margin([.mobile: [.left: 1]]), Class.align.middle,
          ]),
        ],
        .text(episode.codeSampleDirectory)
      )
    )
  )
}

private func creditSubscribeCallout(data: EpisodePageData) -> Node {

  return callout(
    bar: calloutBar(icon: unlockSvgBase64, "You unlocked this episode with a credit."),
    title: "Subscribe to Point-Free",
    body: "Access all past and future episodes when you become a subscriber.",
    .a(
      attributes: [
        .class([
          Class.pf.components.button(color: .purple),
        ]),
        .href(path(to: .pricingLanding)),
      ],
      "See plans and pricing"
    )
  )
}

private func subscribeCallout(data: EpisodePageData) -> Node {

  callout(
    bar: calloutBar(icon: lockSvgBase64, "This episode is for subscribers only."),
    title: "Subscribe to Point-Free",
    body: "Access this episode, plus all past and future episodes when you become a subscriber.",
    .a(
      attributes: [
        .class([
          Class.pf.components.button(color: .purple),
        ]),
        .href(path(to: .pricingLanding)),
      ],
      "See plans and pricing"
    ),
    data.user == nil
      ? .p(
        attributes: [
          .class([
            Class.margin([.mobile: [.top: 2]]),
            Class.pf.colors.fg.gray650,
            Class.pf.type.body.small,
          ]),
        ],
        "Already a subscriber? ",
        .a(
          attributes: [
            .class([
              Class.pf.colors.link.purple,
            ]),
            .href(path(to: .login(redirect: url(to: data.route)))),
          ],
          "Log in"
        )
      )
      : []
  )
}

private func subscribeFreeCallout(data: EpisodePageData) -> Node {

  callout(
    bar: calloutBar(icon: unlockSvgBase64, "This episode is free for everyone."),
    title: "Subscribe to Point-Free",
    body: "Access all past and future episodes when you become a subscriber.",
    .a(
      attributes: [
        .class([
          Class.pf.components.button(color: .purple),
        ]),
        .href(path(to: .pricingLanding)),
      ],
      "See plans and pricing"
    ),
    data.user == nil
      ? .p(
        attributes: [
          .class([
            Class.margin([.mobile: [.top: 2]]),
            Class.pf.colors.fg.gray650,
            Class.pf.type.body.small,
          ]),
        ],
        "Already a subscriber? ",
        .a(
          attributes: [
            .class([
              Class.pf.colors.link.purple,
            ]),
            .href(path(to: .login(redirect: url(to: data.route)))),
          ],
          "Log in"
        )
      )
      : []
  )
}

private func unlockLoggedOutCallout(data: EpisodePageData) -> Node {
  callout(
    icon: circleLockSvgBase64,
    title: "Unlock This Episode",
    body:
      "Our Free plan includes 1 subscriber-only episode of your choice, plus weekly updates from our newsletter.",
    .gitHubLink(
      text: "Sign in with GitHub",
      type: .black,
      href: path(to: .login(redirect: url(to: data.route)))
    )
  )
}

private func unlockLoggedInCallout(user: User, data: EpisodePageData) -> Node {
  callout(
    icon: circleLockSvgBase64,
    title: "Unlock This Episode",
    body: """
      You have \(String(user.episodeCreditCount)) episode credit\(user.episodeCreditCount == 1 ? "" : "s"). \
      Spend \(user.episodeCreditCount == 1 ? "it" : "one") to watch this episode for free?
      """,
    .form(
      attributes: [
        .action(path(to: .useEpisodeCredit(data.episode.id))),
        .method(.post),
      ],
      .button(
        attributes: [
          .class([
            Class.pf.components.button(color: .black),
          ])
        ],
        "Redeem this episode"
      )
    )
  )
}

private func video(
  forEpisode episode: Episode,
  isEpisodeViewable: Bool,
  episodeProgress: Int?
) -> Node {
  .div(
    attributes: [
      .class([
        Class.border.top,
      ]),
      .style(key("border-top-color", "#333")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .desktop: [.leftRight: 3],
            .mobile: [.leftRight: 1, .bottom: 2],
          ]),
        ]),
        .style(
          maxWidth(.px(1080))
            <> margin(topBottom: nil, leftRight: .auto)
            <> margin(top: .rem(-4))
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .style(
            boxShadow(
              hShadow: .rem(0),
              vShadow: .rem(1),
              blurRadius: .px(20),
              color: .rgba(0, 0, 0, 0.2)
            )
          )
        ],
        videoView(
          forEpisode: episode,
          isEpisodeViewable: isEpisodeViewable,
          episodeProgress: episodeProgress
        )
      )
    )
  )
}

private func episodeHeader(
  episode: Episode,
  date: () -> Date
) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
      ]),
      .style(key("border-top-color", "#000")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3, .top: 4, .bottom: 5],
          ]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [],
        .h1(
          attributes: [
            .class([
              Class.pf.colors.fg.white,
              Class.pf.type.responsiveTitle2,
              Class.type.align.center,
            ]),
            .style(lineHeight(1.2)),
          ],
          .raw(nonBreaking(title: episode.fullTitle))
        ),
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 2]]),
              Class.pf.colors.fg.gray650,
              Class.pf.type.body.small,
              Class.type.align.center,
            ]),
          ],
          .text(
            """
            Episode #\(episode.sequence) • \
            \(newEpisodeDateFormatter.string(from: episode.publishedAt)) \
            • \(episode.isSubscriberOnly(currentDate: date()) ? "Subscriber-Only" : "Free Episode")
            """)
        ),
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1, .leftRight: 0], .desktop: [.leftRight: 4]]),
              Class.pf.colors.fg.gray850,
              Class.pf.type.body.regular,
            ]),
          ],
          .markdownBlock(episode.blurb)
        )
      )
    )
  )
}

public let useCreditCTA = "Use an episode credit"

let divider = Node.hr(attributes: [.class([Class.pf.components.divider])])

private func transcriptView(data: EpisodePageData) -> Node {
  .div(
    attributes: [
      .id("transcript"),
      .class(
        [
          Class.padding([
            .mobile: [.all: 3],
            .desktop: [
              .left: 4,
              .right: 3,
            ],
          ])
        ]
      ),
    ],
    transcript(data: data)
  )
}

private func transcript(data: EpisodePageData) -> Node {
  struct State { var nodes: [Node] = [], titleCount = 0 }

  return .fragment(
    data.episode.transcriptBlocks
      .enumerated()
      .reduce(into: State()) { state, idxAndBlock in
        let (idx, block) = idxAndBlock
        if case .title = block.type { state.titleCount += 1 }

        let isLastParagraphInFirstChapter: Bool
        if idx + 1 < data.episode.transcriptBlocks.count,
          case .title = data.episode.transcriptBlocks[idx + 1].type
        {
          isLastParagraphInFirstChapter = true
        } else {
          isLastParagraphInFirstChapter = false
        }

        state.nodes +=
          state.titleCount <= 1 || isEpisodeViewable(for: data.permission)
          ? [
            transcriptBlockView(
              block,
              fadeOutBlock: isLastParagraphInFirstChapter
                && !isEpisodeViewable(for: data.permission)
            )
          ]
          : []
      }
      .nodes + [bottomCallout(data: data)]
  )
}

private func referencesView(references: [Episode.Reference]) -> Node {
  guard !references.isEmpty else { return [] }

  return [
    .div(
      attributes: [
        .class([
          Class.padding([
            .mobile: [.leftRight: 3, .top: 3],
            .desktop: [.left: 4, .right: 3, .top: 2],
          ]
          ),
          Class.pf.colors.bg.white,
        ])
      ],
      .h3(
        attributes: [
          .id("references"),
          .class([Class.h3]),
        ],
        "References"
      ),
      .gridRow(
        .fragment(zip(1..., references).map(referenceView(index:reference:)))
      )
    )
  ]
}

private func referenceView(index: Int, reference: Episode.Reference) -> Node {
  return [
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .id("reference-\(index)"),
        .class([
          Class.margin([.mobile: [.bottom: 3]]),
          Class.padding([.mobile: [.all: 3]]),
          Class.border.all,
          Class.border.rounded.all,
          Class.pf.colors.border.gray850,
        ]),
      ],
      .h4(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle4,
            Class.type.normal,
            Class.margin([.mobile: [.topBottom: 0]]),
          ])
        ],
        .a(
          attributes: [
            .href(reference.link),
            .target(.blank),
            .rel(.init(rawValue: "noopener noreferrer")),
          ],
          .text(reference.title)
        )
      ),
      .strong(
        attributes: [
          .class([
            Class.display.block,
            Class.pf.type.body.small,
            Class.pf.colors.fg.gray500,
            Class.margin([.mobile: [.bottom: 2]]),
          ])
        ],
        .text(topLevelReferenceMetadata(reference))
      ),
      .div(
        attributes: [
          .class([
            Class.margin([.mobile: [.bottom: 2]])
          ])
        ],
        .markdownBlock(reference.blurb ?? "")
      ),
      .div(
        attributes: [
          .class([Class.pf.colors.fg.purple]),
          .style(
            unsafe: #"""
              white-space: nowrap;
              overflow: hidden;
              text-overflow: ellipsis;
              """#),
        ],
        .a(
          attributes: [
            .href(reference.link),
            .class([Class.pf.colors.link.purple]),
            .target(.blank),
            .rel(.init(rawValue: "noopener noreferrer")),
          ],
          .text(reference.link)
        )
      )
    )
  ]
}

private func topLevelReferenceMetadata(_ reference: Episode.Reference) -> String {
  return [
    reference.author,
    reference.publishedAt.map(episodeDateFormatter.string(from:)),
  ]
  .compactMap { $0 }
  .joined(separator: " • ")
}

private func exercisesView(exercises: [Episode.Exercise]) -> Node {
  guard !exercises.isEmpty else { return [] }

  return [
    .div(
      attributes: [
        .class(
          [
            Class.padding([
              .mobile: [.leftRight: 3, .top: 3],
              .desktop: [.left: 4, .right: 3, .bottom: 2, .top: 2],
            ]),
            Class.pf.colors.bg.white,
          ]
        )
      ],
      .h3(
        attributes: [
          .id("exercises"),
          .class([Class.h3]),
        ],
        "Exercises"
      ),
      .ol(
        attributes: [
          .style(safe: "padding-left: 1.5rem")
        ],
        .fragment(zip(1..., exercises).map(exercise(idx:exercise:)))
      )
    )
  ]
}

private func exercise(idx: Int, exercise: Episode.Exercise) -> ChildOf<Tag.Ol> {
  return .li(
    attributes: [
      .id("exercise-\(idx)"),
      .class([
        Class.padding([.mobile: [.bottom: 2]])
      ]),
    ],
    .div(
      .markdownBlock(exercise.problem),
      solution(to: exercise)
    )
  )
}

private func solution(to exercise: Episode.Exercise) -> Node {
  guard let solution = exercise.solution else { return [] }

  return .details(
    .summary(attributes: [.class([Class.cursor.pointer])], "Solution"),
    .div(
      attributes: [
        .class([
          Class.border.left,
          Class.pf.colors.border.gray850,
          Class.pf.colors.bg.white,
          Class.padding([.mobile: [.topBottom: 1, .leftRight: 2]]),
          Class.margin([.mobile: [.bottom: 3]]),
          Class.layout.overflowAuto(.x),
        ])
      ],
      .markdownBlock(solution)
    )
  )
}

public func isEpisodeViewable(for permission: EpisodePermission) -> Bool {
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

private func nonBreaking(title: String) -> String {
  let parts = title.components(separatedBy: ": ")
  guard
    parts.count == 2,
    let mainTitle = parts.first,
    let subTitle = parts.last
  else { return title }

  return mainTitle + ": " + subTitle.replacingOccurrences(of: " ", with: "&nbsp;")
}

private let newEpisodeDateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateFormat = "MMM d, yyyy"
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()

private let sidebarShoutTitleClass =
  Class.pf.colors.fg.gray650
  | Class.typeScale([.mobile: .r0_75])
  | Class.type.lineHeight(1)
  | Class.type.caps
  | Class.type.bold
  | Class.padding([.mobile: [.all: 0]])
  | Class.margin([.mobile: [.leftRight: 0, .top: 0, .bottom: 1]])
