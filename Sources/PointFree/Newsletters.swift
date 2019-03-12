import ApplicativeRouter
import Either
import HttpPipeline
import Foundation
import Models
import PointFreeRouter
import Prelude
import Tuple

let expressUnsubscribeMiddleware =
  decryptUserAndNewsletter
    <| unsubscribeMiddleware
    >=> redirect(to: .home, headersMiddleware: flash(.notice, "You’re now unsubscribed."))

let expressUnsubscribeReplyMiddleware =
  requireUserAndNewsletter
    <| unsubscribeMiddleware
    >=> head(.ok)

private func requireUserAndNewsletter(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (User.Id, EmailSetting.Newsletter), Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, MailgunForwardPayload, Data> {

  return { conn in

    guard
      let (userId, newsletter) = Current.mailgun.userIdAndNewsletter(fromUnsubscribeEmail: conn.data.recipient),
      conn.data.verify(with: Current.envVars.appSecret)
      else {
        return conn |> head(.notAcceptable)
    }

    return conn.map(const((userId, newsletter))) |> middleware
  }
}

private func unsubscribeMiddleware<I>(
  _ conn: Conn<I, (User.Id, EmailSetting.Newsletter)>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (userId, newsletter) = conn.data

  return Current.database.fetchEmailSettingsForUserId(userId)
    .map { settings in settings.filter(^\.newsletter != newsletter) }
    .flatMap { settings in
      Current.database.updateUser(userId, nil, nil, settings.map(^\.newsletter), nil)
    }
    .run
    .map(const(conn.map(const(unit))))
}

private func decryptUserAndNewsletter(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, (User.Id, EmailSetting.Newsletter), Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Encrypted<String>, Data> {

  return { conn in
    guard
      let string = conn.data.decrypt(with: Current.envVars.appSecret),
      let (userId, newsletter) = expressUnsubscribeIso.apply(string)
      else {
        return conn.map(const(unit))
          |> redirect(
            to: .home,
            headersMiddleware: flash(
              .error, "An error occurred. Please contact <support@pointfree.co>."
            )
        )
    }

    return conn.map(const((userId, newsletter))) |> middleware
  }
}
