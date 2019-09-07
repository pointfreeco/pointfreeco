import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Styleguide
import Prelude

func footerView(user: User?) -> [Node] {
  return [
    footer(
      [`class`([footerClass])],
      footerInfoColumnsView(user: user)
    )
  ]
}

private func column(sizes: [Breakpoint: Int]) -> ([Node]) -> [Node] {
  return gridColumn(sizes: sizes) >>> pure
}

private let footerInfoColumn = column(sizes: [.mobile: 12, .desktop: 6])

private func footerInfoColumnsView(user: User?) -> [Node] {
  return footerInfoColumn(pointFreeView)
    + linksColumnsView(currentUser: user)
    + footerInfoColumn(legalView)
}

private let linksColumn = column(sizes: [.mobile: 4, .desktop: 2])

private func linksColumnsView(currentUser: User?) -> [Node] {
  return linksColumn(contentColumnView(currentUser: currentUser))
    + linksColumn(moreColumnView)
}

private let legalView: [Node] = [
  p([`class`([legalClass, Class.padding([.mobile: [.top: 2]])])], [
    .text("© \(year) Point-Free, Inc. All rights are reserved for the videos and transcripts on this site. "),
    "All other content is licensed under ",
    a([`class`([Class.pf.colors.link.gray650]),
       href("https://creativecommons.org/licenses/by-nc-sa/4.0/")],
      ["CC BY-NC-SA 4.0"]),
    ", and the underlying ",
    a([`class`([Class.pf.colors.link.gray650]), href(gitHubUrl(to: .repo(.pointfreeco)))], ["source code"]),
    " to run this site is licensed under the ",
    a([`class`([Class.pf.colors.link.gray650]), href(gitHubUrl(to: .license))], ["MIT license"])
    ])
]

private let pointFreeView: [Node] = [
  div([`class`([Class.padding([.desktop: [.right: 4], .mobile: [.bottom: 2]])])], [
    h4([`class`([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.bottom: 0]])])], [
      a([href(path(to: .home)), `class`([Class.pf.colors.link.white])], ["Point-Free"])
      ]),
    p([`class`([Class.pf.type.body.regular, Class.pf.colors.fg.white])], [
      "A video series on functional programming and the Swift programming language. Hosted by ",
      a(
        [href(twitterUrl(to: .mbrandonw)), `class`([Class.type.textDecorationNone, Class.pf.colors.link.green])],
        [.raw("Brandon&nbsp;Williams")]
      ),
      " and ",
      a(
        [href(twitterUrl(to: .stephencelis)), `class`([Class.type.textDecorationNone, Class.pf.colors.link.green])],
        [.raw("Stephen&nbsp;Celis")]
      ),
      "."
      ]),
    ])
]

private func contentColumnView(currentUser: User?) -> [Node] {

  return [
    div([
      h5([`class`([columnTitleClass])], ["Content"]),
      ol(
        [`class`([Class.type.list.reset])],
        [
          li([
            a([`class`([footerLinkClass]), href(path(to: .pricingLanding))], ["Pricing"])
            ]),
          li([
            a([`class`([footerLinkClass]), href(path(to: .home))], ["Videos"])
            ]),
          li([
            a([`class`([footerLinkClass]), href(path(to: .blog(.index)))], ["Blog"])
            ]),
          li([
            a([`class`([footerLinkClass]), href(path(to: .about))], ["About Us"])
            ])
        ]
      )
      ])
  ]
}

private let moreColumnView = [
  div([
    h5([`class`([columnTitleClass])], ["More"]),
    ol([`class`([Class.type.list.reset])], [
      li([
        a([`class`([footerLinkClass]), href(twitterUrl(to: .pointfreeco))], ["Twitter"])
        ]),
      li([
        a([`class`([footerLinkClass]), href(gitHubUrl(to: .organization))], ["GitHub"])
        ]),
      li([
        a([`class`([footerLinkClass]), mailto("support@pointfree.co")], ["Contact us"])
        ]),
      li([
        a([`class`([footerLinkClass]), href(path(to: .privacy))], ["Privacy Policy"])
        ]),
      ])
    ])
]

private let footerClass =
  Class.grid.row
    | Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])
    | Class.pf.colors.bg.black

private let footerLinkClass =
  Class.pf.colors.link.purple
    | Class.pf.type.body.regular

private let columnTitleClass =
  Class.pf.type.responsiveTitle7
    | Class.pf.colors.fg.white

private let legalClass =
  Class.pf.colors.fg.gray400
    | Class.pf.type.body.small

private var year: Int {
  return Calendar(identifier: .gregorian).component(.year, from: Current.date())
}
