import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct Footer: HTML {
  public var body: some HTML {
    footer {
      Grid {
        TaglineColumn()
          .column(count: 12, media: .mobile)
          .column(count: 6, media: .desktop)

        HTMLGroup {
          ContentColumn()
          MoreColumn()
        }
        .column(count: 4, media: .mobile)
        .column(count: 2, media: .desktop)

        LegalColumn()
          .column(count: 12, media: .mobile)
          .column(count: 6, media: .desktop)
      }
      .grid(alignment: .baseline)
    }
    .backgroundColor(.black)
    .padding(3, .mobile)
    .padding(4, .desktop)
  }
}

private struct TaglineColumn: HTML {
  @Dependency(\.siteRouter) var siteRouter
  let twitterRouter = TwitterRouter()

  var body: some HTML {
    GridColumn {
      div {
        h4 {
          Link("Point-Free", color: .white, href: siteRouter.path(for: .home))
        }
        .fontScale(.h4)
        .margin(bottom: 0, .mobile)
        .inlineStyle("font-size", "1.25", media: MediaQuery.mobile.rawValue)
        .inlineStyle("font-size", "1.25", media: MediaQuery.desktop.rawValue)
        .inlineStyle("line-height", "1.45")

        p {
          "A video series exploring advanced topics in the Swift programming language. Hosted by "
          twitterLink("Brandon&nbsp;Williams", .mbrandonw)
          " and "
          twitterLink("Stephen&nbsp;Celis", .stephencelis)
          "."
        }
        .color(.white)
        .fontStyle(.body(.regular))
      }
      .padding(right: 4, .desktop)
      .padding(bottom: 2, .mobile)
    }
  }

  func twitterLink(_ name: String, _ route: TwitterRoute) -> some HTML {
    Link(color: .green, href: twitterRouter.url(for: route).absoluteString) {
      HTMLText(name, raw: true)
    }
    .inlineStyle("text-decoration", "none", pseudo: "link")
    .inlineStyle("text-decoration", "none", pseudo: "visited")
  }
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

        ol { links }
          .listStyle(.reset)
      }
    }
  }
}

public struct FooterLink: HTML {
  let href: String
  let label: String

  init(_ label: String, href: String) {
    self.href = href
    self.label = label
  }

  public var body: some HTML {
    li { Link(label, color: .purple, href: href) }
  }
}

private struct LegalColumn: HTML {
  @Dependency(\.date.now) var now
  let gitHubRouter = GitHubRouter()

  var body: some HTML {
    GridColumn {
      p {
        let year = Calendar(identifier: .gregorian).component(.year, from: now)
        """
        © \(year) Point-Free, Inc. All rights are reserved for the videos and transcripts on this \
        site. All other content is licensed under \

        """
        Link(
          "CC BY-NC-SA 4.0",
          color: .gray650,
          href: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
        )
        ", and the underlying "
        Link(
          "source code",
          color: .gray650,
          href: gitHubRouter.url(for: .repo(.pointfreeco)).absoluteString
        )
        " to run this site is licensed under the "
        Link(
          "MIT License",
          color: .gray650,
          href: gitHubRouter.url(for: .license).absoluteString
        )
        "."
      }
      .color(.gray400)
      .fontStyle(.body(.small))
      .padding(top: 2, .mobile)
    }
    .column(count: 6, media: .desktop)
    .column(count: 12, media: .mobile)
  }
}
