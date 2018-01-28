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

  return zip(
    parallel(sendEmail(
      to: [teammate.email],
      subject: "You have been removed from \(owner.name)’s Point-Free team",
      content: inj2(youHaveBeenRemovedEmailView.view((owner, teammate)))
      )
      .run),
    parallel(sendEmail(
      to: [owner.email],
      subject: "Your teammate \(teammate.name) has been removed",
      content: inj2(teammateRemovedEmailView.view((owner, teammate)))
      )
      .run)
  )
  .map(const(unit))
}
