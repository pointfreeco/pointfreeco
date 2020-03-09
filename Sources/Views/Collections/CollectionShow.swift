import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import TaggedTime

// MARK: - HTML

public func collectionShow(_ collection: Episode.Collection) -> Node {
  [
    collectionNavigation(
      left: .a(
        attributes: [
          .href( path(to: .collections(.index))),
          .class([
            Class.pf.colors.link.gray650
          ])
        ],
        .text("Collections")
      )
    ),
    collectionHeader(
      title: collection.title,
      category: "Collection",
      subcategory: "section",
      subcategoryCount: collection.sections.count,
      length: collection.length,
      blurb: collection.blurb
    ),
    sectionsTitle,
    .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 4]])
        ]),
      ],
      .fragment(collection.sections.map { sectionRow(collection: collection, section: $0) })
    )
  ]
}

private let sectionsTitle = Node.div(
  attributes: [
    .class([
      Class.border.bottom,
    ]),
    .style(key("border-bottom-color", "#E8E8E8")),
  ],
  .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.top: 4]])
      ]),
      .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .class([
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3],
          ]),
        ]),
      ],
      .h2(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle3,
          ]),
        ],
        "Sections"
      )
    )
  )
)

private func sectionRow(
  collection: Episode.Collection,
  section: Episode.Collection.Section
) -> Node {
  .div(
    attributes: [
      .class([
        Class.border.bottom,
        Class.pf.collections.hoverBackground,
      ]),
      .style(key("border-bottom-color", "#E8E8E8")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3]
          ]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [],
        .a(
          attributes: [
            .class([
              Class.display.block,
              Class.grid.row,
              Class.padding([.mobile: [.topBottom: 2]]),
              Class.pf.collections.hoverLink,
              Class.pf.type.responsiveTitle4,
              Class.type.light,
            ]),
            .href(url(to: .collections(.section(collection.slug, section.slug)))),
          ],
          .gridRow(
            attributes: [
              .class([
                Class.align.middle,
              ]),
            ],
            .gridColumn(
              sizes: [.mobile: 6],
              .text(section.title)
            ),
            .gridColumn(
              sizes: [.mobile: 6],
              attributes: [
                .class([
                  Class.grid.end(.mobile),
                ]),
              ],
              .img(base64: rightChevronSvgBase64, type: .image(.svg), alt: "")
            )
          )
        )
      )
    )
  )
}
