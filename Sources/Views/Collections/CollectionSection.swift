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

public func collectionSection(
  _ collection: Episode.Collection,
  _ section: Episode.Collection.Section
) -> Node {
  [
    collectionNavigation(
      left: zip(collection.title, collection.slug)
        .map { ($0, url(to: .collections(.show($1)))) }
    ),
    collectionHeader(
      title: section.title,
      category: "Section",
      subcategory: "episode",
      subcategoryCount: section.coreLessons.count,
      length: section.length,
      blurb: section.blurb
    ),
    coreLessons(section.coreLessons),
    relatedItems(section.related),
    whereToGoFromHere(section.whereToGoFromHere),
    sectionNavigation(),
  ]
}

private func coreLessons(_ lessons: [Episode.Collection.Section.Lesson]) -> Node {
  .div(
    attributes: [
      .style(backgroundColor(.other("#fafafa"))),
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
              .desktop: [.leftRight: 5, .top: 3, .bottom: 4],
              .mobile: [.leftRight: 3, .topBottom: 2],
            ]),
          ]),
        ],
        .h2(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 1]]),
              Class.pf.type.responsiveTitle4,
            ]),
          ],
          "Core lessons"
        ),
        .fragment(lessons.map(coreLesson))
      )
    )
  )
}

private func coreLesson(_ lesson: Episode.Collection.Section.Lesson) -> Node {
  .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .style(margin(top: .px(4))),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.border.left,
          Class.padding([.mobile: [.leftRight: 2]]),
          Class.flex.items.center,
          Class.pf.colors.border.gray800,
          Class.pf.colors.bg.white,
        ]),
        .style(
          borderColor(all: .other("#e8e8e8"))
            <> borderWidth(left: .px(4))
            <> height(.px(48))
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 9],
        attributes: [
          .class([
            Class.grid.start(.mobile),
          ]),
        ],
        .text(lesson.episode.title)
      ),
      .gridColumn(
        sizes: [.mobile: 3],
        attributes: [
          .class([
            Class.grid.end(.mobile),
          ]),
        ],
        .text(lesson.episode.length.formattedDescription)
      )
    )
  )
}

private func relatedItems(_ relatedItems: [Episode.Collection.Section.Related]) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.white,
      ]),
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
              .desktop: [.leftRight: 5, .top: 3],
              .mobile: [.leftRight: 3, .top: 2],
            ]),
          ]),
        ],
        .h2(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 1]]),
              Class.pf.type.responsiveTitle4,
            ]),
          ],
          "Related episodes"
        ),
        .fragment(relatedItems.map(relatedItem))
      )
    )
  )
}

private func relatedItem(_ relatedItem: Episode.Collection.Section.Related) -> Node {
  guard case let .episode(episode) = relatedItem.content else { return [] }
  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .style(margin(top: .px(4))),
    ],
    .markdownBlock(relatedItem.blurb),
    .gridRow(
      attributes: [
        .class([
          Class.border.left,
          Class.margin([
            .desktop: [.top: 2, .bottom: 3],
            .mobile: [.top: 1, .bottom: 2],
          ]),
          Class.padding([.mobile: [.leftRight: 2]]),
          Class.flex.items.center,
          Class.pf.colors.border.gray800,
          Class.pf.colors.bg.gray900,
        ]),
        .style(
          backgroundColor(.other("#fafafa"))
          <> borderColor(all: .other("#e8e8e8"))
          <> borderWidth(left: .px(4))
          <> height(.px(48))
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 9],
        attributes: [
          .class([
            Class.grid.start(.mobile),
          ]),
        ],
        .text(episode.title)
      ),
      .gridColumn(
        sizes: [.mobile: 3],
        attributes: [
          .class([
            Class.grid.end(.mobile),
          ]),
        ],
        .text(episode.length.formattedDescription)
      )
    )
  )
}

private func whereToGoFromHere(_ string: String) -> Node {
  .div(
    attributes: [
      .style(backgroundColor(.other("#fafafa"))),
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
              .desktop: [.leftRight: 5, .top: 3, .bottom: 4],
              .mobile: [.leftRight: 3, .topBottom: 2],
            ]),
          ]),
        ],
        .h2(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 1]]),
              Class.pf.type.responsiveTitle4,
            ]),
          ],
          "Where to go from here"
        ),
        .markdownBlock(string)
      )
    )
  )
}

private func sectionNavigation() -> Node {
  .div(
    attributes: [
      .class([
        Class.border.top,
      ]),
      .style(
        backgroundColor(.other("#fafafa"))
          <> borderColor(top: .other("#e8e8e8"))
      ),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.center(.mobile),
        ]),
        .style(
          height(.px(88))
            <> maxWidth(.px(1080))
            <> margin(topBottom: nil, leftRight: .auto)
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 6],
        attributes: [
          .class([
            Class.border.right
          ]),
          .style(borderColor(right: .other("#e8e8e8"))),
        ],
        ""
      ),
      .gridColumn(
        sizes: [.mobile: 6],
        attributes: [
          .class([
            Class.grid.end(.mobile),
            Class.padding([
              .desktop: [.leftRight: 5, .top: 3, .bottom: 4],
              .mobile: [.leftRight: 3, .topBottom: 2],
            ]),
          ]),
        ],
        ""
      )
    )
  )
}

private extension Seconds where RawValue == Int {
  var formattedDescription: String {
    "\(self.rawValue / 60) min"
  }
}
