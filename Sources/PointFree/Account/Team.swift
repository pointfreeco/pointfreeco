import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

let leaveTeamMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, SubscriberState>, Data> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filter(
      get2 >>> ^\.isOwner >>> (!),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.error, "You are the owner of the subscription, you can’t leave.")
      )
    )
    <<< leaveTeam
    <| redirect(
      to: .account(.index),
      headersMiddleware: flash(.notice, "You are no longer a part of that team.")
)

private func leaveTeam<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, Z>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, Z>, Data> {

  return { conn in
    let user = get1(conn.data)

    let removed = user.subscriptionId
      .map {
        Current.database
          .removeTeammateUserIdFromSubscriptionId(user.id, $0)
      }
      ?? pure(unit)

    return removed
      .run
      .flatMap(
        either(
          const(
            conn
              |> redirect(
                to: .account(.index),
                headersMiddleware: flash(.error, "Something went wrong.")
            )
          ),
          const(middleware(conn))
        )
    )
  }
}

let removeTeammateMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.User?>, Data> =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      over1(
        Current.database.fetchUserById
          >>> mapExcept(requireSome)
          >>> ^\.run
          >>> map(^\.right)
        )
        >>> sequence1
        >>> map(require1),
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Could not find that teammate."))
    )
    <| { conn -> IO<Conn<StatusLineOpen, Prelude.Unit>> in
      let (teammate, currentUser) = lower(conn.data)
      guard let teammateSubscriptionId = teammate.subscriptionId
        else { return pure(conn.map(const(unit))) }

      let validateSubscriptionData = Current.database
        .fetchSubscriptionById(teammateSubscriptionId)
        .mapExcept(requireSome)
        .mapExcept { errorOrSubscription in
          // Validate the current user is the subscription owner
          errorOrSubscription.right?.userId == .some(currentUser.id)
            // Validate that the fetched user is in fact the current user's teammate.
            && errorOrSubscription.right?.id == teammate.subscriptionId
            ? .right(unit)
            : .left(unit as Error)
      }

      return validateSubscriptionData
        .flatMap { _ in
          Current.database
            .removeTeammateUserIdFromSubscriptionId(teammate.id, teammateSubscriptionId)
            .flatMap { x -> EitherIO<Error, Prelude.Unit> in

              // Fire-and-forget emails to owner and teammate
              sendEmailsForTeammateRemoval(owner: currentUser, teammate: teammate)
                .run({ _ in })

              return pure(x)
          }
        }
        .run
        .map(const(conn.map(const(unit))))
    }
    >=> redirect(to: .account(.index), headersMiddleware: flash(.notice, "That teammate has been removed."))

private func sendEmailsForTeammateRemoval(owner: Database.User, teammate: Database.User) -> Parallel<Prelude.Unit> {

  guard owner.id != teammate.id else {
    return pure(unit)
  }

  return zip2(
    parallel(sendEmail(
      to: [teammate.email],
      subject: "You have been removed from \(owner.displayName)’s Point-Free team",
      content: inj2(youHaveBeenRemovedEmailView.view((owner, teammate)))
      )
      .run),
    parallel(sendEmail(
      to: [owner.email],
      subject: "Your teammate \(teammate.displayName) has been removed",
      content: inj2(teammateRemovedEmailView.view((owner, teammate)))
      )
      .run)
  )
  .map(const(unit))
}
