import Css
import Either
import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import Prelude
import Styleguide
import Tuple

let leaveTeamMiddleware: M<Tuple2<User?, SubscriberState>> =
  requireOwner
  <<< leaveTeam
  <| redirect(
    to: .account(),
    headersMiddleware: flash(.notice, "You are no longer a part of that team.")
  )

let joinTeamLandingMiddleware: M<Tuple3<User?, SubscriberState, Subscription.TeamInviteCode>> =
  writeStatus(.ok)
  >=> end

let joinTeamMiddleware: M<Tuple3<User?, SubscriberState, Subscription.TeamInviteCode>> =
  writeStatus(.ok)
  >=> end

private let requireOwner: MT<Tuple2<User?, SubscriberState>, Tuple2<User, SubscriberState>> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
  <<< filter(
    get2 >>> \.isOwner >>> (!),
    or: redirect(
      to: .account(),
      headersMiddleware: flash(.error, "You are the owner of the subscription, you can’t leave.")
    )
  )

private func leaveTeam<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, T2<User, Z>, Data> {

  return { conn in
    let user = get1(conn.data)

    return EitherIO {
      guard let subscriptionId = user.subscriptionId else { return }
      try await Current.database.removeTeammateUserIdFromSubscriptionId(user.id, subscriptionId)
      try await Current.database.deleteEnterpriseEmail(user.id)
    }
    .run
    .flatMap(
      either(
        const(
          conn
            |> redirect(
              to: .account(),
              headersMiddleware: flash(
                .error,
                "Something went wrong. Please try again or contact <support@pointfree.co>.")
            )
        ),
        const(middleware(conn))
      )
    )
  }
}

let removeTeammateMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
  <<< requireTeammate
  <| { conn -> IO<Conn<StatusLineOpen, Prelude.Unit>> in
    let (teammate, currentUser) = lower(conn.data)
    guard let teammateSubscriptionId = teammate.subscriptionId
    else { return pure(conn.map(const(unit))) }

    return EitherIO {
      let subscription = try await Current.database.fetchSubscriptionById(teammateSubscriptionId)
      // Validate the current user is the subscription owner,
      // and the fetched user is in fact the current user's teammate.
      guard subscription.userId == currentUser.id && subscription.id == teammate.subscriptionId
      else { throw unit }

      try await Current.database
        .removeTeammateUserIdFromSubscriptionId(teammate.id, teammateSubscriptionId)

      // Fire-and-forget emails to owner and teammate
      sendEmailsForTeammateRemoval(owner: currentUser, teammate: teammate)
        .run({ _ in })
    }
    .run
    .map(const(conn.map(const(unit))))
  }
  >=> redirect(to: .account(), headersMiddleware: flash(.notice, "That teammate has been removed."))

private let requireTeammate: MT<Tuple2<User.ID, User>, Tuple2<User, User>> = filterMap(
  over1 { id in
    IO { try? await Current.database.fetchUserById(id) }
  }
    >>> sequence1
    >>> map(require1),
  or: redirect(to: .account(), headersMiddleware: flash(.error, "Could not find that teammate."))
)

private func sendEmailsForTeammateRemoval(owner: User, teammate: User) -> Parallel<Prelude.Unit> {

  guard owner.id != teammate.id else {
    return pure(unit)
  }

  return zip2(
    parallel(
      sendEmail(
        to: [teammate.email],
        subject: "You have been removed from \(owner.displayName)’s Point-Free team",
        content: inj2(youHaveBeenRemovedEmailView(.teamOwner(owner)))
      )
      .run),
    parallel(
      sendEmail(
        to: [owner.email],
        subject: "Your teammate \(teammate.displayName) has been removed",
        content: inj2(teammateRemovedEmailView((owner, teammate)))
      )
      .run)
  )
  .map(const(unit))
}
