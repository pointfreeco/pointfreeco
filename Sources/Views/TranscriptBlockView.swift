import Ccmark
import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func transcriptBlockView(
  _ block: Episode.TranscriptBlock,
  fadeOutBlock: Bool = false,
  previousSpeaker: String? = nil
) -> Node {
  switch block.type {
  case let .box(box):
    return .div(
      attributes: [
        .class([
          Class.margin([.mobile: [.leftRight: 2, .topBottom: 3]]),
          Class.padding([.mobile: [.all: 2]]),
        ]),
        .style(
          unsafe:
            "background-color: #\(box.backgroundColor);border-left: 3px solid #\(box.borderColor);"
        ),
      ],
      box.title.map { title in
        .h3(attributes: [.class([Class.pf.type.responsiveTitle6])], .text(title))
      } ?? [],
      .div(
        attributes: [.class([Class.pf.type.body.regular])],
        .markdownBlock(block.content, options: CMARK_OPT_UNSAFE)
      )
    )

  case let .button(href: href):
    return .div(
      attributes: [
        .class([
          Class.margin([.mobile: [.leftRight: 2, .topBottom: 3]]),
          Class.padding([.mobile: [.all: 3]]),
        ]),
        .style(unsafe: "background-color: #f6f6f6;"),
      ],
      .div(
        attributes: [
          .class([
            Class.pf.type.body.regular,
            Class.type.align.center,
          ])
        ],
        .a(
          attributes: [
            .class([
              Class.pf.components.button(color: .purple)
            ]),
            .href(href),
          ],
          .text(block.content)
        )
      )
    )

  case .code(.plainText):
    return .div(
      attributes: [
        .class("md-ctn")
      ],
      .blockquote(
        .pre(
          .text(block.content)
        )
      )
    )

  case let .code(lang):
    return .pre(
      .code(
        attributes: [.class([Class.pf.components.code(lang: lang.identifier)])],
        .text(block.content)
      )
    )

  case let .image(src, sizing):
    let imageClasses =
      sizing == .inset
      ? [
        innerImageContainerClass,
        Class.margin([.mobile: [.topBottom: 3]]),
        Class.padding([.mobile: [.leftRight: 3]]),
        Class.pf.colors.bg.white,
      ]
      : [innerImageContainerClass]

    return .a(
      attributes: [
        .class([outerImageContainerClass, Class.margin([.mobile: [.topBottom: 3]])]),
        .href(src),
        .target(.blank),
        .rel(.init(rawValue: "noopener noreferrer")),
      ],
      .img(src: src, alt: block.content, attributes: [.class(imageClasses)])
    )

  case .paragraph:
    return .div(
      attributes: fadeOutBlock
        ? [
          .style(
            safe: #"""
              -webkit-mask-image: linear-gradient(to bottom, black 20%, transparent 100%);
              mask-image: linear-gradient(to bottom, black 20%, transparent 100%);
              """#)
        ] : [],
      timestampLinkView(block.timestamp),
      .markdownBlock(
        previousSpeaker != block.speaker
          ? (block.speaker.map { "**\($0):**\n" } ?? "") + block.content
          : block.content,
        options: CMARK_OPT_UNSAFE
      )
    )

  case let .question(question):
    return .div(
      attributes: [.class([Class.pf.type.body.regular])],
      timestampLinkView(block.timestamp),
      .blockquote([.text(question)]),
      .markdownBlock(block.content, options: CMARK_OPT_UNSAFE)
    )

  case .title:
    return .h3(
      attributes: [
        .class([Class.h3]),
        block.timestamp.map { .id("t\($0)") },
        block.timestamp.map { .data("timestamp", $0.description) },
      ]
      .compactMap(id),
      .a(
        attributes: block.timestamp.map { [.href("#t\($0)")] } ?? [],
        .text(block.content)
      )
    )

  case let .video(poster, sources):
    return .div(
      attributes: [
        .class([outerVideoContainerClass, Class.margin([.mobile: [.topBottom: 2]])]),
        .style(outerVideoContainerStyle),
      ],
      .video(
        attributes: [
          .class([innerVideoContainerClass]),
          .controls(true),
          .playsinline(true),
          .autoplay(false),
          .poster(poster),
          .style(objectFit(.cover)),
        ],
        .fragment(sources.map { .source(src: $0) })
      )
    )
  }
}

private func timestampLinkView(_ timestamp: Int?) -> Node {
  guard let timestamp = timestamp else { return [] }

  return .div(
    attributes: [
      .id("t\(timestamp)"),
      .class([Class.display.block]),
    ],
    .a(
      attributes: timestampLinkAttributes(timestamp: timestamp) + [
        .class([Class.pf.components.videoTimeLink]),
        .data("timestamp", timestamp.description),
      ],
      .text(timestampLabel(for: timestamp))
    )
  )
}

public func timestampLabel(for timestamp: Int) -> String {
  let minute = Int(timestamp / 60)
  let second = Int(timestamp) % 60
  let minuteString = minute >= 10 ? "\(minute)" : "0\(minute)"
  let secondString = second >= 10 ? "\(second)" : "0\(second)"
  return "\(minuteString):\(secondString)"
}

public func timestampLinkAttributes(timestamp: Int) -> [Attribute<Tag.A>] {

  return [
    .href("#t\(timestamp)")
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

let outerImageContainerClass: CssSelector =
  Class.size.width100pct
  | Class.position.relative

let innerImageContainerClass: CssSelector =
  Class.size.width100pct
