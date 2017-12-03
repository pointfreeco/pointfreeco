import EpisodeModels
import Html
import Prelude
import Styleguide

extension Tag {
  var slug: String {
    return PointFree.slug(for: name)
  }
}

extension Tag {
  init?(slug: String) {
    guard let tag = array(Tag.all).first(where: { PointFree.slug(for: slug) == $0.slug })
      else { return nil }
    self = tag
  }

  static let all = (
    algebra: Tag(name: "Algebra"),
    dsl: Tag(name: "DSL"),
    generics: Tag(name: "Generics"),
    html: Tag(name: "HTML"),
    math: Tag(name: "Math"),
    polymorphism: Tag(name: "Polymorphism"),
    programming: Tag(name: "Programming"),
    serverSideSwift: Tag(name: "Server-Side Swift"),
    swift: Tag(name: "Swift")
  )
}

public let pillTagsView = View<[Tag]> { tags in
  ol(
    [`class`([Class.layout.inlineBlock, Class.type.list.reset])],
    tags
      .sorted(by: get(\.name))
      .map(
        episodeTagView.view
          >>> li([`class`([Class.layout.inlineBlock, Class.margin.right(1), Class.margin.bottom(1)])])
    )
  )
}

private let episodeTagView = View<Tag> { tag in
  a(
    [
      href(path(to: .episodes(tag: .some(tag)))),
      `class`([
        Class.h6,
        Class.padding.leftRight(2),
        Class.padding.topBottom(1),
        Class.border.pill,
        Class.border.all,
        Class.pf.colors.bg.white,
        Class.type.textDecorationNone,
        ])
    ],
    [.text(encode(tag.name))]
  )
}
