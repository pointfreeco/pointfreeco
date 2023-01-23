import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import Styleguide
import Views

func liveMiddleware(
  _ conn: Conn<StatusLineOpen, Int>
) async -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(
      view: liveView,
      layoutData: { id in
        SimplePageLayoutData(
          data: id,
          description: """
            Now streaming live!
            """,
          style: .base(.minimal(.black)),
          title: "Point-Free Live"
        )
      }
    )
}

func liveView(id: Int) -> Node {
  .gridRow(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [
        .class([
          Class.grid.center(.desktop),
        ])
      ],
      .raw(
        """
        <div style="padding:56.25% 0 0 0;position:relative;">
          <iframe src="https://vimeo.com/event/\(id)/embed"
                  frameborder="0"
                  allow="autoplay; fullscreen; picture-in-picture"
                  allowfullscreen
                  style="position:absolute;top:0;left:0;width:100%;height:100%;">
          </iframe>
        </div>
        """)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 4],
      attributes: [
        .class([
          Class.grid.center(.desktop),
        ])
      ],
      .raw(
        """
        <iframe src="https://vimeo.com/event/\(id)/chat/"
                width="100%"
                height="100%"
                frameborder="0"
                style="min-height: 30rem;">
        </iframe>
        """)
    )
  )
}
