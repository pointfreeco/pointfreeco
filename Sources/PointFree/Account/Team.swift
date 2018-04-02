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

let leaveTeamMiddleware: Middleware<StatusLineOpen, ResponseEnded, Database.User?, Data> =
  filterMap(pure, or: loginAndRedirect)
    <<< requireNonOwnerSubscriber
    <<< leaveTeam
    <| redirect(
      to: .account(.index),
      headersMiddleware: flash(.notice, "You are no longer a part of that team.")
)

private func leaveTeam(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.User, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Database.User, Data> {

  return { conn in

    let removed = conn.data.subscriptionId
      .map {
        AppEnvironment.current.database
          .removeTeammateUserIdFromSubscriptionId(conn.data.id, $0)
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

private func requireNonOwnerSubscriber(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.User, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Database.User, Data> {

  return { conn in

    let isOwnerOfSubscription = conn.data.subscriptionId
      .map(
        AppEnvironment.current.database.fetchSubscriptionById
          >>> mapExcept(requireSome)
          >>> map { $0.userId.unwrap == conn.data.id.unwrap }
      )
      ?? pure(false)

    return isOwnerOfSubscription
      .run
      .flatMap(
        either(
          const(
            conn
              |> redirect(
                to: .account(.index),
                headersMiddleware: flash(.error, "We couldn’t find your subscription.")
            )
          ),
          const(middleware(conn))
        )
    )
  }
}

let removeTeammateMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.User?>, Data> =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <| { conn -> IO<Conn<StatusLineOpen, Prelude.Unit>> in
      let (teammateId, currentUser) = lower(conn.data)
      guard let currentUserSubscriptionId = currentUser.subscriptionId
        else { return pure(conn.map(const(unit))) }

      let validateCurrentUserIsSubscriptionOwner = AppEnvironment.current.database
        .fetchSubscriptionById(currentUserSubscriptionId)
        .mapExcept(requireSome)
        .mapExcept { errorOrSubscription in
          errorOrSubscription.right?.userId.unwrap == .some(currentUser.id.unwrap)
            ? .right(unit)
            : .left(unit as Error)
      }

      return validateCurrentUserIsSubscriptionOwner
        .flatMap { _ in AppEnvironment.current.database.fetchUserById(teammateId) }
        .mapExcept(requireSome)
        .mapExcept { errorOrTeammate in
          // Validate that the fetched user is in fact the current user's teammate.
          errorOrTeammate.right?.subscriptionId?.unwrap == .some(currentUserSubscriptionId.unwrap)
            ? errorOrTeammate
            : .left(unit)
        }
        .flatMap { teammate in
          AppEnvironment.current.database
            .removeTeammateUserIdFromSubscriptionId(teammate.id, currentUserSubscriptionId)
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
    >-> redirect(to: .account(.index))

private func sendEmailsForTeammateRemoval(owner: Database.User, teammate: Database.User) -> Parallel<Prelude.Unit> {

  return zip2(
    parallel(sendEmail(
      to: [teammate.email],
      subject: "You have been removed from \(owner.name ?? owner.email.unwrap)’s Point-Free team",
      content: inj2(youHaveBeenRemovedEmailView.view((owner, teammate)))
      )
      .run),
    parallel(sendEmail(
      to: [owner.email],
      subject: "Your teammate \(teammate.name ?? teammate.email.unwrap) has been removed",
      content: inj2(teammateRemovedEmailView.view((owner, teammate)))
      )
      .run)
  )
  .map(const(unit))
}
