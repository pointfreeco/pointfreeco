import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

let episodesResponse: Middleware<StatusLineOpen, ResponseEnded, Tag?, Data> =
  map(episodes(for:))
    >>> requestContextMiddleware
    >-> writeStatus(.ok)
    >-> respond(episodesDocumentView.map(addGoogleAnalytics))

private func episodes(for tag: Tag?) -> (episodes: [Episode], selectedTag: Tag?) {
  return (
    episodes: episodes
      .filter { tag.map($0.tags.contains) != .some(false) }
      .sorted(by: get(\.sequence))
      .reversed(),

    selectedTag: tag
  )
}

private let episodesDocumentView = View<RequestContext<(episodes: [Episode], selectedTag: Tag?)>> { context in
  document(
    [
      html(
        [
          head(
            [
              style(renderedNormalizeCss),
              style(styleguide),
              ]
          ),
          body(
            navView.view(context.map(const(unit)))
              <> episodesView.view(context.data)
              <> footerView.view(unit)
          )
        ]
      )
    ]
  )
}

private let episodesView = View<(episodes: [Episode], selectedTag: Tag?)> { eps, selectedTag in
  gridRow([
    gridColumn(
      sizes: [.xs: 12, .md: 9], [
        div([`class`([Class.padding.leftRight(4), Class.padding.bottom(2), Class.padding.top(3)])], [
          ul([`class`([Class.type.list.reset])],
             eps.map(episodeListItemView.view >>> li)
          )
          ])
      ]),

    gridColumn(
      sizes: [.md: 3],
      [`class`([Class.hide.xs, Class.hide.sm])],
      sideMenuView.view(selectedTag)
    )
    ])
}

private let sideMenuView = View<Tag?> { selectedTag in
  div(
    [`class`([
      Class.padding.right(4),
      Class.padding.bottom(2),
      Class.padding.top(3),
      Class.position.sticky(.md),
      Class.position.top0])],
    [
      h5([`class`([Class.pf.type.subhead])], ["Sort by"]),
      ol([`class`([Class.type.list.reset, Class.padding.bottom(2)])], [
        li([a([href("#")], ["Newest first"])]),
        li([a([href("#")], ["Oldest first"])]),
        ]),

      h5([`class`([Class.pf.type.subhead])], ["Episode Type"]),
      ol([`class`([Class.type.list.reset, Class.padding.bottom(2)])], [
        li([a([href("#")], ["All"])]),
        li([a([href("#")], ["Subscriber only"])]),
        li([a([href("#")], ["Free"])]),
        ]),

      h5([`class`([Class.pf.type.subhead])], ["Tag"]),
      ol(
        [`class`([Class.type.list.reset, Class.padding.bottom(2)])],
        ([nil] + array(Tag.all).map(Optional.some))
          .map { (tag: $0, selectedTag: selectedTag) }
          .map(tagListItemView.view >>> li))

    ])
}

private let tagListItemView = View<(tag: Tag?, selectedTag: Tag?)> { tag, selectedTag in
  (selectedTag == tag ? ["> "] : [])
    + [a([href(path(to: .episodes(tag: tag)))], [.text(encode(tag?.name ?? "All"))])]
}

let episodeImageStyles: Stylesheet =
  width(.pct(100))
    <> maxHeight(.px(200))
    <> objectFit(.cover)

private let episodeListItemView = View<Episode> { ep in
  gridRow([`class`([Class.margin.bottom(4)])], [
    gridColumn(sizes: [.xs: 4], [
      div([`class`([Class.padding.right(3)])], [
        a(
          [href(path(to: .episode(.left(ep.slug))))],
          [
            img(
              base64: logoSvgBase64,
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.pf.colors.bg.black50, Class.layout.fit]), style(episodeImageStyles)])
          ]
        )
        ])
      ]),

    gridColumn(sizes: [.xs: 8], [
      div([
        strong(
          [`class`([Class.h6, Class.type.caps, Class.type.lineHeight(1)])],
          [.text(encode("Episode \(ep.sequence)"))]
        ),
        h5([`class`([Class.pf.type.title3])], [
          a(
            [href(path(to: .episode(.left(ep.slug))))],
            [.text(encode(ep.title))])
          ]),
        p([`class`([Class.pf.type.callout])], [.text(encode(ep.blurb))]),

        div(pillTagsView.view(ep.tags))
        ])
      ])
    ])
}

extension Array {
  func sorted<A: Comparable>(by f: (Element) -> A) -> Array {
    return self.sorted { lhs, rhs in f(lhs) < f(rhs) }
  }
}
