import Html
import Prelude
import Styleguide
import View

public struct SiteTag: Equatable {
  var name: String

  var slug: String {
    return PointFree.slug(for: name)
  }

  public static let all = (
    algebra: SiteTag(name: "Algebra"),
    dsl: SiteTag(name: "DSL"),
    generics: SiteTag(name: "Generics"),
    html: SiteTag(name: "HTML"),
    math: SiteTag(name: "Math"),
    polymorphism: SiteTag(name: "Polymorphism"),
    programming: SiteTag(name: "Programming"),
    serverSideSwift: SiteTag(name: "Server-Side Swift"),
    swift: SiteTag(name: "Swift")
  )
}

extension SiteTag {
  public init?(slug: String) {
    guard let tag = array(SiteTag.all).first(where: { PointFree.slug(for: slug) == $0.slug })
      else { return nil }
    self = tag
  }
}

public let pillTagsView = View<[SiteTag]> { tags in
  ol(
    [`class`([Class.display.inlineBlock, Class.type.list.reset])],
    tags
      .sorted(by: their(^\.name))
      .map(
        episodeTagView.view
          >>> curry(li)([`class`([Class.display.inlineBlock, Class.margin([.mobile: [.right: 1, .bottom: 1]])])])
    )
  )
}

private let episodeTagView = View<SiteTag> { tag in
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
    [.text(tag.name)]
  )
}

func slug(for string: String) -> String {
  return string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}
