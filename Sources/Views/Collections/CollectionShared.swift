import Css
import EmailAddress
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

// MARK: HTML -

func collectionNavigation(
  left: Node?
) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
      ]),
      .style(borderColor(top: .black)),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.leftRight: 1]]),
          Class.grid.middle(.mobile),
        ]),
        .style(
          color(.other("#7d7d7d"))
            <> height(.px(50))
            <> maxWidth(.px(1080))
            <> margin(topBottom: nil, leftRight: .auto)
        ),
      ],
      .gridColumn(
        sizes: [.desktop: 6, .mobile: 12],
        left
          .map {
            [
              .img(base64: leftNavigationChevronSvgBase64, type: .image(.svg), alt: "", attributes: [
                .class([
                  Class.padding([.mobile: [.right: 1]]),
                ]),
              ]),
              $0
            ]
          }
          ?? []
      )//,
//      .gridColumn(
//        sizes: [.desktop: 6, .mobile: 12],
//        attributes: [
//          .class([
//            Class.grid.end(.mobile)
//          ]),
//        ],
//        ""
//      )
    )
  )
}

func collectionHeader(
  title: String,
  category: String,
  subcategory: String,
  subcategoryCount: Int,
  length: Seconds<Int>,
  blurb: String
) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
      ]),
      .style(borderColor(top: .black)),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .desktop: [.leftRight: 4, .top: 3, .bottom: 4],
            .mobile: [.leftRight: 2, .topBottom: 3],
          ]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [],
        .h1(
          attributes: [
            .class([
              Class.pf.colors.fg.white,
              Class.pf.type.responsiveTitle2,
              Class.type.align.center,
            ]),
            .style(lineHeight(1.2))
          ],
          .text(title)
        ),
        .div(
          attributes: [
            .class([
              Class.pf.type.body.small,
              Class.type.align.center,
            ]),
            .style(color(.other("#a1a1a1")))
          ],
          "\(category) • \(subcategory.pluralize(subcategoryCount)) • \(length.formattedDescription)"
        ),
        .div(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 2, .leftRight: 2], .desktop: [.top: 3, .leftRight: 4]]),
              Class.pf.colors.fg.gray850,
              Class.pf.type.body.regular,
            ]),
          ],
          .markdownBlock(blurb)
        )
      )
    )
  )
}

// MARK: - Stylesheet

public let collectionsStylesheet = Stylesheet.concat(
  (Class.pf.collections.hoverBackground & .pseudo(.hover)) % backgroundColor(.white(0.9)),
  (Class.pf.collections.hoverLink & .pseudo(.hover)) % key("text-decoration", "none")
)

extension Class.pf {
  enum collections {
    static let hoverBackground = CssSelector.class("col-idx-hover")
    static let hoverLink = CssSelector.class("col-idx-link")
  }
}

// MARK: - Helpers

fileprivate extension String {
  func pluralize(_ count: Int) -> String {
    let string = "\(count) \(self)"
    return count == 1 ? string
      : string.hasSuffix("y") ? string.replacingOccurrences(of: "y$", with: "ies", options: .regularExpression)
      : "\(string)s"
  }
}

fileprivate extension Seconds where RawValue == Int {
  var formattedDescription: String {
    let length = self.rawValue
    let hours = length / 3600
    let minutes = (length / 60) % 60
    return hours > 0
      ? "\(hours) hr \(minutes) min"
      : "\(minutes) min"
  }
}
