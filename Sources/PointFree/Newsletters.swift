import ApplicativeRouter
import Either
import HttpPipeline
import Foundation
import Prelude
import Tuple

let expressUnsubscribeMiddleware =
  unsubscribeMiddleware
    >=> redirect(to: .home, headersMiddleware: flash(.notice, "You’re now unsubscribed."))

let expressUnsubscribeReplyMiddleware =
  requireUserAndNewsletter
    <| unsubscribeMiddleware
    >=> head(.ok)

private func requireUserAndNewsletter(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.EmailSetting.Newsletter>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, MailgunForwardPayload, Data> {

  return { conn in

    guard let (userId, newsletter) = userIdAndNewsletter(fromUnsubscribeEmail: conn.data.recipient)
      else {
        return conn
          |> head(.notAcceptable)
    }

    return conn.map(const(userId .*. newsletter .*. unit))
      |> middleware
  }
}

private func unsubscribeMiddleware<I>(
  _ conn: Conn<I, Tuple2<Database.User.Id, Database.EmailSetting.Newsletter>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (userId, newsletter) = lower(conn.data)

  return Current.database.fetchEmailSettingsForUserId(userId)
    .map { settings in settings.filter(^\.newsletter != newsletter) }
    .flatMap { settings in
      Current.database.updateUser(userId, nil, nil, settings.map(^\.newsletter), nil)
    }
    .run
    .map(const(conn.map(const(unit))))
}
