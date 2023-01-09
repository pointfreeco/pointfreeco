import Dependencies
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
  @Dependency(\.mailgun) var mailgun
  @Dependency(\.envVars.mailgun.apiKey) var mailgunApiKey

  return { conn in

    guard
      let (userId, newsletter) = mailgun.userIdAndNewsletter(
        fromUnsubscribeEmail: conn.data.recipient),
      mailgun.verify(payload: conn.data, with: mailgunApiKey)
    else {
      return conn |> head(.notAcceptable)
    }

    return conn.map(const((userId, newsletter))) |> middleware
  }
}

private func unsubscribeMiddleware<I>(
  _ conn: Conn<I, (User.ID, EmailSetting.Newsletter)>
) -> IO<Conn<I, Prelude.Unit>> {
  @Dependency(\.database) var database

  let (userId, newsletter) = conn.data

  return EitherIO {
    let settings = try await database.fetchEmailSettingsForUserId(userId)
      .filter { $0.newsletter != newsletter }
    try await database.updateUser(id: userId, emailSettings: settings.map(\.newsletter))
  }
  .run
  .map(const(conn.map(const(unit))))
}

private func decryptUserAndNewsletter(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, (User.ID, EmailSetting.Newsletter), Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, Encrypted<String>, Data> {
  @Dependency(\.envVars.appSecret) var appSecret

  return { conn in
    guard
      let string = conn.data.decrypt(with: appSecret),
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
