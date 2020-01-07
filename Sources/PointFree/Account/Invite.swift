import Either
import Foundation
import HttpPipeline
import Mailgun
import Models
import Optics
import PointFreeRouter
import PointFreePrelude
import Prelude
import Stripe
import Tuple
import Views

let showInviteMiddleware =
  redirectCurrentSubscribers
    <<< requireTeamInvite
    <<< filterMap(fetchTeamInviter, or: redirect(to: .home))
    <| writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
      view: Views.showInviteView,
      layoutData: { teamInvite, inviter, currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (teamInvite, inviter, currentUser),
          title: "Accept Team Invite?"
        )
    }
)

private let genericInviteError = "You need to be the inviter to do that!"

let revokeInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<TeamInvite.Id, User?>, Data> =
  requireTeamInvite
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filter(
      validateCurrentUserIsInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, genericInviteError))
    )
    <| { conn in
      Current.database.deleteTeamInvite(get1(conn.data).id)
        .run
        .flatMap(
          const(
            conn
              |> redirect(
                to: path(to: .account(.index)),
                headersMiddleware: flash(
                  .notice,
                  "Invite to \(get1(conn.data).email.rawValue) has been revoked."
                )
            )
          )
      )
}

let resendInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<TeamInvite.Id, User?>, Data> =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< requireTeamInvite
    <<< filter(
      validateCurrentUserIsInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, genericInviteError))
    )
    <| { conn in
      let (invite, inviter) = lower(conn.data)

      parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
        .run({ _ in })
      return conn
        |> redirect(
          to: .account(.index),
          headersMiddleware: flash(.notice, "Invite sent to \(invite.email).")
      )
}

let acceptInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<TeamInvite.Id, User?>, Data> =
  redirectCurrentSubscribers
    <<< requireTeamInvite
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <| { conn in
      let (teamInvite, currentUser) = lower(conn.data)

      let inviter = Current.database
        .fetchUserById(teamInvite.inviterUserId)
        .mapExcept(requireSome)

      let sendInviterEmailOfAcceptance = parallel(
        inviter
          .run
          .flatMap { errorOrInviter in
            errorOrInviter.right.map { inviter in
              sendEmail(
                to: [inviter.email],
                subject: "\(currentUser.displayName) has accepted your Point-Free team invitation!",
                content: inj2(inviteeAcceptedEmailView((inviter, currentUser)))
                )
                .run
                .map(const(unit))
              }
              ?? pure(unit)
      })

      // VERIFY: user is subscribed
      let subscription = inviter
        .flatMap(^\.id >>> Current.database.fetchSubscriptionByOwnerId)
        .mapExcept(requireSome)
        .flatMap { subscription in
          Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
            .mapExcept(validateActiveStripeSubscription)
            .bimap(const(unit as Error), id)
            .flatMap { _ in
              Current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
          }
      }

      let deleteInvite = parallel(
        subscription
          .flatMap { _ in Current.database.deleteTeamInvite(teamInvite.id) }
          .run
      )

      // fire-and-forget email of acceptance and deletion of invite
      zip2(sendInviterEmailOfAcceptance, deleteInvite).run({ _ in })

      return subscription
        .run
        .flatMap(const(conn |> redirect(to: path(to: .account(.index)))))
}

let addTeammateViaInviteMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple2<User?, EmailAddress?>,
  Data
  > =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(require2 >>> pure, or: invalidSubscriptionErrorMiddleware)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <| { (conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription, User, EmailAddress>>) in

      let (stripeSubscription, inviter, email) = lower(conn.data)
      let newPricing = Pricing(
        billing: stripeSubscription.plan.interval == .month ? .monthly : .yearly,
        quantity: stripeSubscription.quantity + 1
      )

      return conn
        .map(const((stripeSubscription, newPricing)))
        |> changeSubscription(
          error: subscriptionModificationErrorMiddleware,
          success: map(const(email .*. inviter .*. unit)) >>> sendInviteMiddleware
      )
}

let sendInviteMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filterMap(require1 >>> pure, or: redirect(to: .account(.index)))
    <| { (conn: Conn<StatusLineOpen, Tuple2<EmailAddress, User>>) in

      let (email, inviter) = lower(conn.data)

      return Current.database.insertTeamInvite(email, inviter.id)
        .run
        .flatMap { errorOrTeamInvite in
          switch errorOrTeamInvite {
          case .left:
            return conn |> redirect(to: .account(.index))

          case let .right(invite):
            parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
              .run({ _ in })

            return conn
              |> redirect(
                to: .account(.index),
                headersMiddleware: flash(.notice, "Invite sent to \(invite.email).")
            )
          }
      }
}

func invalidSubscriptionErrorMiddleware<A>(
  _ conn: Conn<StatusLineOpen, A>
  ) -> IO<Conn<ResponseEnded, Data>> {

  return conn
    |> redirect(
      to: .account(.index),
      headersMiddleware: flash(
        .error,
        "Invalid subscription data. Please try again or contact <support@pointfree.co>."
      )
  )
}

private func requireTeamInvite<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<TeamInvite, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<TeamInvite.Id, A>, Data> {

  return { conn in
    Current.database.fetchTeamInvite(get1(conn.data))
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >=> _respond(
              view: { _ in inviteNotFoundView },
              layoutData: { data in
                SimplePageLayoutData(
                  currentUser: nil,
                  data: data,
                  title: "Invite not found"
                )
            }
          )

        case let .right(teamInvite):
          return conn.map(over1(const(teamInvite)))
            |> middleware
        }
    }
  }
}

func sendInviteEmail(
  invite: TeamInvite, inviter: User
  ) -> EitherIO<Error, SendEmailResponse> {

  return sendEmail(
    to: [invite.email],
    subject: "You’re invited to join \(inviter.displayName)’s team on Point-Free",
    content: inj2(teamInviteEmailView((inviter, invite)))
  )
}

private func validateIsNot(currentUser: User) -> (User) -> EitherIO<Error, User> {
  return { user in
    user.id == currentUser.id
      ? lift(.left(unit))
      : lift(.right(user))
  }
}

private func validateActiveStripeSubscription(
  _ errorOrSubscription: Either<Error, Stripe.Subscription>
  )
  -> Either<Error, Stripe.Subscription> {

    return errorOrSubscription.flatMap { stripeSubscription in
      stripeSubscription.status != .active ? .left(unit) : .right(stripeSubscription)
    }
}

private func redirectCurrentSubscribers<A, B>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<A, User?, B>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T3<A, User?, B>, Data> {

  return { conn in
    guard
      let user = get2(conn.data),
      let subscriptionId = user.subscriptionId
      else { return middleware(conn) }

    let hasActiveSubscription = Current.database.fetchSubscriptionById(subscriptionId)
      .mapExcept(requireSome)
      .bimap(const(unit), id)
      .flatMap { Current.stripe.fetchSubscription($0.stripeSubscriptionId) }
      .run
      .map { $0.right?.isRenewing ?? false }

    return hasActiveSubscription.flatMap {
      $0
        ? conn
          |> redirect(
            to: .account(.index),
            headersMiddleware: flash(
              .warning,
              """
              You already have an active subscription. If you want to accept this team invite you need to
              cancel your current subscription.
              """
            )
          )
        : middleware(conn)
    }
  }
}

private func validateCurrentUserIsInviter<A>(_ data: T3<TeamInvite, User, A>) -> Bool {
  let (teamInvite, currentUser) = (get1(data), get2(data))
  return currentUser.id == teamInvite.inviterUserId
}

private func validateEmailDoesNotBelongToInviter<A>(_ data: T3<EmailAddress, User, A>) -> Bool {
  let (email, inviter) = (get1(data), get2(data))
  return email.rawValue.lowercased() != inviter.email.rawValue.lowercased()
}

private func fetchTeamInviter<A>(_ data: T2<TeamInvite, A>) -> IO<T3<TeamInvite, User, A>?> {

  return Current.database.fetchUserById(get1(data).inviterUserId)
    .mapExcept(requireSome)
    .run
    .map { $0.right.map { get1(data) .*. $0 .*. data.second } }
}
