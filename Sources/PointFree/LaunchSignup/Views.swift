import Css
import CssReset
import Foundation
import Html
import HtmlCssSupport
import Prelude

private let view: View<Bool?> = View { success in
  document(
    [
      html(
        [
          head(
            [
              title("Point-Free — A weekly video series on Swift and functional programming."),
              style(reset <> stylesheet),
              meta(viewport: .width(.deviceWidth), .initialScale(1)),
              googleAnalytics,
            ]
          ),
          body(
            success == .some(true)
              ? [ successSectionNode, headerNode ]
              : [ headerNode, defaultSectionNode ]
          )
        ]
      )
    ]
  )
}

private let headerNode = header(
  [ `class`("hero") ],
  [
    div(
      [ `class`("container") ],
      [
        a(
          [href("/")],
          [img(base64: logoSvgBase64, mediaType: .image(.svg), alt: "Point Free", [`class`("logo")])]
        ),
        h1(["A new weekly Swift video series exploring functional programming and more."]),
        h2(["Coming really, really soon."]),
        footer(
          [
            p(
              [
                "Made by ",
                a(
                  [href("https://twitter.com/mbrandonw"), target(.blank)],
                  ["@mbrandonw"]
                ),
                " and ",
                a(
                  [href("https://twitter.com/stephencelis"), target(.blank)],
                  ["@stephencelis"]
                ),
                "."
              ]
            ),
            p(
              [
                "Built with ",
                a(
                  [href("https://swift.org"), target(.blank)],
                  ["Swift"]
                ),
                " and open-sourced on ",
                a(
                  [href("https://github.com/pointfreeco/pointfreeco"), target(.blank)],
                  ["GitHub"]
                ),
              ]
            )
          ]
        )
      ]
    )
  ]
)

private let successSectionNode = section(
  [`class`("success"), style("background-color: #79f2b0")],
  [
    div(
      [ `class`("container") ],
      [
        img(base64: checkmarkSvgBase64, mediaType: .image(.svg), alt: "", []),
        h1(["We'll be in touch."]),
        p(["Help spread the word about Point-Free!"]),
        twitterLink,
        facebookLink
      ]
    )
  ]
)

private let defaultSectionNode = section(
  [`class`("signup")],
  [
    form(
      [`class`("container"), action(link(to: .launchSignup(email: "", csrf: ""))), method(.post)],
      [
        input([name("csrf"), value("deadbeef"), hidden(true)]),
        
        h3(["Get notified when we launch"]),
        label([`for`("email")], ["Email address"] ),
        input(
          [
            type(.email),
            placeholder("hi@example.com"),
            name("email"),
            id("email")
          ]
        ),
        input(
          [
            type(.submit),
            value("Sign up")
          ]
        )
      ]
    )
  ]
)

private let googleAnalytics: ChildOf<Element.Head> = script(
"""
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-106218876-1', 'auto');
ga('send', 'pageview');
"""
)

private let twitterShareHref = { () -> String in
  var components = URLComponents(string: "https://twitter.com/intent/tweet")!
  components.queryItems = [
    URLQueryItem(name: "text", value: "A new weekly video series on Swift and functional programming is coming soon!"),
    URLQueryItem(name: "url", value: "http://www.pointfree.co"),
    URLQueryItem(name: "via", value: "pointfreeco"),
  ]
  return components.string!
}()

private let twitterLink = a(
  [ href(twitterShareHref), target(.blank), `class`("social-btn") ],
  [ img(base64: twitterIconSvgBase64, mediaType: .image(.svg), alt: "Share on Twitter", []) ]
)

private let facebookShareHref = "https://www.facebook.com/sharer/sharer.php?u=http%3A//www.pointfree.co"

private let facebookLink = a(
  [ href(facebookShareHref), target(.blank), `class`("social-btn") ],
  [ img(base64: facebookIconSvgBase64, mediaType: .image(.svg), alt: "Share on Facebook", []) ]
)

let launchSignupView =
  metaLayout(view)
    .contramap(
      Metadata.create(
        description: "A weekly video series on Swift and functional programming. Each week we discuss a topic and then ask: “What’s the point!?”",
        image: "https://s3.amazonaws.com/pointfree.co/twitter-card-large.png",
        title: "Point-Free",
        twitterCard: "summary_large_image",
        twitterSite: "@pointfreeco",
        type: "website",
        url: "https://www.pointfree.co"
      )
)
