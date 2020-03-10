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

public struct NewEpisodePageData {
  var context: Context
  var date: () -> Date
  var episode: Episode
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
    permission: EpisodePermission,
    subscriberState: SubscriberState,
    user: User?
  ) {
    self.context = context
    self.date = date
    self.episode = episode
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
}

public func newEpisodePageView(
  episodePageData data: NewEpisodePageData
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
                ])
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
      isEpisodeViewable: isEpisodeViewable(for: data.permission)
    ),
    mainContent(
      data: data,
      isEpisodeViewable: isEpisodeViewable(for: data.permission)
    )
  ]
}

private func sideBar(
  data: NewEpisodePageData
) -> Node {
  switch data.context {
  case let .collection(collection):
    guard let section = collection.sections
      .first(where: { section in
        section.coreLessons.contains(where: { lesson in
          // TODO: equatable
          lesson.episode.id == data.episode.id
        })
      })
      // TODO: is it possible for a section to not be found?
      else { return [] }
    guard
      let currentEpisodeIndex = section.coreLessons.firstIndex(where: { $0.episode.id == data.episode.id })
      else { return [] }

    let previousEpisodes = section.coreLessons[0..<currentEpisodeIndex].map { $0.episode }
    let nextEpisodes = section.coreLessons[(currentEpisodeIndex+1)...].map { $0.episode }

    return .div(
      attributes: [
        .class([
          Class.border.all,
          Class.border.rounded.all,
          Class.pf.colors.border.gray850,
          Class.margin([.mobile: [.leftRight: 2], .desktop: [.left: 3, .right: 0]])
        ])
      ],
      collectionHeaderRow(collection: collection, section: section),
      sequentialEpisodes(episodes: previousEpisodes, collection: collection, section: section, type: .previous),
      currentEpisodeInfoRow(data: data),
      sequentialEpisodes(episodes: nextEpisodes, collection: collection, section: section, type: .next)
    )
  case let .direct(previousEpisode: previousEpisode, nextEpisode: nextEpisode):
    return .div(
      attributes: [
        .class([
          Class.border.all,
          Class.border.rounded.all,
          Class.pf.colors.border.gray850,
          Class.margin([.mobile: [.left: 3, .right: 1]])
        ])
      ],
      sequentialEpisodeRow(episode: previousEpisode, type: .previous),
      currentEpisodeInfoRow(data: data),
      sequentialEpisodeRow(episode: nextEpisode, type: .next)
    )
  }
}

private func sequentialEpisodes(
  episodes: [Episode],
  collection: Episode.Collection,
  section: Episode.Collection.Section,
  type: SequentialEpisodeType
) -> Node {
  .fragment(episodes.map { episode in
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
        .img(
          base64: playIconSvgBase64(),
          type: .image(.svg),
          alt: "",
          attributes: [
            .class([Class.align.middle]),
            .style(margin(top: .px(-2)))
          ]
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
              Class.type.lineHeight(1)
            ])
          ],
          .a(
            attributes: [
              .class([
                Class.pf.type.body.regular,
                Class.type.lineHeight(1)
              ]),
              .href(url(to: .collections(.episode(collection.slug, section.slug, .left(episode.slug)))))
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
      .style(padding(topBottom: .rem(1.5)))
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
              Class.type.lineHeight(1)
            ]),
            .href(url(to: .collections(.section(collection.slug, section.slug))))
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

private enum SequentialEpisodeType {
  case next
  case previous

  var label: String {
    switch self {
    case .next:     return "Next episode"
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
        .class([
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
        .img(
          base64: playIconSvgBase64(),
          type: .image(.svg),
          alt: "",
          attributes: [
            .class([Class.align.middle]),
            .style(margin(top: .px(-2)))
          ]
        )
      ),
      .gridColumn(
        sizes: [.mobile: 11],
        attributes: [
          .class([
            Class.padding([.mobile: [.left: 1]]),
          ]),
          .style(unsafe: type == .previous ? """
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          """ : "")
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
  data: NewEpisodePageData
) -> Node {
  .div(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        Class.border.top,
        Class.pf.colors.border.gray850
      ]),
      .style(backgroundColor(.rgba(250, 250, 250, 1.0)))
    ],
    .gridRow(
      attributes: [
        .class([
          Class.margin([.mobile: [.bottom: 2]]),
          Class.grid.middle(.mobile)
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
            .style(margin(top: .px(-2)))
          ]
        )
      ),
      .gridColumn(
        sizes: [.mobile: 11],
        attributes: [
          .class([
            Class.pf.type.body.regular,
            Class.padding([.mobile: [.left: 1]]),
            Class.type.lineHeight(1)
          ])
        ],
        .text(data.episode.subtitle ?? data.episode.title)
      )
    ),
    chaptersRow(data: data),
    exercisesRow(episode: data.episode),
    referencesRow(episode: data.episode),
    downloadRow
  )
}

private func chaptersRow(data: NewEpisodePageData) -> Node {
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
                  Class.display.inlineBlock
                ]),
                .style(
                  width(.px(2))
                    <> height(.pct(100))
                )
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
            .a(
              attributes: [
                .href(
                  isEpisodeViewable(for: data.permission)
                    ? "#t\(block.timestamp ?? 0)"
                    : ""
                ),
              ],
              .text(block.content)
            )
          ),
          .gridColumn(
            sizes: [.mobile: 2],
            attributes: [
              .class([
                Class.pf.type.body.small,
                Class.pf.colors.fg.gray650,
                Class.type.align.end
              ])
            ],
            .a(
              attributes: [
                .href(
                  isEpisodeViewable(for: data.permission)
                    ? "#t\(block.timestamp ?? 0)"
                    : ""
                ),
                .class([
                  Class.pf.type.body.small,
                  Class.pf.colors.link.gray650
                ]),
                .style(safe: "font-variant-numeric: tabular-nums")
              ],
              .text(timestampLabel(for: block.timestamp ?? 0))
            )
          )
        )
      }
    )
  )
}

private func exercisesRow(episode: Episode) -> Node {
  guard !episode.exercises.isEmpty else { return [] }
  return .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.top: 1]]),
        Class.grid.middle(.mobile)
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
          .style(margin(top: .px(-4)))
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.regular,
          Class.padding([.mobile: [.left: 1]])
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
        Class.grid.middle(.mobile)
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
          .style(margin(top: .px(-2)))
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.regular,
          Class.padding([.mobile: [.left: 1]])
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
      Class.grid.middle(.mobile)
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
        .style(margin(top: .px(-2)))
      ]
    )
  ),
  .gridColumn(
    sizes: [.mobile: 11],
    attributes: [
      .class([
        Class.pf.type.body.regular,
        Class.padding([.mobile: [.left: 1]])
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
  data: NewEpisodePageData,
  isEpisodeViewable: Bool
) -> Node {

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
          Class.position.top0
        ])
      ],
      sideBar(data: data)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      transcriptView(
        blocks: data.episode.transcriptBlocks,
        isEpisodeViewable: isEpisodeViewable,
        needsExtraPadding: false
      ),
      exercisesView(exercises: data.episode.exercises),
      referencesView(references: data.episode.references),
      downloadsView(episode: data.episode)
    )
  )
}

private func downloadsView(episode: Episode) -> Node {
  //.href(gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: codeSampleDirectory)))
  .div(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 3], .desktop: [.leftRight: 4, .bottom: 4, .top: 2]]),
        ])
    ],
    .h2(
      attributes: [
        .id("downloads"),
        .class([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])])
      ],
      "Downloads"
    ),
    .div(
      attributes: [
        .class([
          Class.border.all,
          Class.border.rounded.all,
          Class.pf.colors.border.gray850,
          Class.padding([.mobile: [.all: 2]])
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
          .href(gitHubUrl(to: GitHubRoute.episodeCodeSample(directory: episode.codeSampleDirectory))),
          .class([Class.pf.colors.link.purple, Class.margin([.mobile: [.left: 1]]), Class.align.middle])
        ],
        .text(episode.codeSampleDirectory)
      )
    )
  )
}

private func video(
  forEpisode episode: Episode,
  isEpisodeViewable: Bool
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
        videoView(forEpisode: episode, isEpisodeViewable: isEpisodeViewable)
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
            .style(lineHeight(1.2))
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
          .text("""
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

private let sidebarShoutTitleClass
  = Class.pf.colors.fg.gray650
    | Class.typeScale([.mobile: .r0_75])
    | Class.type.lineHeight(1)
    | Class.type.caps
    | Class.type.bold
    | Class.padding([.mobile: [.all: 0]])
    | Class.margin([.mobile: [.leftRight: 0, .top: 0, .bottom: 1]])
