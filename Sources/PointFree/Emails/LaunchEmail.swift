import CssReset
import Either
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide

let launchEmailView = simpleEmailLayout(launchEmailBody)
  .contramap { data in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Thanks for signing up!",
      preheader: "We’re very excited to finally get the series off the ground!",
      data: data
    )
}

private let launchEmailBody = View<Prelude.Unit> { _ in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["We’ve launched!"]),
          p([
            """
            We’re very excited to finally get the series off the ground! We first announced Point-Free back
            in July, and since then we’ve been hard at work building the site in Swift, mostly from scratch.
            In fact, we even
            """,
            " ",
            a([href(gitHubUrl(to: .repo(.pointfreeco)))], ["open-sourced"]),
            " ",
            """
            the entire code base of the site, including the code that sent this very email!
            """
            ]),
          p([
            """
            We’ve got so much we want to talk about, but just a quick overview of the things we have planned:
            """
            ]),
          p([
            ul([`class`([Class.padding([.mobile: [.left: 3]])])], [
              li(["Pure functions and side effects"]),
              li(["Code reuse through function composition"]),
              li(["Maximizing the use of the type-system"]),
              li(["Turning programming problems into algebraic problems"]),
              ])
            ]),
          p([
            """
            And so much more…
            """
            ]),
          p([
            """
            If any of that sounds interesting to you, please consider subscribing! We have monthly, yearly and
            team plan to choose from.
            """
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .pricing(nil, expand: nil))), `class`([Class.pf.components.button(color: .purple)])],
              ["Subscribe to Point-Free!"])
            ]),
          p([`class`([Class.padding([.mobile: [.top: 2]])])], [
            "Your hosts,"
            ]),
          p([
            a([href(twitterUrl(to: .mbrandonw))], [.text(unsafeUnencodedString("Brandon&nbsp;Williams"))]),
            " & ",
            a([href(twitterUrl(to: .stephencelis))], [.text(unsafeUnencodedString("Stephen&nbsp;Celis"))]),
            ])
          ])
        ])
      ])
    ])
}
