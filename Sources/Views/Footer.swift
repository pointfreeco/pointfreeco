import Css
import Dependencies
import FunctionalCss
import Html
import Models
import PointFreeRouter

public func footerView(user: User?, year: Int) -> Node {
  return .footer(
    attributes: [.class([footerClass])],
    footerInfoColumnsView(user: user, year: year)
  )
}

private func footerInfoColumnsView(user: User?, year: Int) -> Node {
  return [
    .gridColumn(sizes: [.mobile: 12, .desktop: 6], pointFreeView()),
    linksColumnsView(currentUser: user),
    .gridColumn(sizes: [.mobile: 12, .desktop: 6], legalView(year: year)),
  ]
}

private func linksColumnsView(currentUser: User?) -> Node {
  return [
    .gridColumn(sizes: [.mobile: 4, .desktop: 2], contentColumnView(currentUser: currentUser)),
    .gridColumn(sizes: [.mobile: 4, .desktop: 2], moreColumnView()),
  ]
}

private func legalView(year: Int) -> Node {
  return .p(
    attributes: [.class([legalClass, Class.padding([.mobile: [.top: 2]])])],
    .text(
      "© \(year) Point-Free, Inc. All rights are reserved for the videos and transcripts on this site. "
    ),
    "All other content is licensed under ",
    .a(
      attributes: [
        .class([Class.pf.colors.link.gray650]),
        .href("https://creativecommons.org/licenses/by-nc-sa/4.0/"),
      ],
      "CC BY-NC-SA 4.0"
    ),
    ", and the underlying ",
    .a(
      attributes: [
        .class([Class.pf.colors.link.gray650]),
        .href(gitHubRouter.url(for: .repo(.pointfreeco)).absoluteString),
      ],
      "source code"
    ),
    " to run this site is licensed under the ",
    .a(
      attributes: [
        .class([Class.pf.colors.link.gray650]),
        .href(gitHubRouter.url(for: .license).absoluteString),
      ],
      "MIT license"
    )
  )
}

private func pointFreeView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    attributes: [.class([Class.padding([.desktop: [.right: 4], .mobile: [.bottom: 2]])])],
    .h4(
      attributes: [.class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.bottom: 0]])])],
      .a(
        attributes: [.href(siteRouter.path(for: .home)), .class([Class.pf.colors.link.white])],
        "Point-Free"
      )
    ),
    .p(
      attributes: [.class([Class.pf.type.body.regular, Class.pf.colors.fg.white])],
      "A video series on functional programming and the Swift programming language. Hosted by ",
      .a(
        attributes: [
          .href(twitterRouter.url(for: .mbrandonw).absoluteString),
          .class([Class.type.textDecorationNone, Class.pf.colors.link.green]),
        ],
        .raw("Brandon&nbsp;Williams")
      ),
      " and ",
      .a(
        attributes: [
          .href(twitterRouter.url(for: .stephencelis).absoluteString),
          .class([Class.type.textDecorationNone, Class.pf.colors.link.green]),
        ],
        .raw("Stephen&nbsp;Celis")
      ),
      "."
    )
  )
}

private func contentColumnView(currentUser: User?) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    .h5(attributes: [.class([columnTitleClass])], "Content"),
    .ol(
      attributes: [.class([Class.type.list.reset])],
      .li(
        .a(
          attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .pricingLanding))],
          "Pricing")
      ),
      .li(
        .a(
          attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .gifts()))], "Gifts")
      ),
      .li(
        .a(attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .home))], "Videos")
      ),
      .li(
        .a(
          attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .collections()))],
          "Collections")
      ),
      .li(
        .a(attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .blog()))], "Blog")
      )
    )
  )
}

private func moreColumnView() -> Node {
  @Dependency(\.siteRouter) var siteRouter
  
  return .div(
    .h5(attributes: [.class([columnTitleClass])], "More"),
    .ol(
      attributes: [.class([Class.type.list.reset])],
      .li(
        .a(attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .about))], "About Us")
      ),
      .li(
        .a(
          attributes: [
            .class([footerLinkClass]),
            .href("https://hachyderm.io/@pointfreeco"),
            .rel(.init(rawValue: "me")),
          ], "Mastodon")
      ),
      .li(
        attributes: [.class([Class.display.none])],
        .a(
          attributes: [
            .class([footerLinkClass]),
            .href("https://hachyderm.io/@mbrandonw"),
            .rel(.init(rawValue: "me")),
          ], "@mbrandonw")
      ),
      .li(
        attributes: [.class([Class.display.none])],
        .a(
          attributes: [
            .class([footerLinkClass]),
            .href("https://hachyderm.io/@stephencelis"),
            .rel(.init(rawValue: "me")),
          ], "@stephencelis")
      ),
      .li(
        .a(
          attributes: [
            .class([footerLinkClass]), .href(twitterRouter.url(for: .pointfreeco).absoluteString),
          ], "Twitter")
      ),
      .li(
        .a(
          attributes: [
            .class([footerLinkClass]), .href(gitHubRouter.url(for: .organization).absoluteString),
          ], "GitHub")
      ),
      .li(
        .a(attributes: [.class([footerLinkClass]), .mailto("support@pointfree.co")], "Contact us")
      ),
      .li(
        .a(
          attributes: [.class([footerLinkClass]), .href(siteRouter.path(for: .privacy))],
          "Privacy Policy")
      )
    )
  )
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
