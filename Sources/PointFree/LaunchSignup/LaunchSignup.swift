import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide

let homeResponse =
  analytics
    >-> writeStatus(.ok)
    >-> respond(launchSignupView)

let signupResponse =
  analytics
    >-> notifyUsOfNewSignup
    >-> airtableStuff
    >-> redirect(to: path(to: .home(signedUpSuccessfully: true)))

private func airtableStuff<I>(_ conn: Conn<I, String>) -> IO<Conn<I, Either<Prelude.Unit, Prelude.Unit>>> {

  let result = [
    AppEnvironment.current.envVars.airtable.base1,
    AppEnvironment.current.envVars.airtable.base2,
    AppEnvironment.current.envVars.airtable.base3
    ]
    .map(AppEnvironment.current.airtableStuff(conn.data))
    .reduce(lift(.left(unit))) { $0 <|> $1 }
    .run

  return result.map { conn.map(const($0)) }
}

func notifyUsOfNewSignup<I>(_ conn: Conn<I, String>) -> IO<Conn<I, String>> {
  return IO {

    // Fire-and-forget to send some emails
    zip(
      // Notify us that someone signed up
      parallel <| sendEmail(
        from: "Point-Free <support@pointfree.co>",
        to: ["brandon@pointfree.co", "stephen@pointfree.co"],
        subject: "New signup for Point-Free!",
        content: inj2(notifyUsView.view(conn.data))
        )
        .run,

      //
      parallel <| sendEmail(
        from: "Point-Free <support@pointfree.co>",
        to: [conn.data],
        subject: "New signup for Point-Free!",
        content: inj2(launchSignupConfirmationEmailView.view(unit))
        )
        .run
      )
      .run({ _ in })

    return conn
  }
}

let notifyUsView = View<String> { email in
  html([
    head([style(reset)]),
    body([
      p(["We just got a new signup for Point-Free! Wooooo!"]),
      p(["Email: ", .text(encode(email))]),
      p(["Good job everyone!"])
      ])
    ])
}

let launchSignupConfirmationEmailView = View<Prelude.Unit> { _ in
  document([
    html([
      head([
        style(styleguide),
        ]),

      body([
        gridRow([
          gridColumn(sizes: [:], [
            div([`class`([Class.padding.all(2)])], [
              h2([`class`([Class.h2])], ["Thanks for signing up!"]),
              p([`class`([Class.padding.topBottom(2)])], [
                "Point-Free will be launching soon, and you’ll be the first to know. Until then, check out our GitHub organization ",
                a([href("https://www.github.com/pointfreeco")], ["@pointfreeco"]),
                ", where we have open-sourced all of the code that powers this site. Also, follow us on Twitter ",
                a([href("https://www.twitter.com/pointfreeco")], ["@pointfreeco"]),
                " to see our progress in making the site and learn more about the interesting techniques we are using."
                ]),
              p([
                a([href("https://www.twitter.com/mbrandonw")], ["Brandon Williams"]),
                br,
                a([href("https://www.twitter.com/stephencelis")], ["Stephen Celis"]),
                ]),
              p([
                a([href(url(to: .home(signedUpSuccessfully: nil)))], ["Point-Free"]),
                ])
              ])
            ])
          ])
        ])
      ])
    ])
}

private func analytics<I, A>(_ conn: Conn<I, A>) -> IO<Conn<I, A>> {
  return IO {
    print("tracked analytics")
    return conn
  }
}

public func zip<A, B>(_ lhs: Parallel<A>, _ rhs: Parallel<B>) -> Parallel<(A, B)> {
  return tuple <¢> lhs <*> rhs
}
