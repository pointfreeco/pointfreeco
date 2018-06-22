import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

let aboutResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: aboutView,
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: unit,
          extraStyles: hostImgStyles <> hostBioStyles,
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

    gridColumn(
      sizes: [.mobile: 12, .desktop: 5],
      [`class`([Class.pf.colors.bg.purple150])],
      [
        div(
          [
            `class`([
              Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
              Class.pf.colors.bg.purple150,
              Class.position.sticky(.desktop),
              Class.position.top0
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
    ),
    p([`class`([Class.pf.type.body.regular, Class.pf.colors.fg.white, Class.padding([.mobile: [.bottom: 3]])])], [
      "Brandon and Stephen are software engineers living in Brooklyn, New York. They previously helped ",
      "build and ",
      a([`class`([Class.pf.colors.link.green, Class.type.underline]), href("https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd")],
        ["open source"]),
      " the ",
      a([`class`([Class.pf.colors.link.green, Class.type.underline]), href("https://www.kickstarter.com")], ["Kickstarter"]),
      " mobile apps."
      ])
    ]
    + hostView.view(.brandon)
    + hostView.view(.stephen)
}

private let hostView = View<Host> { host in
  div(
    [`class`([Class.padding([.mobile: [.bottom: 3]])])],
    [
      img(
        src: host.image,
        alt: "Photo of \(host.name)",
        [`class`([hostImgClass])]
      ),

      div(
        [`class`([hostBioClass])],
        [
          a(
            [
              href(host.website),
              `class`([
                Class.pf.colors.link.white,
                Class.h5,
                Class.type.bold
                ])
            ],
            [
              text(host.name)
            ]
          ),

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
        ]
      )
    ]
  )
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
      ul([`class`([Class.type.list.styleNone, Class.padding([.mobile: [.left: 4, .topBottom: 2]])])], [
        li([
          h5([`class`([bulletPointTitleClass])], ["Pure functions and side effects"]),
          p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
            """
            Side effects are one of the greatest sources of complexity in an application, and every program
            has this in common. After giving a proper definition of side effects and pure functions, we will
            show how to push the effects to the boundary of your application, leaving behind an
            understandable, testable and pure core.
            """])
          ]),

        li([
          h5([`class`([bulletPointTitleClass])], ["Code reuse through function composition"]),
          p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
            """
            The most basic unit of code reusability comes in the form of simple function composition. We will
            show that by focusing on small atomic units that compose well, we can build large complex
            systems that are easy to understand.
            """])
          ]),

        li([
          h5([`class`([bulletPointTitleClass])], ["Maximizing the use of the type system"]),
          p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
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
    h1([`class`([Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 3]])])], ["Open source"]),
    p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
      "When we ",
      a([href("https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd"), `class`([Class.pf.colors.link.purple])], ["open-sourced"]),
      " the entire ",
      a([href("http://github.com/kickstarter/ios-oss"), `class`([Class.pf.colors.link.purple])], ["iOS"]),
      " and ",
      a([href("http://github.com/kickstarter/android-oss"), `class`([Class.pf.colors.link.purple])], ["Android"]),
      " codebases at ",
      a([href("http://www.kickstarter.com"), `class`([Class.pf.colors.link.purple])], ["Kickstarter"]),
      """
      , we saw that it was one of the best resources to show people how to build a large application in
      the functional style. It transcended any talks about the theoretical benefits or proposed
      simplifications. We could just show directly how embracing pure functions allowed us to write code that
      was understandable in isolation, and enabled us to write tests for every subtle edge case.
      """
      ]),

    p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
      """
      We wanted to be able to do that again, but this time we’d build an entire website in server-side Swift,
      all in the functional style! This meant we had to build nearly everything from scratch, from server
      middleware and routing to HTML views and CSS.
      """]),

    p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
      """
      We discovered quite a few fun things along the way, like using Swift Playgrounds to design pages in an
      iterative fashion, and came to the conclusion that server-side Swift will soon be a viable backend
      language rivaling almost every other language out there.
      """]),

    p([`class`([Class.pf.type.body.regular, Class.padding([.mobile: [.bottom: 2]])])], [
      "You can view the entire source code to this site on our GitHub organization, ",
      a([href(gitHubUrl(to: .organization)), `class`([Class.pf.colors.link.purple])], [text(gitHubUrl(to: .organization))]),
      "."
      ])
  ]
}

private let bulletPointTitleClass =
  Class.pf.type.responsiveTitle6

private struct Host {
  let bio: String
  let image: String
  let name: String
  let twitterRoute: TwitterRoute
  let website: String

  static var brandon: Host {
    return Host(
      bio: """
Brandon did math for a very long time, and now enjoys talking about functional programming as a means to
better our craft as engineers.
""",
      image: Current.assets.brandonImgSrc,
      name: "Brandon Williams",
      twitterRoute: .mbrandonw,
      website: "http://www.fewbutripe.com"
    )
  }

  static var stephen: Host {
    return Host(
      bio: """
Stephen taught himself to code when he realized his English degree didn’t pay the bills. He became a
functional convert and believer after years of objects.
""",
      image: Current.assets.stephenImgSrc,
      name: "Stephen Celis",
      twitterRoute: .stephencelis,
      website: "http://www.stephencelis.com"
    )
  }
}

public struct Assets {
  public var brandonImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/about-us/brando.jpg"
  public var stephenImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/about-us/stephen.jpg"
  public var emailHeaderImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-email-header.png"
  public var pointersEmailHeaderImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-pointers-header.jpg"
}

private let hostImgClass = CssSelector.class("host-img")
private let hostBioClass = CssSelector.class("host-bio")
private let hostImgStyles =
  hostImgClass % (
    float(.left) <> width(.px(160)) <> height(.px(160))
    )
    <> queryOnly(screen, [minWidth(.px(832)), maxWidth(.px(1300))]) {
      hostImgClass % (
        width(.px(100)) <> height(.px(100))
      )
}
private let hostBioStyles =
  hostBioClass % margin(left: .px(180))
    <> queryOnly(screen, [minWidth(.px(832)), maxWidth(.px(1300))]) {
      hostBioClass % margin(left: .px(120))
}
