import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import VimeoClient
import PointFreeDependencies

public func vimeoVideoView(video: VimeoVideo, videoID: VimeoVideo.ID) -> Node {
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
            .raw(nonBreaking(title: video.name))
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
              \(video.type == .live ? "Livestream" : "Episode Clip") • Free • \
              \(headerDateFormatter.string(from: video.created))
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
            video.description.map { .markdownBlock($0) } ?? []
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
            )
          ],
          videoView(videoID: videoID)
        ),

        subscriberCalloutView
      )
    )
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
