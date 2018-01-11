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

let teamResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <| { conn -> IO<Conn<StatusLineOpen, Tuple3<[Database.TeamInvite], [Database.User], Database.User>>> in
      sequential(
        // Fetch invites and teammates in parallel.
        zip(
          parallel(AppEnvironment.current.database.fetchTeamInvites(conn.data.first.id).run)
            .map { $0.right ?? [] },
          parallel(AppEnvironment.current.database.fetchSubscriptionTeammatesByOwnerId(conn.data.first.id).run)
            .map { $0.right ?? [] }
          )
        )
        .map { conn.map(const(($0 .*. $1 .*. conn.data))) }
    }
    >-> writeStatus(.ok)
    >-> respond(teamView.contramap(lower))

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

private let teamView = View<([Database.TeamInvite], [Database.User], Database.User)> { invites, teammates, currentUser in
  [
    h1(["Your team"]),
    ul(
      teammates.map { teammate in
        li([
          .text(encode(teammate.name)),
          form([action(path(to: .team(.remove(teammate.id)))), method(.post)], [
            input([type(.submit), value("Remove")])
            ]),
          ])
      }
    ),

    h1(["Current invites"]),
    p(["These teammates have been invited, but have not yet accepted."]),
    ul(
      invites.map { invite in
        li([
          .text(encode(invite.email.unwrap)),
          form([action(path(to: .invite(.resend(invite.id)))), method(.post)], [
            input([type(.submit), value("Resend")])
            ]),
          form([action(path(to: .invite(.revoke(invite.id)))), method(.post)], [
            input([type(.submit), value("Revoke")])
            ]),
          ])
      }
    ),

    h1(["Invite more"]),
    p(["You have 10 open spots on your team. Invite a team member below:"]),
    form([action(path(to: .invite(.send(nil)))), method(.post)], [
      input([type(.email), name("email")]),
      input([type(.submit), value("Add team member")])
      ])
  ]
}
