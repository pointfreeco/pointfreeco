import ApplicativeRouter
import Either
import HttpPipeline
import Foundation
import Prelude
import Tuple

let expressUnsubscribeMiddleware =
  unsubscribeMiddleware
    >-> redirect(to: .secretHome)

let expressUnsubscribeReplyMiddleware =
  requireUserAndNewsletter
    <| unsubscribeMiddleware
    >-> writeStatus(.ok)
    >-> respond(text: "OK")

private func requireUserAndNewsletter(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.EmailSetting.Newsletter>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, MailgunForwardPayload, Data> {

  return { conn in

    guard let newsletter = Database.EmailSetting.Newsletter(unsubscribeEmail: conn.data.recipient.unwrap)
      else {
        return conn
          |> writeStatus(.notAcceptable)
          >-> respond(text: "Not acceptable")
    }

    return AppEnvironment.current.database.fetchUserByEmail(conn.data.sender)
      .mapExcept(requireSome)
      .run
      .flatMap(
        either(
          const(
            conn
              |> writeStatus(.notAcceptable)
              >-> respond(text: "Not acceptable")
          ),

          { user in conn.map(const(user.id .*. newsletter .*. unit)) |> middleware }
        )
    )
  }
}

private func unsubscribeMiddleware<I>(
  _ conn: Conn<I, Tuple2<Database.User.Id, Database.EmailSetting.Newsletter>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (userId, newsletter) = lower(conn.data)

  return AppEnvironment.current.database.fetchEmailSettingsForUserId(userId)
    .map { settings in settings.filter(^\.newsletter != newsletter) }
    .flatMap { settings in
      AppEnvironment.current.database.updateUser(userId, nil, nil, settings.map(^\.newsletter))
    }
    .run
    .map(const(conn.map(const(unit))))
}
