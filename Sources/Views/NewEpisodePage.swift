import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import Prelude
import Styleguide

public struct NewEpisodePageData {
  var permission: EpisodePermission
  var user: User?
  var subscriberState: SubscriberState
  var episode: Episode
  var previousEpisodes: [Episode]
  var date: () -> Date

  public init(
    permission: EpisodePermission,
    user: User?,
    subscriberState: SubscriberState,
    episode: Episode,
    previousEpisodes: [Episode],
    date: @escaping () -> Date
    ) {
    self.permission = permission
    self.user = user
    self.subscriberState = subscriberState
    self.episode = episode
    self.previousEpisodes = previousEpisodes
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
      episode: data.episode,
      isEpisodeViewable: isEpisodeViewable(for: data.permission)
    )
  ]
}

private func toc(
  episode: Episode
) -> Node {
  .div(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        Class.border.all,
        Class.border.rounded.all,
        Class.pf.colors.border.gray850,
      ])
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
          base64: playIconSvgBase64,
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
          ]),
          .style(unsafe: """
overflow: hidden;
text-overflow: ellipsis;
white-space: nowrap;
""")
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
            .text(block.content)
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
      "Exercises"
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
      "References"
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
    "Downloads"
  )
)

private func mainContent(
  episode: Episode,
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
          Class.margin([.mobile: [.top: 3]])
        ])
      ],
      toc(episode: episode)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      transcriptView(
        blocks: episode.transcriptBlocks,
        isEpisodeViewable: isEpisodeViewable
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
