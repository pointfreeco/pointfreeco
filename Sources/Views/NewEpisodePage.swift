import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public struct NewEpisodePageData {
  var permission: EpisodePermission
  var user: User?
  var subscriberState: SubscriberState
  var episode: Episode
  var previousEpisode: Episode?
  var nextEpisode: Episode?
  var date: () -> Date

  public init(
    permission: EpisodePermission,
    user: User?,
    subscriberState: SubscriberState,
    episode: Episode,
    previousEpisode: Episode?,
    nextEpisode: Episode?,
    date: @escaping () -> Date
    ) {
    self.permission = permission
    self.user = user
    self.subscriberState = subscriberState
    self.episode = episode
    self.previousEpisode = previousEpisode
    self.nextEpisode = nextEpisode
    self.date = date
  }
}

public func newEpisodePageView(
  episodePageData data: NewEpisodePageData
) -> Node {
  [
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
  .div(
    attributes: [
      .class([
        Class.border.all,
        Class.border.rounded.all,
        Class.pf.colors.border.gray850,
      ])
    ],
    sequentialEpisodeRow(episode: data.previousEpisode, type: .previous),
    currentEpisodeInfoRow(episode: data.episode),
    sequentialEpisodeRow(episode: data.nextEpisode, type: .next)
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

  return .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        type == .next ? Class.border.top : Class.border.bottom,
        Class.pf.colors.border.gray850,
        Class.grid.middle(.desktop),
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 1],
      attributes: [
        .class([Class.type.align.center])
      ],
      .img(
        base64: playIconSvgBase64(fill: "a1a1a1"),
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([Class.align.middle]),
          .style(margin(top: .px(2)))
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
      .h6(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle8,
            Class.type.lineHeight(0),
            Class.pf.colors.fg.gray650,
            Class.padding([.mobile: [.all: 0]]),
            Class.margin([.mobile: [.all: 0]])
          ])
        ],
        .text(type.label)
      ),
      .p(
        attributes: [
          .class([
            Class.padding([.mobile: [.all: 0]]),
            Class.margin([.mobile: [.all: 0]]),
            Class.pf.colors.fg.gray650,
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
              Class.pf.colors.link.gray650,
              Class.pf.type.body.leading,
              Class.type.lineHeight(1)
            ]),
            .href(url(to: .episode(.show(.left(episode.slug)))))
          ],
          .text(episode.title)
        )
      )
    )
  )
}

private func currentEpisodeInfoRow(
  episode: Episode
) -> Node {
  .div(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]])
      ]),
      .style(backgroundColor(.rgba(250, 250, 250, 1.0)))
    ],
    .gridRow(
      attributes: [
        .class([Class.margin([.mobile: [.bottom: 2]])])
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
            .style(margin(top: .px(2)))
          ]
        )
      ),
      .gridColumn(
        sizes: [.mobile: 11],
        attributes: [
          .class([
            Class.pf.type.body.leading,
            Class.padding([.mobile: [.left: 1]]),
            Class.type.lineHeight(1)
          ])
        ],
        .text(episode.title)
      )
    ),
    chaptersRow(episode: episode),
    exercisesRow(episode: episode),
    referencesRow(episode: episode),
    downloadRow
  )
}

private func chaptersRow(episode: Episode) -> Node {
  let titleBlocks = episode.transcriptBlocks
    .filter { $0.type == .title && $0.timestamp != nil }

  return .div(
    attributes: [
      .class([
        Class.margin([.mobile: [.bottom: 2]]),
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
                Class.pf.type.body.small,
                Class.padding([.mobile: [.left: 1]])
              ]),
              .style(padding(topBottom: .px(2)))
            ],
            .a(
              attributes: [
                .href("#t\(block.timestamp ?? 0)")
              ],
              .text(block.content)
            )
          ),
          .gridColumn(
            sizes: [.mobile: 2],
            attributes: [
              .class([
                Class.pf.type.body.small,
                Class.pf.colors.fg.gray650
              ])
            ],
            .text(timestampLabel(for: block.timestamp ?? 0))
          )
        )
      }
    )
  )
}

private func exercisesRow(episode: Episode) -> Node {
  guard !episode.exercises.isEmpty else { return [] }
  return .gridRow(
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
          .style(margin(top: .px(2)))
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.leading,
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
          .style(margin(top: .px(2)))
        ]
      )
    ),
    .gridColumn(
      sizes: [.mobile: 11],
      attributes: [
        .class([
          Class.pf.type.body.leading,
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
        .style(margin(top: .px(2)))
      ]
    )
  ),
  .gridColumn(
    sizes: [.mobile: 11],
    attributes: [
      .class([
        Class.pf.type.body.leading,
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
          .desktop: [.leftRight: 3, .top: 0],
          .mobile: [.leftRight: 3, .top: 4, .bottom: 2],
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
          Class.padding([.mobile: [.top: 3]]),
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
        isEpisodeViewable: isEpisodeViewable
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
            .mobile: [.leftRight: 3, .bottom: 2],
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
      .style(key("border-top-color", "#333")),
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
        .div(
          attributes: [
            .class([
              Class.pf.colors.fg.gray650,
              Class.pf.type.body.small,
              Class.type.align.center,
              Class.type.caps,
            ]),
          ],
          .text("""
            Episode #\(episode.sequence) • \
            \(newEpisodeDateFormatter.string(from: episode.publishedAt)) \
            • \(episode.isSubscriberOnly(currentDate: date()) ? "Subscriber-only" : "Free Episode")
            """)
        ),
        .h1(
          attributes: [
            .class([
              Class.pf.colors.fg.white,
              Class.pf.type.responsiveTitle2,
              Class.type.align.center,
            ]),
            .style(lineHeight(1.2))
          ],
          .raw(nonBreaking(title: episode.title))
        ),
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1, .leftRight: 4]]),
              Class.pf.colors.fg.gray850,
              Class.pf.type.body.regular,
            ]),
          ],
          .text(episode.blurb)
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
