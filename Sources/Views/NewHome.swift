import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func newHomeView(
  currentDate: Date,
  currentUser: User?,
  subscriberState: SubscriberState,
  episodes: [Episode],
  date: () -> Date,
  emergencyMode: Bool
) -> Node {

//  let episodes = episodes.sorted(by: their(^\.sequence, >))
//
//  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
//  let firstBatch = episodes[0..<ctaInsertionIndex]
//  let secondBatch = episodes[ctaInsertionIndex...]

  func title(_ text: Node...) -> Node {
    .h1(
      attributes: [
        .class([
          Class.pf.colors.fg.white,
          Class.pf.type.responsiveTitle1,
          Class.type.align.center,
        ]),
        .style(lineHeight(1.2))
      ],
      .fragment(text)
    )
  }

  func subtitle(_ text: Node...) -> Node {
    .div(
      attributes: [
        .class([
          Class.pf.colors.fg.gray700,
          Class.pf.type.body.leading,
          Class.type.align.center,
        ]),
      ],
      .fragment(text)
    )
  }

  let trustedTeams: Node = .gridRow(
    attributes: [
      .class([
        Class.grid.middle(.mobile),
        Class.grid.center(.mobile),
        Class.padding([.mobile: [.bottom: 3, .leftRight: 3], .desktop: [.bottom: 4, .leftRight: 4]]),
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 12],
      attributes: [.class([Class.padding([.mobile: [.bottom: 3]])])],
      .h6(
        attributes: [
          .id("featured-teams"),
          .class([
            Class.pf.colors.fg.purple,
            Class.pf.type.responsiveTitle7,
            Class.type.align.center
          ]),
        ],
        "Trusted by teams"
      )
    ),
    .gridColumn(
      sizes: [.mobile: 6, .desktop: 2],
      attributes: [.class([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
      [.img(base64: nytLogoSvg(fill: "#a1a1a1"), type: .image(.svg), alt: "New York Times")]
    ),
    .gridColumn(
      sizes: [.mobile: 6, .desktop: 2],
      attributes: [.class([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
      [.img(base64: spotifyLogoSvg(fill: "#a1a1a1"), type: .image(.svg), alt: "Spotify")]
    ),
    .gridColumn(
      sizes: [.mobile: 6, .desktop: 2],
      [.img(base64: venmoLogoSvg(fill: "#a1a1a1"), type: .image(.svg), alt: "Venmo")]
    ),
    .gridColumn(
      sizes: [.mobile: 6, .desktop: 2],
      [.img(base64: atlassianLogoSvg(fill: "#a1a1a1"), type: .image(.svg), alt: "Atlassian")]
    )
  )

  let header: Node = .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
      ]),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .mobile: [.leftRight: 3, .topBottom: 4],
          ])
        ]),
        .style(maxWidth(.px(1184)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      .gridColumn(
        sizes: [:],
        attributes: [
          .class([
            Class.padding([.desktop: [.leftRight: 5]]),
          ]),
        ],
        title("Explore the wonderful world of functional Swift."),
        .div(
          attributes: [
            .class([
              Class.padding([
                .mobile: [.top: 1, .leftRight: 0],
                .desktop: [.leftRight: 5]
              ]),
            ]),
          ],
          subtitle(
            """
            Point-Free is a video series about combining functional programming concepts with the \
            Swift programming language.
            """
          )
        ),
        .div(
          attributes: [
            .class([
              Class.type.align.center,
              Class.padding([.mobile: [.top: 4]]),
            ])
          ],
          .a(
            attributes: [
              .class([
                Class.border.rounded.all,
                Class.pf.colors.bg.purple,
                Class.pf.colors.link.white,
                Class.padding([.mobile: [.leftRight: 3, .topBottom: 2]])
              ]),
              .href(url(to: .pricingLanding))
            ],
            "Start with a free episode →"
          )
        )
      )
    ),
    trustedTeams
  )

  return [
    header,
    whatToExpect,
    episodesSection(
      episodes: episodes.prefix(3),
      currentDate: currentDate,
      emergencyMode: emergencyMode
    ),
    collectionsSection()
  ]
}

func episodesSection<Episodes>(
  episodes: Episodes,
  currentDate: Date,
  emergencyMode: Bool
) -> Node
where
  Episodes: Sequence,
  Episodes.Element == Episode
{
  section(
    title: "Episodes",
    seeAllUrl: "#TODO",
    .fragment(
      episodes.map {
        episodeCard(
          episode: $0,
          currentDate: currentDate,
          emergencyMode: emergencyMode
        )
      }
    )
  )
}

func episodeCard(
  episode: Episode,
  currentDate: Date,
  emergencyMode: Bool
) -> Node {
  let isSubscriberOnly = episode.isSubscriberOnly(currentDate: currentDate, emergencyMode: emergencyMode)

  return card(
    .img(src: episode.image, alt: "", attributes: [
      .style(
        borderRadius(topLeft: .px(6), topRight: .px(6))
          <> maxWidth(.pct(100))
      ),
    ]),
    .div(
      attributes: [
        .class([
          Class.padding([.desktop: [.all: 2], .mobile: [.all: 2]]),
        ]),
      ],
      .div(
        attributes: [
          .class([
            Class.pf.colors.fg.gray500,
            Class.pf.type.body.small,
          ]),
        ],
        .text("Episode \(episode.sequence) • \(dateFormatter.string(from: episode.publishedAt))")
      ),
      .h2(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle4,
          ]),
        ],
        .text(episode.fullTitle)
      ),
      .div(
        attributes: [
          .class([
            Class.pf.colors.fg.gray400,
          ]),
          .style(flex(grow: 1, shrink: 0, basis: .auto)),
        ],
        .text(episode.blurb)
      ),
      .div(
        attributes: [
          .class([
            Class.padding([.mobile: [.top: 2, .bottom: 1]]),
            Class.pf.colors.fg.gray500,
            Class.pf.type.body.small,
          ]),
        ],
        .img(
          base64: isSubscriberOnly ? lockSvgBase64 : unlockSvgBase64,
          type: .image(.svg),
          alt: isSubscriberOnly ? "Locked padlock" : "Unlocked padlock",
          attributes: [
            .class([
              Class.padding([
                .mobile: [.right: 1],
              ])
            ])
          ]),
        isSubscriberOnly ? "Subscriber-only" : ""
      )
    )
  )
}

func cardFooter() -> Node {
  []
}

func collectionsSection() -> Node {
  section(
    title: "Collections",
    seeAllUrl: url(to: .collections(.index)),
    collectionCard(collection: .composableArchitecture),
    collectionCard(collection: .swiftUI),
    collectionCard(collection: .combine)
  )
}

//extension Node {
//  func padding() -> Node {
//
//  }
//}

func collectionCard(
  collection: Episode.Collection
) -> Node {
  card(
    .div(
      attributes: [
        .class([
          Class.padding([.desktop: [.all: 2], .mobile: [.all: 2]]),
        ]),
      ],
      .text(collection.blurb)
    )
  )
}

func card(
  _ body: Node...
) -> Node {
  .gridColumn(
    sizes: [.desktop: 4, .mobile: 12],
    attributes: [
      .class([
        Class.border.rounded.all,
        Class.flex.flex,
        Class.flex.column,
        Class.padding([.desktop: [.leftRight: 1], .mobile: [.bottom: 3]]),
      ])
    ],
    .div(
      attributes: [
        .class([
          Class.border.rounded.all,
          Class.flex.column,
        ]),
        .style(
          boxShadow(
            hShadow: .rem(0),
            vShadow: .px(1),
            blurRadius: .px(3),
            color: .rgba(0, 0, 0, 0.15)
          )
          <> boxShadow(
            hShadow: .rem(0),
            vShadow: .px(2),
            blurRadius: .px(8),
            color: .rgba(0, 0, 0, 0.05)
          )
        ),
      ],
      .fragment(body)
    )
  )
}

func section(
  title: String,
  seeAllUrl: String,
  _ body: Node...
) -> Node {
  .gridRow(
    attributes: [
      .class([
        Class.grid.middle(.desktop),
        Class.padding([
          .mobile: [.leftRight: 3, .topBottom: 3],
        ])
      ]),
      .style(maxWidth(.px(1184)) <> margin(leftRight: .auto)),
    ],

    .gridColumn(
      sizes: [.mobile: 6],
      .h2(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle2,
          ]),
        ],
        .text(title)
      )
    ),

    .gridColumn(
      sizes: [.mobile: 6],
      attributes: [
        .class([
          Class.type.align.end,
        ]),
      ],
      .a(
        attributes: [
          .class([
            Class.pf.colors.link.purple,
          ]),
          .href(seeAllUrl),
          .style(fontSize(.px(24))),
        ],
        "See all →"
      )
    ),

    .fragment(body)
  )
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .none
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return formatter
}()

#if DEBUG && os(macOS)
  import WebPreview

  struct HomePreviews: PreviewProvider {
    static var previews: some View {
      let node = simplePageLayout { _ in
        newHomeView(
          currentDate: Date(),
          currentUser: nil,
          subscriberState: .nonSubscriber,
          episodes: [
            .ep118_redactions_pt4,
            .ep117_redactions_pt3,
            .ep116_redactions_pt2,
          ],
          date: Date.init,
          emergencyMode: false
        )
      }(
        SimplePageLayoutData(
          currentUser: nil,
          data: (),
          style: .base(.some(.minimal(.black))),
          title: ""
        )
      )

      WebPreview(html: render(node))
      .previewLayout(.fixed(width: 1440, height: 3000))

      WebPreview(html: render(node))
      .previewLayout(.fixed(width: 414, height: 3000))
    }
  }
#endif
