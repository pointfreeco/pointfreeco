import Css
import Either
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Views

public let newEpisodeEmail =
  simpleEmailLayout(newEpisodeEmailContent)
  <<< { episode, subscriberAnnouncement, nonSubscriberAnnouncement, user in
    SimpleEmailLayoutData(
      user: user,
      newsletter: .newEpisode,
      title: "New Point-Free Episode: \(episode.fullTitle)",
      preheader: episode.blurb,
      template: .default(),
      data: (
        episode,
        user.subscriptionId != nil
          ? subscriberAnnouncement
          : nonSubscriberAnnouncement,
        user.subscriptionId != nil
      )
    )
  }

func newEpisodeEmailContent(ep: Episode, announcement: String?, isSubscriber: Bool) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          announcementView(announcement: announcement),
          .a(
            attributes: [.href(siteRouter.url(for: .episode(.show(.left(ep.slug)))))],
            .h3(
              attributes: [.class([Class.pf.type.responsiveTitle3])],
              .text("#\(ep.sequence): \(ep.fullTitle)"))
          ),
          .markdownBlock(ep.blurb),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [.href(siteRouter.url(for: .episode(.show(.left(ep.slug)))))],
              .img(attributes: [.src(ep.image), .alt(""), .style(maxWidth(.pct(100)))])
            )
          ),
          nonSubscriberCtaView(ep: ep, isSubscriber: isSubscriber),
          subscriberCtaView(ep: ep, isSubscriber: isSubscriber),
          hostSignOffView
        )
      )
    )
  )
}

private func announcementView(announcement: String?) -> Node {
  guard let announcement = announcement, !announcement.isEmpty else { return [] }

  return .blockquote(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.leftRight: 0, .topBottom: 3]]),
        Class.pf.colors.bg.blue900,
        Class.type.italic,
      ])
    ],
    .h5(attributes: [.class([Class.pf.type.responsiveTitle5])], "Announcements"),
    .markdownBlock(announcement)
  )
}

private func nonSubscriberCtaView(ep: Episode, isSubscriber: Bool) -> Node {
  guard !isSubscriber else { return [] }

  let blurb =
    ep.subscriberOnly
    ? "This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber today!"
    : "This episode is free for everyone, made possible by our subscribers. Consider becoming a subscriber today!"

  let watchText =
    ep.subscriberOnly
    ? "Watch preview"
    : "Watch"

  return [
    .p(.text(blurb)),
    .p(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
      .a(
        attributes: [
          .href(siteRouter.url(for: .pricingLanding)),
          .class([Class.pf.components.button(color: .purple)]),
        ],
        "Subscribe to Point-Free!"
      ),
      .a(
        attributes: [
          .href(siteRouter.url(for: .episode(.show(.left(ep.slug))))),
          .class([
            Class.pf.components.button(color: .black, style: .underline), Class.display.inlineBlock,
          ]),
        ],
        .text(watchText)
      )
    ),
  ]
}

private func subscriberCtaView(ep: Episode, isSubscriber: Bool) -> Node {
  guard isSubscriber else { return [] }

  return [
    .p(.text("This episode is \(ep.length.rawValue / 60) minutes long.")),
    .p(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
      .a(
        attributes: [
          .href(siteRouter.url(for: .episode(.show(.left(ep.slug))))),
          .class([Class.pf.components.button(color: .purple)]),
        ],
        "Watch now!"
      )
    ),
  ]
}
