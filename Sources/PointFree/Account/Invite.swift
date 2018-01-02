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
  redirectCurrentSubscribers
    <<< requireTeamInvite
    <<< filter(validateCurrentUserIsNotInviter, or: redirect(to: .account(.index)))
    <| writeStatus(.ok)
    >-> respond(showInviteView.contramap(lower))

let revokeInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.TeamInvite.Id, Database.User?>, Data> =
  requireTeamInvite
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filter(
      validateCurrentUserIsInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "You must be the invite owner to perform that action."))
    )
    <| { conn in
      AppEnvironment.current.database.deleteTeamInvite(get1(conn.data).id)
        .run
        .flatMap(const(conn |> redirect(to: path(to: .account(.index)))))
}

let resendInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.TeamInvite.Id, Database.User?>, Data> =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< requireTeamInvite
    <<< filter(
      validateCurrentUserIsInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "You must be the invite owner to perform that action."))
    )
    <| { conn in
      parallel(sendInviteEmail(invite: get1(conn.data), inviter: get2(conn.data)).run)
        .run({ _ in })
      return conn |> redirect(to: path(to: .account(.index)))
}

let acceptInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.TeamInvite.Id, Database.User?>, Data> =
  redirectCurrentSubscribers
    <<< requireTeamInvite
    <<< filter(
      validateCurrentUserIsNotInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.warning, "You cannot accept your own team invite."))
    )
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <| { conn in
      let (teamInvite, currentUser) = lower(conn.data)

      let inviter = AppEnvironment.current.database
        .fetchUserById(teamInvite.inviterUserId)
        .mapExcept(requireSome)

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
          AppEnvironment.current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
            .mapExcept(validateActiveStripeSubscription)
            .bimap(const(unit as Error), id)
            .flatMap { _ in
              AppEnvironment.current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
          }
      }

      // VERIFY: only do this if the invite was successfully taken
      let deleteInvite = parallel(
        subscription
          // TODO: should `const` be @autoclosure so that we can do:
          //       `.flatMap(const(AppEnvironment.current.database.deleteTeamInvite(teamInvite.id)))`
          //       ?
          .flatMap { _ in AppEnvironment.current.database.deleteTeamInvite(teamInvite.id) }
          .run
      )

      // fire-and-forget email of acceptance and deletion of invite
      zip(sendInviterEmailOfAcceptance, deleteInvite).run({ _ in })

      return subscription
        .run
        .flatMap(const(conn |> redirect(to: path(to: .account(.index)))))
}

let sendInviteMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filterMap(require1 >>> pure, or: redirect(to: .account(.index)))
    <<< filter(validateEmailDoesNotBelongToInviter, or: redirect(to: .account(.index)))
    <| { (conn: Conn<StatusLineOpen, Tuple2<EmailAddress, Database.User>>) in

      // TODO: need to validate that email isnt the same as the inviter
      // TODO: need to validate that email is unique

      let (email, inviter) = lower(conn.data)

      return AppEnvironment.current.database.insertTeamInvite(email, inviter.id)
        .run
        .flatMap { errorOrTeamInvite in
          switch errorOrTeamInvite {
          case .left:
            return conn |> redirect(to: .account(.index))

          case let .right(invite):
            parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
              .run({ _ in })

            return conn |> redirect(to: .account(.index))
          }
      }
}

private let showInviteView = View<(Database.TeamInvite, Database.User?)> { teamInvite, currentUser in

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

private func requireTeamInvite<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.TeamInvite, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.TeamInvite.Id, A>, Data> {

  return { conn in
    AppEnvironment.current.database.fetchTeamInvite(get1(conn.data))
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >-> respond(inviteNotFound)

        case let .right(teamInvite):
          return conn.map(over1(const(teamInvite)))
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

private func validateActiveStripeSubscription(
  _ errorOrSubscription: Either<Prelude.Unit, Stripe.Subscription>
  )
  -> Either<Prelude.Unit, Stripe.Subscription> {

    return errorOrSubscription.flatMap { stripeSubscription in
      stripeSubscription.status != .active ? .left(unit) : .right(stripeSubscription)
    }
}

private func redirectCurrentSubscribers<A, B>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<A, Database.User?, B>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T3<A, Database.User?, B>, Data> {

  return { conn in
    guard
      let user = get2(conn.data),
      let subscriptionId = user.subscriptionId
      else { return middleware(conn) }

    let hasActiveSubscription = AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
      .mapExcept(requireSome)
      .bimap(const(unit), id)
      .flatMap { AppEnvironment.current.stripe.fetchSubscription($0.stripeSubscriptionId) }
      .run
      .map { $0.right?.status == .some(.active) }

    return hasActiveSubscription.flatMap {
      $0
        ? (conn |> redirect(to: .account(.index), headersMiddleware: flash(.warning, "You already have an active subscription. If you want to accept this team invite you must cancel your current subscription.")))
        : middleware(conn)
    }
  }
}

private func validateCurrentUserIsNotInviter<A>(_ data: T3<Database.TeamInvite, Database.User?, A>) -> Bool {
  let (teamInvite, currentUser) = (get1(data), get2(data))
  return currentUser?.id.unwrap != .some(teamInvite.inviterUserId.unwrap)
}

private func validateCurrentUserIsInviter<A>(_ data: T3<Database.TeamInvite, Database.User, A>) -> Bool {
  let (teamInvite, currentUser) = (get1(data), get2(data))
  return currentUser.id.unwrap == teamInvite.inviterUserId.unwrap
}

private func validateEmailDoesNotBelongToInviter<A>(_ data: T3<EmailAddress, Database.User, A>) -> Bool {
  let (email, inviter) = (get1(data), get2(data))
  return email.unwrap.lowercased() != inviter.email.unwrap.lowercased()
}
