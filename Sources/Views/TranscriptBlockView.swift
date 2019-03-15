import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import View

public let transcriptBlockView = View<Episode.TranscriptBlock> { block -> Node in
  switch block.type {
  case let .code(lang):
    return pre([
      code(
        [`class`([Class.pf.components.code(lang: lang.identifier)])],
        [.text(block.content)]
      )
      ])

  case .correction:
    return div(
      [
        `class`([
          Class.margin([.mobile: [.leftRight: 2, .topBottom: 3]]),
          Class.padding([.mobile: [.all: 2]]),
          ]),
        style("background-color: #ffdbdd;border-left: 3px solid #eb1c26;")
      ],
      [
        h3([`class`([Class.pf.type.responsiveTitle6])], ["Correction"]),
        div(
          [`class`([Class.pf.type.body.regular])],
          [markdownBlock(block.content)]
        ),
        ]
    )

  case let .image(src, sizing):
    let imageClasses = sizing == .inset
      ? [innerImageContainerClass,
         Class.margin([.mobile: [.topBottom: 3]]),
         Class.padding([.mobile: [.leftRight: 3]]),
         Class.pf.colors.bg.white]
      : [innerImageContainerClass]

    return a(
      [
        `class`([outerImageContainerClass, Class.margin([.mobile: [.topBottom: 3]])]),
        href(src),
        target(.blank),
        rel(.init(rawValue: "noopener noreferrer")),
        ],
      [img(src: src, alt: "", [`class`(imageClasses)])]
    )

  case .paragraph:
    return div(
      timestampLinkView.view(block.timestamp)
        + [markdownBlock(block.content)]
    )

  case .title:
    return h2(
      [
        `class`([Class.h4, Class.type.lineHeight(3), Class.padding([.mobile: [.top: 2]])]),
        block.timestamp.map { id("t\($0)") }
        ]
        .compactMap(id),
      [
        a(block.timestamp.map { [href("#t\($0)")] } ?? [], [
          .text(block.content)
          ])
      ]
    )

  case let .video(poster, sources):
    return div(
      [
        `class`([outerVideoContainerClass, Class.margin([.mobile: [.topBottom: 2]])]),
        style(outerVideoContainerStyle)
      ],
      [
        video(
          [
            `class`([innerVideoContainerClass]),
            controls(true),
            playsinline(true),
            autoplay(false),
            Html.poster(poster),
            style(objectFit(.cover))
          ],

          sources.map { source(src: $0) }
        )
      ]
    )
  }
}

private let timestampLinkView = View<Int?> { timestamp -> [Node] in
  guard let timestamp = timestamp else { return [] }

  return [
    div([id("t\(timestamp)"), `class`([Class.display.block])], [
      a(
        timestampLinkAttributes(timestamp: timestamp, useAnchors: false) + [
          `class`([Class.pf.components.videoTimeLink])
        ],
        [.text(timestampLabel(for: timestamp))])
      ])
  ]
}

public func timestampLabel(for timestamp: Int) -> String {
  let minute = Int(timestamp / 60)
  let second = Int(timestamp) % 60
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(minuteString):\(secondString)"
}

public func timestampLinkAttributes(timestamp: Int, useAnchors: Bool) -> [Attribute<Tag.A>] {

  return [
    useAnchors
      ? href("#t\(timestamp)")
      : href("#"),

    onclick(unsafe: """
      var video = document.getElementsByTagName("video")[0];
      video.currentTime = event.target.dataset.t;
      video.play();
      """
      + (useAnchors
        ? ""
        : "event.preventDefault();"
      )
    ),

    data("t", "\(timestamp)")
  ]
}

let outerVideoContainerClass: CssSelector =
  Class.size.width100pct
    | Class.position.relative

let outerVideoContainerStyle: Stylesheet =
  padding(bottom: .pct(56.25))

let innerVideoContainerClass: CssSelector =
  Class.size.height100pct
    | Class.size.width100pct
    | Class.position.absolute
    | Class.pf.colors.bg.gray650

let outerImageContainerClass: CssSelector =
  Class.size.width100pct
    | Class.position.relative

let innerImageContainerClass: CssSelector =
  Class.size.width100pct
    | Class.pf.colors.bg.gray650
