import EpisodeModels
import Html
import Prelude
import Styleguide

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
