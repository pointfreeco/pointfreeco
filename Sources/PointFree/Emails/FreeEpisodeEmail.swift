import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide

let freeEpisodeEmail = simpleEmailLayout(freeEpisodeEmailContent)
  .contramap { ep, user in
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

let freeEpisodeEmailContent = View<Episode> { ep in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])], [
          blockquote(
            [
              `class`(
                [
                  Class.padding([.mobile: [.all: 2]]),
                  Class.margin([.mobile: [.leftRight: 0, .topBottom: 3]]),
                  Class.pf.colors.bg.blue900,
                  Class.type.italic
                ]
              )
            ],
            [
              text(freeEpisodeBlurb),
              " Please consider ",
              a([href(url(to: .pricing(nil, expand: nil)))], ["supporting us"]),
              " so that we can keep new episodes coming!"
            ]
          ),

          a([href(url(to: .episode(.left(ep.slug))))], [
            h3(
              [`class`([Class.pf.type.responsiveTitle3])],
              [text("Episode #\(ep.sequence) is now free!")]
            )
            ]),

          h4(
            [`class`([Class.pf.type.responsiveTitle5])],
            [text(ep.title)]
          ),

          p([text(ep.blurb)]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .episode(.left(ep.slug))))], [
              img(src: ep.image, alt: "", [style(maxWidth(.pct(100)))])
              ])
            ]),

          p([text("This episode is \(ep.length / 60) minutes long.")]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .episode(.left(ep.slug)))), `class`([Class.pf.components.button(color: .purple)])],
              ["Watch now!"])
            ])
          ]
          <> hostSignOffView.view(unit))
        ])
      ])
    ])
}
