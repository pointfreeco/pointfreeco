import Css
import Dependencies
import FunctionalCss
import Html
import Models
import PointFreeRouter
import StyleguideV2

public func footerView(user: User?, year: Int) -> Node {
  return .footer(
    attributes: [.class([footerClass])],
    footerInfoColumnsView(user: user, year: year)
  )
}

private func footerInfoColumnsView(user: User?, year: Int) -> Node {
  return [
    .gridColumn(sizes: [.mobile: 12, .desktop: 6], pointFreeView),
    Node {
      ContentColumn()
      MoreColumn()
    },
    .gridColumn(sizes: [.mobile: 12, .desktop: 6], legalView(year: year)),
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
        .href(GitHubRouter().url(for: .repo(.pointfreeco)).absoluteString),
      ],
      "source code"
    ),
    " to run this site is licensed under the ",
    .a(
      attributes: [
        .class([Class.pf.colors.link.gray650]),
        .href(GitHubRouter().url(for: .license).absoluteString),
      ],
      "MIT license"
    )
  )
}

private var pointFreeView: Node {
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    attributes: [.class([Class.padding([.desktop: [.right: 4], .mobile: [.bottom: 2]])])],
    .h4(
      attributes: [
        .class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.bottom: 0]])])
      ],
      .a(
        attributes: [.href(siteRouter.path(for: .home)), .class([Class.pf.colors.link.white])],
        "Point-Free"
      )
    ),
    .p(
      attributes: [.class([Class.pf.type.body.regular, Class.pf.colors.fg.white])],
      "A video series exploring advanced topics in the Swift programming language. Hosted by ",
      .a(
        attributes: [
          .href(TwitterRouter().url(for: .mbrandonw).absoluteString),
          .class([Class.type.textDecorationNone, Class.pf.colors.link.green]),
        ],
        .raw("Brandon&nbsp;Williams")
      ),
      " and ",
      .a(
        attributes: [
          .href(TwitterRouter().url(for: .stephencelis).absoluteString),
          .class([Class.type.textDecorationNone, Class.pf.colors.link.green]),
        ],
        .raw("Stephen&nbsp;Celis")
      ),
      "."
    )
  )
}

private struct ContentColumn: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    Column(title: "Content") {
      FooterLink("Pricing", href: siteRouter.path(for: .pricingLanding))
      FooterLink("Gifts", href: siteRouter.path(for: .gifts()))
      FooterLink("Videos", href: siteRouter.path(for: .home))
      FooterLink("Collections", href: siteRouter.path(for: .collections()))
      FooterLink("Clips", href: siteRouter.path(for: .clips(.clips)))
      FooterLink("Blog", href: siteRouter.path(for: .blog()))
    }
  }
}

private struct MoreColumn: HTML {
  @Dependency(\.siteRouter) var siteRouter
  let gitHubRouter = GitHubRouter()
  let twitterRouter = TwitterRouter()

  var body: some HTML {
    Column(title: "More") {
      FooterLink("About Us", href: siteRouter.path(for: .about))
      FooterLink("Mastodon", href: "https://hachyderm.io/@pointfreeco")
        .attribute("rel", "me")
      FooterLink("Twitter", href: twitterRouter.url(for: .pointfreeco).absoluteString)
      FooterLink("GitHub", href: gitHubRouter.url(for: .organization).absoluteString)
      FooterLink("Contact Us", href: "mailto:support@pointfree.co")
      FooterLink("Privacy Policy", href: siteRouter.path(for: .privacy))
    }
  }
}

private struct Column<Links: HTML>: HTML {
  let title: String
  @HTMLBuilder let links: Links

  var body: some HTML {
    GridColumn {
      div {
        h5 { title }
          .color(.white)
          .inlineStyle("font-size", "0.75rem")
          .inlineStyle("font-size", "0.875rem", media: MediaQuery.desktop.rawValue)
          .inlineStyle("letter-spacing", "0.54pt")
          .inlineStyle("line-height", "1.25")
          .inlineStyle("text-transform", "uppercase")
        ol {
          links
        }
        .listStyle(.reset)
      }
    }
    .column(count: 4, media: .mobile)
    .column(count: 2, media: .desktop)
  }
}

public struct FooterLink<Label: HTML>: HTML {
  let href: String
  let label: Label

  init(href: String, @HTMLBuilder label: () -> Label) {
    self.href = href
    self.label = label()
  }

  init(_ label: String, href: String) where Label == HTMLText {
    self.href = href
    self.label = HTMLText(label)
  }

  public var body: some HTML {
    li {
      a {
        label
      }
      .attribute("href", href)
      .color(.purple, .link)
      .color(.purple, .visited)
    }
  }
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
