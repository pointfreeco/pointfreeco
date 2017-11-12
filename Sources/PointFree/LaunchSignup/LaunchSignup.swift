import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Optics

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

    // Fire-and-forget to notify us that someone signed up
    parallel(
      sendEmail(
        from: "Point-Free <support@pointfree.co>",
        to: ["brandon@pointfree.co", "stephen@pointfree.co"],
        subject: "New signup for Point-Free!",
        content: inj2(notifyUsView.view(conn.data))
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

private func analytics<I, A>(_ conn: Conn<I, A>) -> IO<Conn<I, A>> {
  return IO {
    print("tracked analytics")
    return conn
  }
}
