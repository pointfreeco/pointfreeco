import Css
import FunctionalCss
import Html
import PointFreeRouter
import Prelude
import Styleguide
import StyleguideV2

public struct AboutView: HTML {
  public init() {}

  public var body: some HTML {
    HTMLGroup {
      PageHeader(title: "About") {
        """
        Point-Free is a video series that explores advanced topics in the Swift programming \
        language. Each episode covers a topic that may seem complex and academic at first, but \
        turns out to be quite simple. At the end of each episode we’ll ask “what’s the point?!”, \
        so that we can bring the concepts back down to earth and show how these ideas can improve \
        the quality of your code today.
        """
      }

      PageModule(theme: .content) {
        HTMLMarkdown(
          """
          # Your hosts

          Brandon and Stephen are industry experts living in New York and California. They
          previously helped build and [open source][ksr-open-source] the [Kickstarter][ksr] mobile \
          apps, and have worked with dozens of companies to help build their products and improve \
          their engineering practices.

          [ksr]: https://www.kickstarter.com/
          [ksr-open-source]: https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd
          """
        )
      }

      CenterColumn {
        LazyVGrid(columns: [.desktop: [1, 1], .mobile: [1]]) {
          HostCard(
            avatarURL: "https://d3rccdn33rt8ze.cloudfront.net/about-us/brando.jpg",
            blurb: """
              Brandon did math for a very long time, and now enjoys talking about functional \
              programming as a means to better our craft as engineers.
              """,
            name: "Brandon Williams",
            twitterURL: "https://www.twitter.com/mbrandonw"
          )
          HostCard(
            avatarURL: "https://d3rccdn33rt8ze.cloudfront.net/about-us/stephen.jpg",
            blurb: """
              Stephen taught himself to code when he realized his English degree didn’t pay the \
              bills. He became a functional convert and believer after years of objects.
              """,
            name: "Stephen Celis",
            twitterURL: "https://www.twitter.com/stephencelis"
          )
        }
      }
      .inlineStyle("padding", "0 2rem")

      PageModule(theme: .informational) {
        VStack {
          HTMLMarkdown("""
            # What we'll cover

            We’ve got so much we want to talk about, but just a quick overview of the things we have planned:

            ### Pure functions and side effects

            Side effects are one of the greatest sources of complexity in an application, and every program has this in common. After giving a proper definition of side effects and pure functions, we will show how to push the effects to the boundary of your application, leaving behind an understandable, testable and pure core.

            ### Code reuse through function composition

            The most basic unit of code reusability comes in the form of simple function composition. We will show that by focusing on small atomic units that compose well, we can build large complex systems that are easy to understand.

            ### Maximizing the use of the type system

            You’ve already seen how the type system helps prevent bugs by making sure you don’t accidentally add an integer to a string, or call a method on a “null” value, but it can do so much more. You can encode invariants of your application directly into the types so impossible application states are not representable and can never compile.

            ### Turning programming problems into algebraic problems

            Algebraic problems are nice because they carry structure that can be manipulated in predictable and understandable ways. For example, if you have ever simplified a complicated boolean expression that looked like a && b || a && c to look like a && (b || c), you were exploiting the algebraic stucture that || and && have. Many programming problems can be given an algebraic structure that allows one to manipulate the problem in the same way you factored out the a && from that expression.

            And so much more…
            """)
          .inlineStyle("max-width", "48rem")
        }
        .inlineStyle("margin", "0 auto")
      }

      PageModule(theme: .content) {
        VStack {
          HTMLMarkdown("""
            # Open source

            When we open-sourced the entire iOS and Android codebases at Kickstarter, we saw that it was one of the best resources to show people how to build a large application in the functional style. It transcended any talks about the theoretical benefits or proposed simplifications. We could just show directly how embracing pure functions allowed us to write code that was understandable in isolation, and enabled us to write tests for every subtle edge case.

            We wanted to be able to do that again, but this time we’d build an entire website in server-side Swift, all in the functional style! This meant we had to build nearly everything from scratch, from server middleware and routing to HTML views and CSS.

            We discovered quite a few fun things along the way, like using Swift Playgrounds to design pages in an iterative fashion, and came to the conclusion that server-side Swift will soon be a viable backend language rivaling almost every other language out there.

            You can view the entire source code to this site on our GitHub organization, [https://github.com/pointfreeco][pf-gh].

            [pf-gh]: https://github.com/pointfreeco
            """)
          .inlineStyle("max-width", "48rem")
        }
        .inlineStyle("margin", "0 auto")
      }
    }
    .linkStyle(.init(color: .black.dark(.white), underline: true))
  }
}

struct HostCard: HTML {
  let avatarURL: String
  let blurb: String
  let name: String
  let twitterURL: String

  var body: some HTML {
    Card {
      div {
        HTMLMarkdown(blurb)
      }
      .color(.gray400.dark(.gray650))
      .linkStyle(LinkStyle(color: .gray400.dark(.gray650), underline: true))
    } header: {
      VStack(alignment: .center, spacing: 1) {
        Image(source: avatarURL, description: "Avatar of \(name).")
          .inlineStyle("width", "4rem")
          .inlineStyle("height", "4rem")
          .inlineStyle("border-radius", "9999px")

        div {
          Header(4) {
            HTMLText(name)
          }
        }
      }
      .inlineStyle("text-align", "center")
      .inlineStyle("display", "block")
      .inlineStyle("padding", "2rem 0")
    } footer: {
      HStack(alignment: .center, spacing: 0.5) {
        SVG.twitter
        Link("Follow on Twitter", href: twitterURL)
          .linkStyle(.init(color: .gray400))
      }
    }
  }
}

extension SVG {
  static let twitter = SVG(
    base64: base64EncodedString("""
    <svg width="15" height="13" viewBox="0 0 15 13" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M14.2918 1.86444C13.77 2.09556 13.2096 2.252 12.6207 2.32222C13.2216 1.96222 13.6829 1.392 13.9 0.712667C13.3378 1.046 12.7156 1.28867 12.0524 1.41844C11.5224 0.853333 10.7664 0.5 9.92955 0.5C8.32288 0.5 7.02022 1.80222 7.02022 3.40956C7.02022 3.63756 7.04644 3.85844 7.09533 4.07178C4.67644 3.95044 2.53355 2.79289 1.09799 1.03244C0.847995 1.46267 0.704662 1.96222 0.704662 2.49467C0.704662 3.50422 1.21844 4.39511 1.99888 4.91689C1.522 4.90133 1.07333 4.77067 0.681106 4.55244C0.680662 4.56489 0.680661 4.57689 0.680661 4.58867C0.680661 5.99867 1.68355 7.17489 3.01488 7.442C2.77044 7.50822 2.51355 7.54356 2.24822 7.54356C2.06044 7.54356 1.878 7.52622 1.70066 7.49244C2.07111 8.648 3.14511 9.48911 4.41844 9.51244C3.42244 10.2924 2.16733 10.758 0.805106 10.758C0.570661 10.758 0.339328 10.7447 0.111328 10.7171C1.39888 11.5431 2.92822 12.0242 4.57066 12.0242C9.92244 12.0242 12.8484 7.59089 12.8484 3.74644C12.8484 3.62089 12.8456 3.49467 12.84 3.37022C13.4084 2.95978 13.9018 2.448 14.2916 1.86489L14.2918 1.86444Z" fill="#1DA1F3"/>
    </svg>
    """),
    description: ""
  )
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI

#Preview(traits: .fixedLayout(width: 800, height: 1000)) {
  HTMLPreview {
    PageLayout(layoutData: SimplePageLayoutData(title: "")) {
      AboutView()
    }
  }
}
#endif

public struct Host {
  public var bio: String
  public var image: String
  public var name: String
  public var twitterRoute: TwitterRoute
  public var website: String

  public init(
    bio: String,
    image: String,
    name: String,
    twitterRoute: TwitterRoute,
    website: String
  ) {
    self.bio = bio
    self.image = image
    self.name = name
    self.twitterRoute = twitterRoute
    self.website = website
  }
}

public let aboutExtraStyles = hostImgStyles <> hostBioStyles

public func aboutView(hosts: [Host]) -> Node {
  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 7],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        aboutSectionView,
        openSourceSection
      )
    ),

    .gridColumn(
      sizes: [.mobile: 12, .desktop: 5],
      attributes: [.class([Class.pf.colors.bg.purple150])],
      .div(
        attributes: [
          .class([
            Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
            Class.pf.colors.bg.purple150,
            Class.position.sticky(.desktop),
            Class.position.top0,
          ])
        ],
        hostsView(hosts: hosts)
      )
    )
  )
}

private func hostsView(hosts: [Host]) -> Node {
  return [
    .h1(
      attributes: [
        .class([
          Class.pf.type.responsiveTitle3,
          Class.pf.colors.fg.white,
          Class.padding([.mobile: [.bottom: 2]]),
        ])
      ],
      "Your hosts"
    ),
    .p(
      attributes: [
        .class([
          Class.pf.type.body.regular,
          Class.pf.colors.fg.white,
          Class.padding([.mobile: [.bottom: 3]]),
        ])
      ],
      "Brandon and Stephen are software engineers living in Brooklyn, New York. They previously helped ",
      "build and ",
      .a(
        attributes: [
          .class([Class.pf.colors.link.green, Class.type.underline]),
          .href(
            "https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd"),
        ],
        "open source"),
      " the ",
      .a(
        attributes: [
          .class([Class.pf.colors.link.green, Class.type.underline]),
          .href("https://www.kickstarter.com"),
        ], "Kickstarter"),
      " mobile apps."
    ),
    .fragment(hosts.map(hostView)),
  ]
}

private func hostView(host: Host) -> Node {
  return .div(
    attributes: [.class([Class.padding([.mobile: [.bottom: 3]])])],
    .img(
      attributes: [.src(host.image), .alt("Photo of \(host.name)"), .class([hostImgClass])]
    ),

    .div(
      attributes: [.class([hostBioClass])],
      .a(
        attributes: [
          .href(host.website),
          .class([
            Class.pf.colors.link.white,
            Class.h5,
            Class.type.bold,
          ]),
        ],
        .text(host.name)
      ),

      .p(
        attributes: [.class([Class.pf.colors.fg.white, Class.pf.type.body.regular])],
        .text(host.bio)
      ),

      .a(
        attributes: [
          .href(TwitterRouter().url(for: host.twitterRoute).absoluteString),
          .class([
            Class.pf.colors.link.white,
            Class.padding([.mobile: [.top: 2]]),
          ]),
        ],
        "Twitter",
        .img(
          base64: rightArrowSvgBase64(fill: "#ffffff"),
          type: .image(.svg),
          alt: "",
          attributes: [
            .class([Class.align.middle, Class.margin([.mobile: [.left: 1]])]),
            .width(16),
            .height(16),
          ]
        )
      )
    )
  )
}

private let aboutSectionView: Node = [
  .h1(attributes: [.class([Class.pf.type.responsiveTitle3])], "About"),
  .markdownBlock(
    """
    Point-Free is a video series that explores advanced topics in the Swift programming language. Each
    episode covers a topic that may seem complex and academic at first, but turns out to be quite simple.
    At the end of each episode we’ll ask _“what’s the point?!”_, so that we can bring the concepts back
    down to earth and show how these ideas can improve the quality of your code today.

    We’ve got so much we want to talk about, but just a quick overview of the things we have planned:
    """
  ),
  .p(
    .ul(
      attributes: [
        .class([Class.type.list.styleNone, Class.padding([.mobile: [.left: 4, .topBottom: 2]])])
      ],
      .li(
        .h5(attributes: [.class([bulletPointTitleClass])], "Pure functions and side effects"),
        .p(
          attributes: [
            .class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])
          ],
          """
          Side effects are one of the greatest sources of complexity in an application, and every program
          has this in common. After giving a proper definition of side effects and pure functions, we will
          show how to push the effects to the boundary of your application, leaving behind an
          understandable, testable and pure core.
          """)
      ),
      .li(
        .h5(
          attributes: [.class([bulletPointTitleClass])], "Code reuse through function composition"),
        .p(
          attributes: [
            .class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])
          ],
          """
          The most basic unit of code reusability comes in the form of simple function composition. We will
          show that by focusing on small atomic units that compose well, we can build large complex
          systems that are easy to understand.
          """
        )
      ),
      .li(
        .h5(attributes: [.class([bulletPointTitleClass])], "Maximizing the use of the type system"),
        .p(
          attributes: [
            .class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])
          ],
          """
          You’ve already seen how the type system helps prevent bugs by making sure you don’t accidentally
          add an integer to a string, or call a method on a “null” value, but it can do so much more. You
          can encode invariants of your application directly into the types so impossible application
          states are not representable and can never compile.
          """
        )
      ),
      .li(
        .h5(
          attributes: [.class([bulletPointTitleClass])],
          "Turning programming problems into algebraic problems"),
        .markdownBlock(
          """
          Algebraic problems are nice because they carry structure that can be manipulated in predictable
          and understandable ways. For example, if you have ever simplified a complicated boolean
          expression that looked like `a && b || a && c` to look like `a && (b || c)`, you were exploiting
          the algebraic stucture that `||` and `&&` have. Many programming problems can be given an
          algebraic structure that allows one to manipulate the problem in the same way you factored out
          the `a &&` from that expression.
          """
        )
      )
    )
  ),
  .p("And so much more…"),
]

private let openSourceSection: Node = [
  .h1(
    attributes: [.class([Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 3]])])],
    "Open source"
  ),

  .p(
    attributes: [.class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])],
    "When we ",
    .a(
      attributes: [
        .href(
          "https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd"),
        .class([Class.pf.colors.link.purple]),
      ],
      "open-sourced"
    ),
    " the entire ",
    .a(
      attributes: [
        .href("http://github.com/kickstarter/ios-oss"),
        .class([Class.pf.colors.link.purple]),
      ],
      "iOS"
    ),
    " and ",
    .a(
      attributes: [
        .href("http://github.com/kickstarter/android-oss"),
        .class([Class.pf.colors.link.purple]),
      ],
      "Android"
    ),
    " codebases at ",
    .a(
      attributes: [
        .href("http://www.kickstarter.com"),
        .class([Class.pf.colors.link.purple]),
      ],
      "Kickstarter"
    ),
    """
    , we saw that it was one of the best resources to show people how to build a large application in
    the functional style. It transcended any talks about the theoretical benefits or proposed
    simplifications. We could just show directly how embracing pure functions allowed us to write code that
    was understandable in isolation, and enabled us to write tests for every subtle edge case.
    """
  ),

  .p(
    attributes: [.class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])],
    """
    We wanted to be able to do that again, but this time we’d build an entire website in server-side Swift,
    all in the functional style! This meant we had to build nearly everything from scratch, from server
    middleware and routing to HTML views and CSS.
    """
  ),

  .p(
    attributes: [.class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])],
    """
    We discovered quite a few fun things along the way, like using Swift Playgrounds to design pages in an
    iterative fashion, and came to the conclusion that server-side Swift will soon be a viable backend
    language rivaling almost every other language out there.
    """
  ),

  .p(
    attributes: [.class([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])],
    "You can view the entire source code to this site on our GitHub organization, ",
    .a(
      attributes: [
        .href(GitHubRouter().url(for: .organization).absoluteString),
        .class([Class.pf.colors.link.purple]),
      ],
      .text(GitHubRouter().url(for: .organization).absoluteString)
    ),
    "."
  ),
]

private let bulletPointTitleClass =
  Class.pf.type.responsiveTitle6

private let hostImgClass = CssSelector.class("host-img")
private let hostBioClass = CssSelector.class("host-bio")
private let hostImgStyles =
  hostImgClass % (float(.left) <> width(.px(160)) <> height(.px(160)))
  <> queryOnly(screen, [minWidth(.px(832)), maxWidth(.px(1300))]) {
    hostImgClass % (width(.px(100)) <> height(.px(100)))
  }
private let hostBioStyles =
  hostBioClass % margin(left: .px(180))
  <> queryOnly(screen, [minWidth(.px(832)), maxWidth(.px(1300))]) {
    hostBioClass % margin(left: .px(120))
  }
