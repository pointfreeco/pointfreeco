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

public func collectionIndex(_ collection: Episode.Collection) -> Node {
  [
    collectionHeader(collection),
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

private func collectionHeader(_ collection: Episode.Collection) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
      ]),
      .style(key("border-top-color", "#333")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3, .topBottom: 4],
          ]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [],
        .h1(
          attributes: [
            .class([
              Class.pf.colors.fg.white,
              Class.pf.type.responsiveTitle2,
              Class.type.align.center,
            ]),
            .style(lineHeight(1.2))
          ],
          .text(collection.title ?? "")
        ),
        .div(
          attributes: [
            .class([
              Class.pf.colors.fg.gray650,
              Class.pf.type.body.small,
              Class.type.align.center,
            ]),
          ],
          "Collection • \(String(collection.sections.count)) sections • \(collection.lengthDescription)"
        ),
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 3, .leftRight: 4]]),
              Class.pf.colors.fg.gray850,
              Class.pf.type.body.regular,
            ]),
          ],
          .text(collection.blurb ?? "")
        )
      )
    )
  )
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
      ]),
      .style(key("border-bottom-color", "#E8E8E8")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3, .topBottom: 2]
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
              Class.pf.type.responsiveTitle4,
              Class.type.light,
            ]),
          ],
          .text(section.title)
        )
      )
    )
  )
}

fileprivate extension Episode.Collection {
  var length: Seconds<Int> {
    self.sections
      .flatMap { $0.coreLessons.map { $0.episode.length } }
      .reduce(into: 0, +=)
  }

  var lengthDescription: String {
    let length = self.length.rawValue
    return "\(length / 3600)hr \((length / 60) % 60)min"
  }
}
