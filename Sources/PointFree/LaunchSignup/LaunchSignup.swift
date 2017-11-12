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
    >-> flashErrors(on: unit)
    >-> { $0 |> redirect(to: path(to: .home(signedUpSuccessfully: $0.data.guaranteedRight.0 == nil))) }

// Middleware<I, I, E, Never, A, (E?, A)>

//

struct Flash {
  let messages: [String]
}

//typealias Flash<A> = Tuple2<Flash, A>

func flashErrors<I, E, A>(on: A) -> Middleware<I, I, E, Never, A, (E?, A)> {
  return pure <<< mapConn(pure <<< either({ ($0, on) }, { (nil, $0) }))
}

//func flashErrors<I, E, A>(on: A) -> Middleware<I, I, E, Never, A, Flash<A>> {
//  fatalError()
//  //return pure <<< mapConn(pure <<< either({ ($0, on) }, { (nil, $0) }))
//}

private func airtableStuff<I>(_ conn: Conn<I, Never, String>) -> IO<Conn<I, Prelude.Unit, Prelude.Unit>> {

  let result = [EnvVars.Airtable.base1, EnvVars.Airtable.base2, EnvVars.Airtable.base3]
    .map(AppEnvironment.current.airtableStuff(conn.data.guaranteedRight))
    .reduce(lift(.left(unit))) { $0 <|> $1 }
    .run
  
  return result.map { conn.mapConn(const($0)) }
}

// (E -> F) -> Conn<I, E, A> -> Conn<I, F, A>

// ((Either<E, A>) -> Either<F, B>) -> Conn<I, E, A> -> Conn<I, F, B>

// (A -> Either<F, B>) -> Conn<I, Never, A> -> Conn<I, F, B>

// mapExceptT :: (m (Either e a) -> n (Either e' b)) -> ExceptT e m a -> ExceptT e' n b

// ((E | A) -> (F | B)) -> (Conn<I, E, A>) -> Conn<I, E | F, B>



private func handleError<I>(_ conn: Conn<I, Prelude.Unit, Prelude.Unit>) -> IO<Conn<I, Never, Route>> {

  return pure <| conn.mapConn(const(.right(.home(signedUpSuccessfully: conn.data.isRight))))
}

func notifyUsOfNewSignup<I>(_ conn: Conn<I, Never, String>) -> IO<Conn<I, Never, String>> {
  return IO {

    // Fire-and-forget to notify us that someone signed up
    _ = sendEmail(
      from: "Point-Free <support@pointfree.co>",
      to: ["brandon@pointfree.co", "stephen@pointfree.co"],
      subject: "New signup for Point-Free!",
      content: inj2(notifyUsView.view(conn.data.guaranteedRight))
      )
      .run
      .perform()

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

private func analytics<I, A>(_ conn: Conn<I, Never, A>) -> IO<Conn<I, Never, A>> {
  return IO {
    print("tracked analytics")
    return conn
  }
}
