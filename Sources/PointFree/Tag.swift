import Html
import Prelude
import Styleguide

public struct Tag: Equatable {
  var name: String

  var slug: String {
    return PointFree.slug(for: name)
  }

  public static let all = (
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

  public static func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.name == rhs.name
  }
}

extension Tag {
  public init?(slug: String) {
    guard let tag = array(Tag.all).first(where: { PointFree.slug(for: slug) == $0.slug })
      else { return nil }
    self = tag
  }
}

public let pillTagsView = View<[Tag]> { tags in
  ol(
    [`class`([Class.display.inlineBlock, Class.type.list.reset])],
    tags
      .sorted(by: ^\.name)
      .map(
        episodeTagView.view
          >>> curry(li)([`class`([Class.display.inlineBlock, Class.margin([.mobile: [.right: 1, .bottom: 1]])])])
    )
  )
}

private let episodeTagView = View<Tag> { tag in
  a(
    [
      href("#"),
      `class`([
        Class.h6,
        Class.padding([.mobile: [.leftRight: 2, .topBottom: 1]]),
        Class.border.pill,
        Class.border.all,
        Class.pf.colors.bg.white,
        Class.type.textDecorationNone,
        Class.pf.colors.border.gray900
        ])
    ],
    [.text(encode(tag.name))]
  )
}

func slug(for string: String) -> String {
  return string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}
