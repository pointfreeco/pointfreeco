import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Styleguide
import Prelude

public let collectionIndex: Node = [
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
        .class([Class.padding([.desktop: [.bottom: 2]])])
      ],
      .h3(
        attributes: [
          .class([Class.pf.type.responsiveTitle2])
        ],
        "Collections"
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
      Episode.Collection.all.enumerated().map { idx, collection in
        collectionItem(collection: collection, index: idx)
      }
    )
  )
]

private func collectionItem(collection: Episode.Collection, index: Int) -> ChildOf<Tag.Ul> {
  let colors = ["#4cccff", "#79f2b0", "#fff080", "#974dff"]
  let combos = colors
    .flatMap { color in colors.map { (color, $0) } }
    .filter { $0 != $1 }
  let (lower, upper) = combos[index % combos.count]
  print("lower", lower, "upper", upper)

  return .li(
    attributes: [
      .class([
        Class.padding([
          .mobile: [.top: 2, .bottom: 3, .leftRight: 2],
          .desktop: [.top: 0, .bottom: 4, .leftRight: 3]
        ]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        itemClass
      ])
      //      .style(width(.pct(100)))
    ],
    .a(
      attributes: [
        .class([
          Class.flex.column,
          Class.size.width100pct,
          Class.flex.flex,
          Class.border.rounded.all,
          Class.layout.overflowHidden,
          Class.border.all,
          Class.pf.colors.border.gray850,
        ]),
        // TODO: figure out force unwrap
        .href(url(to: .collections(.show(collection.slug!))))
      ],
      .div(
        attributes: [
          .class([
            Class.flex.flex,
            Class.flex.justify.center,
            Class.flex.align.center
          ]),
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
          // TODO: figure out force unwrap
          .text(collection.title!)
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
          // TODO: handle force unwrap
          .text(collection.blurb!)
          // TODO: link
        )
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
