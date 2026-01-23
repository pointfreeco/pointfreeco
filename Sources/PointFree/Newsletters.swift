import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Tagged

func expressUnsubscribeMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  payload: Encrypted<String>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.envVars.appSecret) var appSecret
  guard
    let string = payload.decrypt(with: appSecret),
    let (userId, newsletter) = try? ExpressUnsubscribe().parse(string)
  else {
    return conn.redirect(to: .home) {
      $0.flash(.error, "An error occurred. Please contact <support@pointfree.co>.")
    }
  }

  await unsubscribe(userID: userId, newsletter: newsletter)
  return conn.redirect(to: .home) {
    $0.flash(.notice, "You’re now unsubscribed.")
  }
}

func expressUnsubscribeReplyMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  payload: MailgunForwardPayload
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.mailgun) var mailgun
  @Dependency(\.envVars.mailgun.apiKey) var mailgunApiKey

  guard
    let (userId, newsletter) = mailgun.userIdAndNewsletter(
      fromUnsubscribeEmail: payload.recipient
    ),
    mailgun.verify(payload: payload, with: mailgunApiKey)
  else {
    return conn.head(.notAcceptable)
  }

  await unsubscribe(userID: userId, newsletter: newsletter)
  return conn.head(.ok)
}

private func unsubscribe(
  userID: User.ID,
  newsletter: EmailSetting.Newsletter
) async {
  @Dependency(\.database) var database

  await withErrorReporting {
    let settings = try await database.fetchEmailSettings(userID: userID)
      .filter { $0.newsletter != newsletter }
    try await database.updateUser(id: userID, emailSettings: settings.map(\.newsletter))
  }
}
