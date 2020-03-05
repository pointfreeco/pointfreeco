import Css
import EmailAddress
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

public func collectionIndex(_ collection: Episode.Collection) -> Node {
  [
    collectionHeader(
      title: collection.title ?? "",
      category: "Collection",
      subcategory: "sections",
      subcategoryCount: collection.sections.count,
      length: collection.length,
      blurb: collection.blurb ?? ""
    ),
    sectionsTitle,
    .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 5]])
        ]),
      ],
      .fragment(collection.sections.map(sectionRow))
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
        Class.grid.between(.desktop),
      ]),
      .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .class([
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3, .topBottom: 2],
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

private func sectionRow(_ section: Episode.Collection.Section) -> Node {
  .div(
    attributes: [
      .class([
        Class.border.bottom,
        Class.private.hoverBackground,
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
              Class.private.hoverLink,
              Class.pf.type.responsiveTitle4,
              Class.type.light,
            ]),
            .href("#TODO"),
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

// MARK: - Stylesheet

public let collectionIndexStylesheet = Stylesheet.concat(
  (Class.private.hoverBackground & .pseudo(.hover)) % backgroundColor(.white(0.9)),
  (Class.private.hoverLink & .pseudo(.hover)) % key("text-decoration", "none")
)

fileprivate extension Class {
  enum `private` {
    static let hoverBackground = CssSelector.class("col-idx-hover")
    static let hoverLink = CssSelector.class("col-idx-hover")
  }
}
