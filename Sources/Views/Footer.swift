import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct Footer: HTML {
  public var body: some HTML {
    footer {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        TaglineColumn()

        LazyVGrid(columns: [1, 2]) {
          ContentColumn()
          MoreColumn()
        }

        LegalColumn()
      }
      .inlineStyle("align-items", "first baseline")
    }
    .backgroundColor(.black)
    .padding(3, .mobile)
    .padding(4, .desktop)
  }
}

private struct TaglineColumn: HTML {
  let twitterRouter = TwitterRouter()

  var body: some HTML {
    div {
      h4 {
        Link("Point-Free", destination: .home)
          .linkColor(.white)
      }
      .fontScale(.h4)
      .margin(bottom: 0, .mobile)
      .inlineStyle("font-size", "1.25rem")
      .inlineStyle("font-size", "1.5rem", media: .desktop)
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
      .linkColor(.green)
    }
    .padding(right: 4, .desktop)
    .padding(bottom: 2, .mobile)
  }

  func twitterLink(_ name: String, _ route: TwitterRoute) -> some HTML {
    Link(href: twitterRouter.url(for: route).absoluteString) {
      HTMLRaw(name)
    }
  }
}

private struct ContentColumn: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.features) var features
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    Column(title: "Content") {
      FooterLink("Pricing", destination: .pricingLanding)
      if features.hasAccess(to: .thePointFreeWay, for: currentUser) {
        FooterLink("The Point-Free Way", destination: .theWay)
      }
      FooterLink("Gifts", destination: .gifts())
      FooterLink("Episodes", destination: .episodes(.list(.all)))
      FooterLink("Collections", destination: .collections())
      FooterLink("Free clips", destination: .clips(.clips))
      FooterLink("Blog", destination: .blog())
    }
  }
}

private struct MoreColumn: HTML {
  @Dependency(\.siteRouter) var siteRouter
  let gitHubRouter = GitHubRouter()
  let twitterRouter = TwitterRouter()

  var body: some HTML {
    Column(title: "More") {
      FooterLink("About Us", destination: .about)
      FooterLink("Community Slack", href: siteRouter.path(for: .slackInvite))
      FooterLink("Mastodon", href: "https://hachyderm.io/@pointfreeco")
        .attribute("rel", "me")
      FooterLink("Twitter", href: twitterRouter.url(for: .pointfreeco).absoluteString)
      FooterLink("BlueSky", href: "https://bsky.app/profile/pointfree.co")
      FooterLink("GitHub", href: gitHubRouter.url(for: .organization).absoluteString)
      FooterLink("Contact Us", href: "mailto:support@pointfree.co")
      FooterLink("Privacy Policy", destination: .privacy)
    }
  }
}

private struct Column<Links: HTML>: HTML {
  let title: String
  @HTMLBuilder let links: Links

  var body: some HTML {
    div {
      h5 { HTMLText(title) }
        .color(.white)
        .inlineStyle("font-size", "0.75rem")
        .inlineStyle("font-size", "0.875rem", media: .desktop)
        .inlineStyle("letter-spacing", "0.54pt")
        .inlineStyle("line-height", "1.25")
        .inlineStyle("text-transform", "uppercase")

      ol { links.linkColor(.purple) }
        .listStyle(.reset)
    }
  }
}

private struct FooterLink: HTML {
  let href: String
  let label: String

  init(_ label: String, href: String) {
    self.href = href
    self.label = label
  }

  init(_ label: String, destination: SiteRoute) {
    @Dependency(\.siteRouter) var siteRouter
    self.init(label, href: siteRouter.path(for: destination))
  }

  var body: some HTML {
    li { Link(label, href: href) }
  }
}

private struct LegalColumn: HTML {
  @Dependency(\.date.now) var now
  let gitHubRouter = GitHubRouter()

  var body: some HTML {
    p {
      let year = Calendar(identifier: .gregorian).component(.year, from: now)
      """
      © \(year) Point-Free, Inc. All rights are reserved for the videos and transcripts on this \
      site. All other content is licensed under \

      """
      Link(
        "CC BY-NC-SA 4.0",
        href: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
      )
      ", and the underlying "
      Link(
        "source code",
        href: gitHubRouter.url(for: .repo(.pointfreeco)).absoluteString
      )
      " to run this site is licensed under the "
      Link(
        "MIT License",
        href: gitHubRouter.url(for: .license).absoluteString
      )
      "."
    }
    .color(.gray400)
    .fontStyle(.body(.small))
    .linkColor(.gray650)
    .padding(top: 2, .mobile)
  }
}
