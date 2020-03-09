import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Styleguide
import Prelude

public let collectionIndex: Node = .gridRow(
  attributes: [
    .style(
      maxWidth(.px(1080))
        <> margin(leftRight: .auto)
    )
  ],
  .gridColumn(
    sizes: [.mobile: 12, .desktop: 7],
    .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])
        ])
      ],
      .h3(
        attributes: [
          .class([Class.h3])
        ],
        "Collections"
      ),
      .ul(
        .fragment(
          Episode.Collection.all.map { collection in
            .li(
              .a(
                attributes: [
                  // TODO: deal with optional slug
                  .href(url(to: .collections(.show(collection.slug ?? ""))))
                ],
                // TODO: does title need to be optional?
                .text(collection.title ?? "")
              )
            )
          }
        )
      )
    )
  )
)
