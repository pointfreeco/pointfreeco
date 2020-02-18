import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import Prelude
import Styleguide

let freeEpisodeEmail = simpleEmailLayout(freeEpisodeEmailContent) <<< { ep, user in
  SimpleEmailLayoutData(
    user: user,
    newsletter: .newEpisode,
    title: "Point-Freebie: \(ep.title)",
    preheader: freeEpisodeBlurb,
    template: .default,
    data: ep
  )
}

let freeEpisodeBlurb = """
Every once in awhile we release a past episode for free to all of our viewers, and today is that day!
"""

func freeEpisodeEmailContent(ep: Episode) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          .blockquote(
            attributes: [
              .class([
                Class.padding([.mobile: [.all: 2]]),
                Class.margin([.mobile: [.leftRight: 0, .topBottom: 3]]),
                Class.pf.colors.bg.blue900,
                Class.type.italic
              ])
            ],
            .text(freeEpisodeBlurb),
            " Please consider ",
            .a(attributes: [.href(url(to: .pricingLanding))], "supporting us"),
            " so that we can keep new episodes coming!"
          ),
          .a(
            attributes: [.href(url(to: .episode(.show(.left(ep.slug)))))],
            .h3(
              attributes: [.class([Class.pf.type.responsiveTitle3])],
              .text("Episode #\(ep.sequence) is now free!")
            )
          ),
          .h4(
            attributes: [.class([Class.pf.type.responsiveTitle5])],
            .text(ep.title)
          ),
          .p(.text(ep.blurb)),
          .p(attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
             .a(
              attributes: [.href(url(to: .episode(.show(.left(ep.slug)))))],
              .img(attributes: [.src(ep.image), .alt(""), .style(maxWidth(.pct(100)))])
            )
          ),
          .p(.text("This episode is \(ep.length / 60) minutes long.")),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(url(to: .episode(.show(.left(ep.slug))))),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "Watch now!"
            )
          ),
          hostSignOffView
        )
      )
    )
  )
}
