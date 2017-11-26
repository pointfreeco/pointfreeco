import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide

let episodesResponse: Middleware<StatusLineOpen, ResponseEnded, Tag?, Data> =
  fetchEpisodes
    >-> respond(episodesView)

private func fetchEpisodes(_ conn: Conn<StatusLineOpen, Tag?>) -> IO<Conn<HeadersOpen, ([Episode], Tag?)>> {

  return conn.map(
    const(
      (
        episodes: episodes
          .filter { conn.data.map($0.tags.contains) != .some(false) }
          .sorted(by: get(\.sequence))
          .reversed(),

        selectedTag: conn.data
      )
    )
    )
    |> writeStatus(.ok)
}

private let episodesView = View<([Episode], Tag?)> { eps, selectedTag in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        ]),
      body([

        gridRow([
          gridColumn(
            sizes: [.xs: 12, .md: 9], [
              div([`class`([Class.padding.leftRight(4), Class.padding.topBottom(2)])], [
                h3(
                  [`class`("h3")],
                  ["Episodes"]
                ),
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

        ] + footerView.view(unit))
      ])
    ])
}

private let sideMenuView = View<Tag?> { selectedTag in
  div([`class`([Class.padding.right(4), Class.padding.topBottom(2), Class.position.sticky(breakpoint: .md), Class.position.top0])], [
    h5([`class`([Class.h5])], ["Sort by"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href("#")], ["Newest first"])]),
      li([a([href("#")], ["Oldest first"])]),
      ]),

    h5([`class`([Class.h5])], ["Episode Type"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href("#")], ["All"])]),
      li([a([href("#")], ["Subscriber only"])]),
      li([a([href("#")], ["Free"])]),
      ]),

    h5([`class`([Class.h5])], ["Tag"]),
    ol(
      [`class`([Class.type.list.reset])],
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
              [`class`([Class.pf.colors.bg.white, Class.layout.fit]), style(episodeImageStyles)])
          ]
        )
        ])
      ]),

    gridColumn(sizes: [.xs: 8], [
      div([
        strong(
          [`class`([Class.h6, Class.type.caps, Class.type.lineHeight1])],
          [.text(encode("Episode \(ep.sequence)"))]
        ),
        h5([`class`([Class.h5, Class.type.lineHeight1, Class.margin.top(0), Class.margin.bottom(2)])], [
          a(
            [href(path(to: .episode(.left(ep.slug))))],
            [.text(encode(ep.title))])
          ]),
        p([.text(encode(ep.blurb))]),

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

