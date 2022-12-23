import Either
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tagged
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
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, (User.ID, EmailSetting.Newsletter), Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, MailgunForwardPayload, Data> {

  return { conn in

    guard
      let (userId, newsletter) = Current.mailgun.userIdAndNewsletter(
        fromUnsubscribeEmail: conn.data.recipient),
      Current.mailgun.verify(payload: conn.data, with: Current.envVars.mailgun.apiKey)
    else {
      return conn |> head(.notAcceptable)
    }

    return conn.map(const((userId, newsletter))) |> middleware
  }
}

private func unsubscribeMiddleware<I>(
  _ conn: Conn<I, (User.ID, EmailSetting.Newsletter)>
) -> IO<Conn<I, Prelude.Unit>> {

  let (userId, newsletter) = conn.data

  return EitherIO {
    let settings = try await Current.database.fetchEmailSettingsForUserId(userId)
      .filter { $0.newsletter != newsletter }
    try await Current.database.updateUser(id: userId, emailSettings: settings.map(\.newsletter))
  }
  .run
  .map(const(conn.map(const(unit))))
}

private func decryptUserAndNewsletter(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, (User.ID, EmailSetting.Newsletter), Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Encrypted<String>, Data> {

  return { conn in
    guard
      let string = conn.data.decrypt(with: Current.envVars.appSecret),
      let (userId, newsletter) = try? expressUnsubscribe.parse(string)
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
