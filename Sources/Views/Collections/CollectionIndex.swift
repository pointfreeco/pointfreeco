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
      Episode.Collection.all.map(collectionItem(collection:))
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
    .a(
      attributes: [
        .class([
          Class.flex.column,
          Class.size.width100pct,
          Class.flex.flex,
          Class.border.rounded.all
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
          .style(unsafe: #"""
background: rgb(110,56,186);
background: linear-gradient(0deg, rgba(110,56,186,1) 0%, rgba(151,77,255,1) 25%, rgba(121,242,176,1) 100%);
"""#)
        ],
        .img(
          base64: collectionsIconSvgBase64,
          type: .image(.svg),
          alt: "",
          attributes: [
            .style(margin(topBottom: .rem(6)))
          ]
        )
      ),
      .div(
        attributes: [
          .class([Class.padding([.mobile: [.all: 2]])])
        ],
        .h6(
          attributes: [
            .class([Class.pf.type.responsiveTitle7])
          ],
          .text("Collection")
        ),
        .h4(
          attributes: [
            .class([Class.pf.type.responsiveTitle4])
          ],
          // TODO: figure out force unwrap
          .text(collection.title!)
        ),
        .p(
          attributes: [
            .class([
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
  )
}


