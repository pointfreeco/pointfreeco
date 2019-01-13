import Css
import Foundation
import Html
import HtmlCssSupport
import Styleguide
import Prelude
import View

let footerView = View<Database.User?> { user in
  footer([Styleguide.class([footerClass])], footerInfoColumnsView.view(user))
}

private func column(sizes: [Breakpoint: Int]) -> (Node) -> Node {
  return gridColumn(sizes: sizes)
}

private let footerInfoColumn = column(sizes: [.mobile: 12, .desktop: 6])

private let footerInfoColumnsView = View {
  [
    pointFreeView.map(footerInfoColumn).contramap(const(unit)).view($0),
    linksColumnsView.view($0),
    legalView.map(footerInfoColumn).contramap(const(unit)).view($0)
  ]
}

private let linksColumn = column(sizes: [.mobile: 4, .desktop: 2])

private let linksColumnsView = View<Database.User?> { currentUser in
  [
    contentColumnView.map(linksColumn).view(currentUser),
    currentUser == nil ? accountColumnView.map(linksColumn).view(unit) : [],
    moreColumnView.map(linksColumn).view(unit)
  ]
}

private let legalView = View<Prelude.Unit> { _ in
  p([Styleguide.class([legalClass, Class.padding([.mobile: [.top: 2]])])], [
    .text("© \(year) Point-Free, Inc. All rights are reserved for the videos and transcripts on this site. "),
    "All other content is licensed under ",
    a([Styleguide.class([Class.pf.colors.link.gray650]),
       href("https://creativecommons.org/licenses/by-nc-sa/4.0/")],
      ["CC BY-NC-SA 4.0"]),
    ", and the underlying ",
    a([Styleguide.class([Class.pf.colors.link.gray650]), href(gitHubUrl(to: .repo(.pointfreeco)))], ["source code"]),
    " to run this site is licensed under the ",
    a([Styleguide.class([Class.pf.colors.link.gray650]), href(gitHubUrl(to: .license))], ["MIT license"])
    ])
}

private let pointFreeView = View<Prelude.Unit> { _ -> Node in
  div([Styleguide.class([Class.padding([.desktop: [.right: 4], .mobile: [.bottom: 2]])])], [
    h4([Styleguide.class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.bottom: 0]])])], [
      a([href(path(to: .home)), Styleguide.class([Class.pf.colors.link.white])], ["Point-Free"])
      ]),
    p([Styleguide.class([Class.pf.type.body.regular, Class.pf.colors.fg.white])], [
      "A video series on functional programming and the Swift programming language. Hosted by ",
      a(
        [href(twitterUrl(to: .mbrandonw)), Styleguide.class([Class.type.textDecorationNone, Class.pf.colors.link.green])],
        [.raw("Brandon&nbsp;Williams")]
      ),
      " and ",
      a(
        [href(twitterUrl(to: .stephencelis)), Styleguide.class([Class.type.textDecorationNone, Class.pf.colors.link.green])],
        [.raw("Stephen&nbsp;Celis")]
      ),
      "."
      ]),
    ])
}

private let contentColumnView = View<Database.User?> { currentUser -> Node in

  return div([
    h5([Styleguide.class([columnTitleClass])], ["Content"]),
    ol(
      [Styleguide.class([Class.type.list.reset])],
      [
        li([
          a([Styleguide.class([footerLinkClass]), href(path(to: .home))], ["Videos"])
          ]),
        li([
          a([Styleguide.class([footerLinkClass]), href(path(to: .blog(.index)))], ["Blog"])
          ]),
        li([
          a([Styleguide.class([footerLinkClass]), href(path(to: .about))], ["About Us"])
          ])
      ]
    )
    ])
}

private let accountColumnView = View<Prelude.Unit> { _ in
  div([
    h5([Styleguide.class([columnTitleClass])], ["Account"]),
    ol([Styleguide.class([Class.type.list.reset])], [
      li([
        a([Styleguide.class([footerLinkClass]), href(path(to: .pricing(nil, expand: nil)))], ["Subscribe"])
        ]),
      li([
        a([Styleguide.class([footerLinkClass]), href(path(to: .pricing(nil, expand: nil)))], ["Pricing"])
        ]),
      ])
    ])
}

private let moreColumnView = View<Prelude.Unit> { _ in
  div([
    h5([Styleguide.class([columnTitleClass])], ["More"]),
    ol([Styleguide.class([Class.type.list.reset])], [
      li([
        a([Styleguide.class([footerLinkClass]), href(twitterUrl(to: .pointfreeco))], ["Twitter"])
        ]),
      li([
        a([Styleguide.class([footerLinkClass]), href(gitHubUrl(to: .organization))], ["GitHub"])
        ]),
      li([
        a([Styleguide.class([footerLinkClass]), mailto("support@pointfree.co")], ["Contact us"])
        ]),
      li([
        a([Styleguide.class([footerLinkClass]), href(path(to: .privacy))], ["Privacy Policy"])
        ]),
      ])
    ])
}

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
