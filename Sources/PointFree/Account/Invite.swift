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

let showInviteMiddleware =
  // TODO: need to validate that current user doesnt already have a subscription
  requireTeamInvite
    <| currentUserMiddleware
    >-> writeStatus(.ok)
    >-> respond(showInviteView.contramap(lower))

let revokeInviteMiddleware =
  requireTeamInvite
    <<< requireUser
    <| { conn in
      AppEnvironment.current.database.deleteTeamInvite(get2(conn.data).id)
        .run
        .flatMap(const(conn |> redirect(to: path(to: .team(.show)))))
}

let resendInviteMiddleware =
  requireTeamInvite
    <<< requireUser
    <| { conn in
      parallel(sendInviteEmail(invite: get2(conn.data), inviter: get1(conn.data)).run)
        .run({ _ in })
      return conn |> redirect(to: path(to: .team(.show)))
}

let acceptInviteMiddleware =
  requireTeamInvite
    <<< requireUser
    <| { conn in
      let (currentUser, teamInvite) = lower(conn.data)

      // VERIFY: need to validate that current user doesnt already have a subscription
      let invitee = pure(currentUser)
        .flatMap(validateDoesNotHaveSubscription)

      // VERIFY: need to validate that current user is not the inviter
      let inviter = AppEnvironment.current.database
        .fetchUserById(teamInvite.inviterUserId)
        .mapExcept(requireSome)
        .flatMap(validateIsNot(currentUser: currentUser))

      let sendInviterEmailOfAcceptance = parallel(
        inviter
          .run
          .flatMap { errorOrInviter in
            errorOrInviter.right.map { inviter in
              sendEmail(
                to: [inviter.email],
                subject: "\(currentUser.name) has accepted your Point-Free team invitation!",
                content: inj2(inviteeAcceptedEmailView.view((inviter: inviter, invitee: currentUser)))
                )
                .run
                .map(const(unit))
              }
              ?? pure(unit)
      })

      // VERIFY: user is subscribed
      let subscription = inviter
        .map(^\.subscriptionId)
        .mapExcept(requireSome)
        .flatMap { AppEnvironment.current.database.fetchSubscriptionById($0) }
        .mapExcept(requireSome)
        .flatMap { subscription in
          AppEnvironment.current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
      }

      // VERIFY: only do this if the invite was successfully taken
      let deleteInvite = parallel(
        subscription
          .flatMap { _ in AppEnvironment.current.database.deleteTeamInvite(teamInvite.id) }
          .run
      )

      // fire-and-forget email of acceptance and deletion of invite
      zip(sendInviterEmailOfAcceptance, deleteInvite).run({ _ in })

      return subscription
        .run
        .flatMap { _ in
          conn |> redirect(to: path(to: .account))
      }
}

let sendInviteMiddleware =
  requireUser
    <| { (conn: Conn<StatusLineOpen, Tuple2<Database.User, EmailAddress?>>) in

      // TODO: need to validate that email isnt the same as the inviter

      guard let email = get2 <| conn.data else { return conn |> redirect(to: path(to: .team(.show))) }
      let inviter = get1 <| conn.data

      return AppEnvironment.current.database.insertTeamInvite(email, inviter.id)
        .run
        .flatMap { errorOrTeamInvite in
          switch errorOrTeamInvite {
          case .left:
            return conn |> redirect(to: .team(.show))

          case let .right(invite):
            parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
              .run({ _ in })

            return conn |> redirect(to: .team(.show))
          }
      }
}

private let showInviteView = View<(Database.User?, Database.TeamInvite)> { currentUser, teamInvite in

  currentUser
    .map { showInviteLoggedInView.view(($0, teamInvite)) }
    ?? showInviteLoggedOutView.view(teamInvite)
}

private let showInviteLoggedOutView = View<Database.TeamInvite> { invite in
  [
    p(["You must be logged in to accept this invitation. Would you like to log in with GitHub?"]),

    a([href(url(to: .login(redirect: url(to: .invite(.show(invite.id))))))], ["Sign up with GitHub"]),
    ]
}

private let showInviteLoggedInView = View<(Database.User, Database.TeamInvite)> { currentUser, teamInvite in
  [
    p(["Do you accept this invite?"]),

    form([action(path(to: .invite(.accept(teamInvite.id)))), method(.post)], [
      input([type(.submit), value("Accept")])
      ])
  ]
}

private let inviteNotFound = View<Prelude.Unit> { _ in
  [
    p([
      "We couldn’t find that invite. Perhaps it was already taken, or it may have been revoked by the sender."
      ]),
    a([href(path(to: .secretHome))], ["Go home"])
  ]
}

private func requireTeamInvite(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.TeamInvite, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Database.TeamInvite.Id, Data> {

  return { conn in
    AppEnvironment.current.database.fetchTeamInvite(conn.data)
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >-> respond(inviteNotFound)

        case let .right(teamInvite):
          return conn.map(const(teamInvite))
            |> middleware
        }
    }
  }
}

private func sendInviteEmail(
  invite: Database.TeamInvite, inviter: Database.User
  ) ->  EitherIO<Prelude.Unit, SendEmailResponse> {

  return sendEmail(
    to: [invite.email],
    subject: "You’re invited to join \(inviter.name)’s team on Point-Free",
    content: inj2(teamInviteEmailView.view((inviter, invite)))
  )
}

private func validateIsNot(currentUser: Database.User) -> (Database.User) -> EitherIO<Error, Database.User> {
  return { user in
    user.id.unwrap.uuidString == currentUser.id.unwrap.uuidString
      ? lift(.left(unit))
      : lift(.right(user))
  }
}

private func validateDoesNotHaveSubscription(user: Database.User) -> EitherIO<Error, Database.User> {
  return user.subscriptionId != nil
    ? lift(.left(unit))
    : lift(.right(user))
}

