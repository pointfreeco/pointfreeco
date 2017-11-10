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

  let result = [EnvVars.Airtable.base1, EnvVars.Airtable.base2, EnvVars.Airtable.base3]
    .map(AppEnvironment.current.airtableStuff(conn.data))
    .reduce(lift(.left(unit))) { $0 <|> $1 }
    .run

  return result.map { conn.map(const($0)) }
}

func notifyUsOfNewSignup<I>(_ conn: Conn<I, String>) -> IO<Conn<I, String>> {
  return IO {

    let emailHtml = html([
      head([style(reset)]),
      body([
        p(["We just got a new signup for Point-Free! Wooooo!"]),
        p(["Email: ", .text(encode(conn.data))]),
        p(["Good job everyone!"])
        ])
      ])

    // Fire-and-forget to notify us that someone signed up
    _ = sendEmail(
      from: "Point-Free <brandon@pointfree.co>",
      to: "mbw234@gmail.com",
      subject: "New signup for Point-Free!",
      content: inj2(emailHtml)
      )
      .run
      .perform()

    return conn
  }
}

private func analytics<I, A>(_ conn: Conn<I, A>) -> IO<Conn<I, A>> {
  return IO {
    print("tracked analytics")
    return conn
  }
}
