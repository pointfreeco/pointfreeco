import Models
import Dependencies
import Foundation
import HttpPipeline
import PointFreeRouter

func joinMiddleware(_ conn: Conn<StatusLineOpen, Join>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.fireAndForget) var fireAndForget

  switch conn.data {
  case let .join(code: code, email: email):
    guard let currentUser = currentUser
    else {
      return conn
        .redirect(to: .join(.landing(code: code))) {
          $0.flash(.notice, "You must be logged in to complete that action.")
        }
    }

    let subscription: Subscription
    do {
      subscription = try await database.fetchSubscriptionByTeamInviteCode(code)
    } catch {
      return conn
        .redirect(to: .home) {
          $0.flash(.error, "Could not find that team.")
        }
    }

    guard let email = email
    else {
      do {
        try await database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
        fireAndForget {
          // TODO: send emails to new subscriber and owner
        }
        return conn
          .redirect(to: .account()) {
            $0.flash(.notice, "You now have access to Point-Free!")
          }
      } catch {
        return conn
          .redirect(to: .home) {
            $0.flash(
              .error,
              "Could not add to the team. Try again or contact support@pointfree.co."
            )
          }
      }
    }

    await fireAndForget {
      try await sendEmail(
        to: [email],
        subject: "Confirm your email to join the Point-Free team subscription.",
        content: .left("Test")
      )
    }
    return conn
      .redirect(to: .home) {
        $0.flash(.notice, "Confirmation email sent to \(email.rawValue).")
      }

  case let .landing(code):
    do {
      let subscription = try await database.fetchSubscriptionByTeamInviteCode(code)
      let isDomain = code.rawValue.contains(".")
      return conn
        .writeStatus(.ok)
        .respond(
          html: """
            <form action="/join/\(code)" method="post">
              <input type="text" name="email">
              <input type="hidden" name="code" value="\(code)">
            </form>
            """
        )
    } catch {
      return conn
        .redirect(to: .home) {
          $0.flash(.error, "We could not find that team.")
        }
    }
  }
}
