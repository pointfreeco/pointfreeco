import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

public func clipView(clip: Models.Clip) -> Node {
  @Dependency(\.subscriberState) var subscriberState

  return [
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
            .raw(nonBreaking(title: clip.title))
          ),
          .div(
            attributes: [
              .class([
                Class.padding([.mobile: [.bottom: 2]]),
                Class.pf.colors.fg.gray650,
                Class.pf.type.body.small,
                Class.type.align.center,
              ])
            ],
            .text(
              """
              Episode Clip • Free • \(headerDateFormatter.string(from: clip.createdAt))
              """)
          ),
          .div(
            attributes: [
              .class([
                Class.padding([.mobile: [.top: 1, .leftRight: 0], .desktop: [.leftRight: 4]]),
                Class.pf.colors.fg.gray850,
                Class.pf.type.body.regular,
              ])
            ],
            .markdownBlock(clip.blurb)
          )
        )
      )
    ),

    .div(
      attributes: [
        .class([
          Class.border.top
        ]),
        .style(key("border-top-color", "#333")),
      ],
      .gridRow(
        attributes: [
          .class([
            Class.grid.middle(.desktop),
            Class.padding([
              .desktop: [.leftRight: 3, .bottom: 4],
              .mobile: [.leftRight: 1, .bottom: 4],
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
            .class([
              Class.margin([.mobile: [.bottom: 4]])
            ]),
            .style(
              boxShadow(
                hShadow: .rem(0),
                vShadow: .rem(1),
                blurRadius: .px(20),
                color: .rgba(0, 0, 0, 0.2)
              )
            ),
          ],
          videoView(videoID: clip.vimeoVideoID)
        ),

        subscriberCalloutView
      )
    ),
  ]
}

public func clipsView(clips: [Models.Clip]) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.top: 3], .desktop: [.top: 4]]),
          Class.grid.between(.desktop),
        ]),
        .style(
          maxWidth(.px(1080))
          <> margin(leftRight: .auto)
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.padding([.mobile: [.bottom: 3, .leftRight: 2], .desktop: [.leftRight: 3]])
          ])
        ],
        .h3(
          attributes: [
            .class([Class.pf.type.responsiveTitle3])
          ],
          "Point-Free clips"
        ),
        .p(
          attributes: [],
          .text("""
            A collection of some of our favorite moments from Point-Free episodes.
            """)
        )
      )
    ),
    .ul(
      attributes: [
        .class([
          Class.margin([.mobile: [.all: 0]]),
          Class.padding([.mobile: [.all: 0], .desktop: [.leftRight: 2, .topBottom: 0]]),
          Class.type.list.styleNone,
          Class.flex.wrap,
          Class.flex.flex,
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .fragment(
        clips.enumerated().map { index, clip in
          cardView(
            title: clip.title,
            subtitle: nil,
            blurb: clip.blurb,
            url: siteRouter.path(for: .clips(.clip(videoID: clip.vimeoVideoID))),
            imageURL: clip.posterURL,
            index: index
          )
        }
      )
    ),
  ]
}

private func videoView(
  videoID: VimeoVideo.ID
) -> Node {
  return .div(
    attributes: [
      .class([outerVideoContainerClass]),
      .style(outerVideoContainerStyle),
    ],
    .iframe(
      attributes: [
        .class([innerVideoContainerClass]),
        .src("https://player.vimeo.com/video/\(videoID)?pip=1"),
        Attribute("frameborder", "0"),
        Attribute("allow", "autoplay; fullscreen"),
        Attribute("allowfullscreen", ""),
      ]
    ),
    .script(attributes: [.async(true), .src("https://player.vimeo.com/api/player.js")])
  )
}

private func cardView(
  title: String,
  subtitle: String? = nil,
  blurb: String,
  url: String,
  imageURL: String,
  index: Int
) -> ChildOf<Tag.Ul> {
  @Dependency(\.siteRouter) var siteRouter

  return .li(
    attributes: [
      .class([
        Class.padding([
          .mobile: [.top: 2, .bottom: 3, .leftRight: 2],
          .desktop: [.top: 0, .bottom: 4],
        ]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        cardClass,
      ])
    ],
    .div(
      attributes: [
        .class([
          Class.flex.column,
          Class.size.width100pct,
          Class.flex.flex,
          Class.border.rounded.all,
          Class.layout.overflowHidden,
          Class.border.all,
          Class.pf.colors.border.gray850,
        ])
      ],
      .a(
        attributes: [
          .class([
            Class.flex.flex,
            Class.flex.justify.center,
            Class.flex.align.center,
          ]),
          .href(url),
        ],
        .img(
          src: imageURL,
          alt: "",
          attributes: [
            .init("width", "100%")
          ]
        )
      ),
      .div(
        attributes: [
          .class([
            Class.padding([.mobile: [.top: 3, .leftRight: 3, .bottom: 2]])
          ])
        ],
        .h6(
          attributes: [
            .class([
              Class.pf.colors.fg.gray400,
              Class.type.normal,
              Class.pf.type.responsiveTitle8,
              Class.margin([.mobile: [.all: 0]]),
            ])
          ],
          subtitle.map { .text($0) } ?? []
        ),
        .h4(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle4,
              Class.type.normal,
              Class.margin([.mobile: [.top: 0]]),
            ])
          ],
          .a(
            attributes: [
              .href(url)
            ],
            .text(title)
          )
        ),
        .p(
          attributes: [
            .class([
              Class.padding([.mobile: [.all: 0]]),
              Class.pf.type.body.regular,
              Class.pf.colors.fg.black,
            ]),
            .style(flex(grow: 1, shrink: 0, basis: .auto)),
          ],
          .div(.markdownBlock(blurb))
        )
      )
    )
  )
}

public let cardStyles: Stylesheet =
Breakpoint.mobile.query(only: screen) {
  cardClass % width(.pct(100))
}
<> Breakpoint.desktop.query(only: screen) {
  cardClass % width(.pct(50))
}

private let cardClass = CssSelector.class("card")
