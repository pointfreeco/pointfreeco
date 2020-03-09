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
        Class.padding([.mobile: [.leftRight: 2, .top: 3], .desktop: [.leftRight: 4, .top: 4]]),
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
      []
//      Episode.Collection.
    )
  )
]

private func collectionItem(collection: Episode.Collection) -> ChildOf<Tag.Ul> {
  .li(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 1]]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
      ]),
      .style(width(.pct(50)))
    ],
    .div(
      attributes: [
        .class([
          Class.pf.colors.bg.gray900,
          Class.flex.column,
          Class.padding([.mobile: [.all: 2]]),
          Class.size.width100pct,
          Class.flex.flex,
        ]),
      ],
      .p(
        attributes: [
          .class([
            Class.type.list.styleNone,
            Class.padding([.mobile: [.all: 0]]),
            Class.pf.colors.fg.gray400,
            Class.pf.type.body.regular,
            Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
            Class.pf.colors.fg.gray400
            ]),
          .style(flex(grow: 1, shrink: 0, basis: .auto))
        ],
        // TODO: handle force unwrap
        .text(collection.blurb!)
        // TODO: link
      )
    )
  )
}
//background: rgb(110,56,186);
//background: linear-gradient(0deg, rgba(110,56,186,1) 0%, rgba(151,77,255,1) 25%, rgba(121,242,176,1) 100%);


