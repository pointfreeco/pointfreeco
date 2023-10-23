import Css
import Dependencies
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
  @Dependency(\.siteRouter) var siteRouter

  let currentIndex = collection.sections.firstIndex(where: { $0 == section })
  let previousSection = currentIndex.flatMap {
    $0 == collection.sections.startIndex
      ? nil
      : collection.sections[collection.sections.index(before: $0)]
  }
  let nextSection = currentIndex.flatMap {
    $0 == collection.sections.index(before: collection.sections.endIndex)
      ? nil
      : collection.sections[collection.sections.index(after: $0)]
  }

  return [
    collectionNavigation(
      left: .a(
        attributes: [
          .href(
            siteRouter.path(
              for: .collections(
                collection.sections.count == 1 ? .index : .collection(collection.slug)
              )
            )
          ),
          .class([
            Class.pf.colors.link.gray650
          ]),
        ],
        .text(collection.sections.count == 1 ? "Collections" : collection.title)
      )
    ),
    collectionHeader(
      title: section.title,
      category: "Section",
      subcategory: "episode",
      subcategoryCount: section.coreLessons.count,
      length: section.length,
      blurb: section.blurb
    ),
    coreLessons(collection: collection, section: section),
    relatedItems(section.related),
    whereToGoFromHere(section.whereToGoFromHere),
    sectionNavigation(
      collection: collection,
      previousSection: previousSection,
      nextSection: nextSection
    ),
  ]
}

private func coreLessons(
  collection: Episode.Collection,
  section: Episode.Collection.Section
) -> Node {
  @Dependency(\.episodes) var episodes

  return .div(
    attributes: [
      .style(backgroundColor(.other("#fafafa")))
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.between(.desktop)
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.padding([
              .desktop: [.leftRight: 5, .top: 3, .bottom: 4],
              .mobile: [.leftRight: 3, .top: 2, .bottom: 3],
            ])
          ])
        ],
        .h2(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 1]]),
              Class.pf.type.responsiveTitle4,
            ])
          ],
          "Core lessons"
        ),
        .fragment(
          section.coreLessons
            .map {
              coreLesson(collection: collection, section: section, lesson: $0)
            }
            + (section.isFinished ? [] : [moreComingSoon])
        )
      )
    )
  )
}

private func coreLesson(
  collection: Episode.Collection,
  section: Episode.Collection.Section,
  lesson: Episode.Collection.Section.Lesson
) -> Node {
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  let isActive = lesson.episode.publishedAt <= now
  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .style(margin(top: .px(4)))
    ],
    contentRow(
      backgroundColor: Class.pf.colors.bg.white,
      icon: isActive ? playIconSvgBase64() : hourGlassSvgBase64(fill: "666"),
      title: lesson.episode.fullTitle,
      length: lesson.episode.length,
      url: siteRouter.path(
        for: .collections(
          .collection(collection.slug, .section(section.slug, .episode(.left(lesson.episode.slug))))
        )
      ),
      isActive: isActive
    )
  )
}

private func relatedItems(_ relatedItems: [Episode.Collection.Section.Related]) -> Node {
  guard !relatedItems.isEmpty else { return [] }
  return .div(
    attributes: [
      .class([
        Class.pf.colors.bg.white
      ])
    ],
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.topBottom: 2], .desktop: [.topBottom: 3]])
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
            ])
          ])
        ],
        .h2(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle4
            ])
          ],
          "Related content"
        ),
        .fragment(relatedItems.map(relatedItem))
      )
    )
  )
}

private func relatedItem(_ relatedItem: Episode.Collection.Section.Related) -> Node {
  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.padding([.mobile: [.bottom: 2]])
      ])
    ],
    .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 1, .top: 1]])
        ])
      ],
      .markdownBlock(relatedItem.blurb)
    ),
    relatedItemContent(relatedItem.content)
  )
}

private func relatedItemContent(_ content: Episode.Collection.Section.Related.Content) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  switch content {
  case let .collections(collections):
    return .fragment(
      collections().map { collection in
        contentRow(
          backgroundColor: Class.pf.colors.bg.gray900,
          icon: collectionIconSvgBase64,
          title: collection.title,
          length: collection.length,
          url: siteRouter.path(for: .collections(.collection(collection.slug)))
        )
      })
  case let .episodes(episodes):
    return .fragment(
      episodes().map { episode in
        contentRow(
          backgroundColor: Class.pf.colors.bg.gray900,
          icon: playIconSvgBase64(),
          title: episode.fullTitle,
          length: episode.length,
          url: siteRouter.path(for: .episode(.show(.left(episode.slug))))
        )
      })
  case let .section(collection, index):
    let collection = collection()
    let section = collection.sections[index]
    return contentRow(
      backgroundColor: Class.pf.colors.bg.gray900,
      icon: collectionIconSvgBase64,
      title: section.title,
      length: section.length,
      url: siteRouter.path(for: .collections(.collection(collection.slug, .section(section.slug))))
    )
  }
}

private func whereToGoFromHere(_ string: String?) -> Node {
  guard let string = string else { return [] }
  return .div(
    attributes: [
      .style(backgroundColor(.other("#fafafa")))
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.between(.desktop)
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.padding([
              .desktop: [.leftRight: 5, .top: 3, .bottom: 4],
              .mobile: [.leftRight: 3, .top: 2, .bottom: 3],
            ])
          ])
        ],
        .h2(
          attributes: [
            .class([
              Class.padding([.mobile: [.bottom: 1]]),
              Class.pf.type.responsiveTitle4,
            ])
          ],
          "Where to go from here"
        ),
        .markdownBlock(string)
      )
    )
  )
}

private func sectionNavigation(
  collection: Episode.Collection,
  previousSection: Episode.Collection.Section?,
  nextSection: Episode.Collection.Section?
) -> Node {
  guard previousSection != nil || nextSection != nil else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  let previousLink = previousSection.map { section in
    Node.a(
      attributes: [
        .class([
          Class.grid.row
        ]),
        .href(
          siteRouter.url(for: .collections(.collection(collection.slug, .section(section.slug))))
        ),
      ],
      .img(
        base64: leftChevronSvgBase64, type: .image(.svg), alt: "",
        attributes: [
          .class([
            Class.padding([
              .mobile: [.right: 1],
              .desktop: [.right: 2],
            ])
          ])
        ]),
      .gridColumn(
        sizes: [:],
        .div(
          attributes: [
            .class([
              Class.pf.type.body.small
            ])
          ],
          "Back to"
        ),
        .div(
          attributes: [
            .class([
              Class.type.semiBold
            ])
          ],
          .text(section.title)
        )
      )
    )
  }

  let nextLink = nextSection.map { section in
    Node.a(
      attributes: [
        .class([
          Class.grid.row
        ]),
        .href(
          siteRouter.url(for: .collections(.collection(collection.slug, .section(section.slug))))
        ),
      ],
      .gridColumn(
        sizes: [:],
        .div(
          attributes: [
            .class([
              Class.pf.type.body.small
            ])
          ],
          "Next up"
        ),
        .div(
          attributes: [
            .class([
              Class.type.semiBold
            ])
          ],
          .text(section.title)
        )
      ),
      .img(
        base64: rightChevronSvgBase64, type: .image(.svg), alt: "",
        attributes: [
          .class([
            Class.padding([
              .mobile: [.left: 1],
              .desktop: [.left: 2],
            ])
          ])
        ])
    )
  }

  return Node.div(
    attributes: [
      .class([
        Class.border.top
      ]),
      .style(
        backgroundColor(.other("#fafafa"))
          <> borderColor(top: .other("#e8e8e8"))
      ),
    ],
    Node.gridRow(
      attributes: [
        .class([
          Class.flex.items.center,
          Class.grid.center(.mobile),
          Class.padding([
            .desktop: [.leftRight: 5],
            .mobile: [.leftRight: 3],
          ]),
        ]),
        .style(
          maxWidth(.px(1080))
            <> margin(topBottom: nil, leftRight: .auto)
        ),
      ],
      .gridColumn(
        sizes: [.mobile: 6],
        attributes: [
          .class([
            Class.border.right,
            Class.grid.start(.mobile),
            Class.padding([
              .mobile: [.topBottom: 3]
            ]),
          ]),
          .style(borderColor(right: .other("#e8e8e8"))),
        ],
        previousLink ?? []
      ),
      .gridColumn(
        sizes: [.mobile: 6],
        attributes: [
          .class([
            Class.grid.end(.mobile),
            Class.padding([.mobile: [.topBottom: 3]]),
          ])
        ],
        nextLink ?? []
      )
    )
  )
}

private func contentRow(
  backgroundColor: CssSelector,
  icon: String,
  title: String,
  length: Seconds<Int>,
  url: String,
  isActive: Bool = true
) -> Node {

  let coreContent: Node = [
    .img(
      base64: icon,
      type: .image(.svg),
      alt: "",
      attributes: [.class([Class.padding([.mobile: [.right: 1]])])]
    ),
    .div(
      attributes: [.style(flex(grow: 1))],
      .text(title),
      isActive
        ? []
        : .div(
          attributes: [
            .style(flex(grow: 1)),
            .class([
              Class.pf.colors.fg.gray400,
              Class.type.italic,
            ]),
          ],
          .text("Not yet released!")
        )
    ),
    .div(
      attributes: [
        .class([
          Class.padding([.mobile: [.left: 1]])
        ]),
        .style(
          flex(wrap: .nowrap)
            <> key("font-variant-numeric", "tabular-nums")
        ),
      ],
      length > 0
        ? .raw(length.formattedDescription.replacingOccurrences(of: " ", with: "&nbsp;"))
        : []
    ),
  ]

  if isActive {
    return .a(
      attributes: [
        .class([
          Class.border.left,
          Class.flex.items.center,
          Class.grid.row,
          Class.padding([.mobile: [.leftRight: 2, .topBottom: 2]]),
          Class.pf.collections.hoverBackground,
          Class.pf.collections.hoverLink,
          Class.pf.colors.border.gray800,
          backgroundColor,
        ]),
        .href(url),
        .style(
          borderColor(all: .other("#e8e8e8"))
            <> borderWidth(left: .px(4))
            <> margin(top: .px(4))
            <> flex(wrap: .nowrap)
        ),
      ],
      coreContent
    )
  } else {
    return .div(
      attributes: [
        .class([
          Class.border.left,
          Class.flex.items.center,
          Class.grid.row,
          Class.padding([.mobile: [.leftRight: 2, .topBottom: 2]]),
          Class.pf.colors.border.gray800,
          backgroundColor,
        ]),
        .style(
          borderColor(all: .other("#e8e8e8"))
            <> borderWidth(left: .px(4))
            <> margin(top: .px(4))
            <> flex(wrap: .nowrap)
        ),
      ],
      coreContent
    )
  }
}

private let moreComingSoon = Node.gridColumn(
  sizes: [.mobile: 12],
  attributes: [
    .style(margin(top: .px(4)))
  ],
  .div(
    attributes: [
      .class([
        Class.border.left,
        Class.flex.items.center,
        Class.grid.row,
        Class.padding([.mobile: [.leftRight: 2, .topBottom: 2]]),
        Class.pf.colors.border.gray800,
        Class.pf.colors.bg.white,
      ]),
      .style(
        borderColor(all: .other("#e8e8e8"))
          <> borderWidth(left: .px(4))
          <> margin(top: .px(4))
          <> flex(wrap: .nowrap)
      ),
    ],
    .img(
      base64: hourGlassSvgBase64(fill: "666"),
      type: .image(.svg),
      alt: "",
      attributes: [.class([Class.padding([.mobile: [.right: 1]])])]
    ),
    .div(
      attributes: [
        .style(flex(grow: 1)),
        .class([
          Class.pf.colors.fg.gray400,
          Class.type.italic,
        ]),
      ],
      .text("Currently in progress. More coming soon!")
    )
  )
)
