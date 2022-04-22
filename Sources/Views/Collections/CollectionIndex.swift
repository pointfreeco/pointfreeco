import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Styleguide
import Prelude

public func collectionIndex(
  collections: [Episode.Collection]
) -> Node {
  [
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.top: 3], .desktop: [.top: 4]]),
          Class.grid.between(.desktop)
        ]),
        .style(
          maxWidth(.px(1080))
            <> margin(leftRight: .auto)
        )
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.padding([.mobile: [.bottom: 2, .leftRight: 2], .desktop: [.leftRight: 3]])
          ])
        ],
        .h3(
          attributes: [
            .class([Class.pf.type.responsiveTitle2])
          ],
          "Episode Collections"
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
          Class.flex.flex
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      .fragment(
        collections.enumerated().map { idx, collection in
          collectionItem(collection: collection, index: idx)
        }
      )
    )
  ]
}

private let colors = ["#4cccff", "#79f2b0", "#fff080", "#974dff"]
private let combos = colors
  .flatMap { color in colors.map { (color, $0) } }
  .filter { $0 != $1 }

private func collectionItem(collection: Episode.Collection, index: Int) -> ChildOf<Tag.Ul> {
  let (lower, upper) = combos[index % combos.count]

  return .li(
    attributes: [
      .class([
        Class.padding([
          .mobile: [.top: 2, .bottom: 3, .leftRight: 2],
          .desktop: [.top: 0, .bottom: 4]
        ]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        itemClass
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
            Class.flex.align.center
          ]),
          .href(siteRouter.url(for: .collections(.show(collection.slug)))),
          .style(unsafe: """
            background: \(lower);
            background: linear-gradient(\(index * 45)deg, \(lower) 0%, \(upper) 100%);
            """)
        ],
        .img(
          base64: collectionsIconSvgBase64,
          type: .image(.svg),
          alt: "",
          attributes: [
            .style(margin(topBottom: .rem(5)))
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
              Class.margin([.mobile: [.all: 0]])
            ])
          ],
          .text("Collection")
        ),
        .h4(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle4,
              Class.type.normal,
              Class.margin([.mobile: [.top: 0]])
            ])
          ],
          .a(
            attributes: [
              .href(siteRouter.url(for: .collections(.show(collection.slug))))
            ],
            .text(collection.title)
          )
        ),
        .p(
          attributes: [
            .class([
              Class.padding([.mobile: [.all: 0]]),
              Class.pf.type.body.regular,
              Class.pf.colors.fg.black
            ]),
            .style(flex(grow: 1, shrink: 0, basis: .auto))
          ],
          .div(.markdownBlock(collection.blurb))
        )
        // TODO: bring this back when we have time
//        .a(
//          attributes: [
//            // TODO: figure out force unwrap
//            .href(url(to: .collections(.show(collection.slug!)))),
//            .class([
//              Class.align.middle,
//              Class.pf.colors.link.purple,
//              Class.pf.type.body.regular,
//              Class.margin([.mobile: [.top: 4]])
//            ])
//          ],
//          .text("See collection (\(10) episodes)"),
//          .img(
//            base64: rightArrowSvgBase64(fill: "#974DFF"),
//            type: .image(.svg),
//            alt: "",
//            attributes: [.class([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), .width(16), .height(16)]
//          )
//        )
      )
    )
  )
}

public let collectionIndexStyles: Stylesheet
  = Breakpoint.mobile.query(only: screen) {
    itemClass % width(.pct(100))
    }
    <> Breakpoint.desktop.query(only: screen) {
      itemClass % width(.pct(50))
}

private let itemClass = CssSelector.class("collection-item")
