import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import PointFreeDependencies
import Prelude
import Styleguide

public func liveView() -> Node {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.livestreams) var livestreams
  @Dependency(\.siteRouter) var siteRouter

  guard let activeLivestream = livestreams.first(where: { $0.isActive })
  else { return [] }

  let dateNode: Node
  if let scheduledAt = activeLivestream.scheduledAt {
    let messageNode: Node
    if activeLivestream.isLive {
      messageNode = [
        .span(
          attributes: [
            .style(safe: "animation: Pulse 3s linear infinite;")
          ],
          "🔴 "
        ),
        .text("We are live right now!")
      ]
    } else {
      messageNode = .text(
        "Scheduled for " + livestreamScheduledAtFormatter.string(from: scheduledAt)
      )
    }
    dateNode = .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 2]]),
          Class.pf.colors.fg.gray650,
          Class.pf.type.body.small,
          Class.type.align.center,
        ])
      ],
      messageNode
    )
  } else {
    dateNode = []
  }
  let loginNode: Node
  if currentUser == nil, !activeLivestream.isLive {
    loginNode = .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3, .bottom: 4],
          ]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.type.align.center,
          ]),
        ],
        .gitHubLink(
          text: "Log in to be notified",
          type: .white,
          href: siteRouter.loginPath(redirect: currentRoute),
          size: .regular
        )
      )
    )
  } else {
    loginNode = []
  }

  return .div(
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
            .mobile: [
              .leftRight: 3,
              .top: 4,
              .bottom: currentUser != nil || activeLivestream.isLive ? 4 : 3
            ],
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
          .raw(nonBreaking(title: activeLivestream.title))
        ),
        dateNode,
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1, .leftRight: 0], .desktop: [.leftRight: 4]]),
              Class.pf.colors.fg.gray850,
              Class.pf.type.body.regular,
            ])
          ],
          .markdownBlock(activeLivestream.description)
        )
      )
    ),

    loginNode,

    .gridRow(
      attributes: [
        .class([
          Class.pf.colors.bg.black
        ])
      ],
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 9],
        attributes: [
          .class([
            Class.grid.center(.desktop)
          ])
        ],
        .raw(
      """
      <div style="padding:56.25% 0 0 0;position:relative;">
        <iframe src="https://vimeo.com/event/\(activeLivestream.eventID)/embed"
                frameborder="0"
                allow="autoplay; fullscreen; picture-in-picture"
                allowfullscreen
                style="position:absolute;top:0;left:0;width:100%;height:100%;">
        </iframe>
      </div>
      """)
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 3],
        attributes: [
          .class([
            Class.grid.center(.desktop)
          ])
        ],
        .raw(
      """
      <iframe src="https://vimeo.com/event/\(activeLivestream.eventID)/chat/"
              width="100%"
              height="100%"
              frameborder="0"
              style="min-height: 30rem;">
      </iframe>
      """)
      )
    )
  )
}

private let livestreamScheduledAtFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .short
  return df
}()
