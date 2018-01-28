import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

let aboutResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, Stripe.Subscription.Status?, Route?>, Data> =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: aboutView,
      layoutData: { currentUser, subscriptionStatus, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: subscriptionStatus,
          currentUser: currentUser,
          data: unit,
          extraStyles: hostImgStyles,
          title: "About"
        )
    }
)

private let aboutView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 7], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          aboutSectionView.view(unit)
            + openSourceSection.view(unit)
      )
      ]),


    gridColumn(sizes: [.mobile: 12, .desktop: 5], [
      div(
        [
          `class`([
            Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
            Class.pf.colors.bg.purple150
            ])
        ],
        hostsView.view(unit)
      )
      ])
    ])
}

private let hostsView = View<Prelude.Unit> { _ in
  [
    h1(
      [
        `class`([
          Class.pf.type.responsiveTitle3,
          Class.pf.colors.fg.white,
          Class.padding([.mobile: [.bottom: 2]])
          ])
      ],
      [
        "Your hosts"
      ]
    )
    ]
    + hostView.view(.brandon)
    + hostView.view(.stephen)
}

private let hostView = View<Host> { host in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 3]])])], [
    gridColumn(sizes: [.mobile: 5, .desktop: 5], [
      img(
        src: host.image,
        alt: "Photo of \(host.name)",
        [`class`([hostImgClass])]
      )
      ]),

    gridColumn(sizes: [.mobile: 7, .desktop: 7], [
      div([
        p([`class`([Class.pf.colors.fg.white, Class.pf.type.body.regular, Class.type.bold])], [text(host.name)]),
        p([`class`([Class.pf.colors.fg.white, Class.pf.type.body.regular])], [text(host.bio)]),
        a(
          [
            href(twitterUrl(to: host.twitterRoute)),
            `class`([
              Class.pf.colors.link.white,
              Class.padding([.mobile: [.top: 2]])
              ])
          ],
          [
            "Twitter",
            img(
              base64: rightArrowSvgBase64(fill: "#ffffff"),
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), width(16), height(16)]
            )
          ]
        )
        ])
      ])
    ])
}

private let aboutSectionView = View<Prelude.Unit> { _ in
  [
    h1([`class`([Class.pf.type.responsiveTitle3])], ["About"]),
    markdownBlock("""
      Point-Free is a video series about functional programming and the Swift programming language. Each
      episode covers a topic that may seem complex and academic at first, but turns out to be quite simple.
      At the end of each episode we’ll ask _“what’s the point?!”_, so that we can bring the concepts back
      down to earth and show how these ideas can improve the quality of your code today.

      We’ve got so much we want to talk about, but just a quick overview of the things we have planned:
      """
    ),

    p([
      ul([`class`([Class.padding([.mobile: [.left: 3, .topBottom: 2]])])], [
        li([
          h5([`class`([bulletPointTitleClass])], ["Pure functions and side effects"]),
          p([
            """
            Side effects are one of the greatest sources of complexity in an application, and every program
            has this in common. After giving a proper definition of side effects and pure functions, we will
            show how to push the effects to the boundary of your application, leaving behind an
            understandable, testable and pure core.
            """])
          ]),

        li([
          h5([`class`([bulletPointTitleClass])], ["Code reuse through function composition"]),
          p([
            """
            The most basic unit of code reusability comes in the form of simple function composition. We will
            show how that by focusing on small atomic units that compose well, we can build large complex
            systems that are easy to understand.
            """])
          ]),

        li([
          h5([`class`([bulletPointTitleClass])], ["Maximizing the use of the type system"]),
          p([
            """
            You’ve already seen how the type system helps prevent bugs by making sure you don’t accidentally
            add an integer to a string, or call a method on a “null” value, but it can do so much more. You
            can encode invariants of your application directly into the types so impossible application
            states are not representable and can never compile.
            """
            ])
          ]),

        li([
          h5([`class`([bulletPointTitleClass])], ["Turning programming problems into algebraic problems"]),
          markdownBlock("""
            Algebraic problems are nice because they carry structure that can be manipulated in predictable
            and understandable ways. For example, if you have ever simplified a complicated boolean
            expression that looked like `a && b || a && c` to look like `a && (b || c)`, you were exploiting
            the algebraic stucture that `||` and `&&` have. Many programming problems can be given an
            algebraic structure that allows one to manipulate the problem in the same way you factored out
            the `a &&` from that expression.
            """
          )
          ]),
        ])
      ]),
    p(["And so much more…"]),
    ]
}

private let openSourceSection = View<Prelude.Unit> { _ in
  [
    h1([`class`([Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 2]])])], ["Open source"]),
    markdownBlock("""
      When we [open-sourced](https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd)
      the entire [iOS](http://github.com/kickstarter/ios-oss) and
      [Android](http://github.com/kickstarter/android-oss) codebases at
      [Kickstarter](https://www.kickstarter.com), we saw that it was one of the best resources to show people
      how to build a large application in the functional style. It transcended any talks about the
      theoretical benefits or proposed simplifications. We could just show directly how embracing pure
      functions allowed us to write code that was understandable in isolation, and enabled us to write tests
      for every subtle edge case.

      We wanted to be able to do that again, but this time we’d build an entire website in server-side Swift,
      all in the functional style! This meant we had to build nearly everything from scratch, from server
      middleware and routing to HTML views and CSS.

      We discovered quite a few fun things along the way, like using Swift Playgrounds to design pages in an
      iterative fashion, and came to the conclusion that server-side Swift will soon be a viable backend
      language rivaling almost every other language out there.

      You can view the entire source code to this site on our GitHub organization,
      [https://www.github.com/pointfreeco](https://www.github.com/pointfreeco).
      """
    )
  ]
}

private let bulletPointTitleClass =
  Class.pf.type.responsiveTitle5

private struct Host {
  let bio: String
  let image: String
  let name: String
  let twitterRoute: TwitterRoute

  static let brandon = Host(
    bio: """
Brandon did math for a very long time, and now enjoys talking about functional programming as a means to
better our craft as engineers.
""",
    image: "https://s3.amazonaws.com/pointfreeco-production/about-us/brando.jpg",
    name: "Brandon Williams",
    twitterRoute: .mbrandonw
  )

  static let stephen = Host(
    bio: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam nec massa euismod, posuere erat sed, mollis
leo. Phasellus et mauris.
""",
    image: "https://s3.amazonaws.com/pointfreeco-production/about-us/stephen.jpg",
    name: "Stephen Celis",
    twitterRoute: .stephencelis
  )
}

private let hostImgClass = CssSelector.class("host-img")
private let hostImgStyles: Stylesheet =
  hostImgClass % (
    width(.px(160)) <> height(.px(160))
    )
    <> queryOnly(screen, [minWidth(.px(832)), maxWidth(.px(1300))]) {
      hostImgClass % (
        width(.px(100)) <> height(.px(100))
      )
}
