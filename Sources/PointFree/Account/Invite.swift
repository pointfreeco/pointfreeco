import Either
import EmailAddress
import Foundation
import HttpPipeline
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

let showInviteMiddleware =
  validateTeamInvite
  <| writeStatus(.ok)
  >=> map(lower)
  >>> respond(
    view: Views.showInviteView,
    layoutData: { teamInvite, inviter, currentUser in
      SimplePageLayoutData(
        currentUser: currentUser,
        data: (teamInvite, inviter, currentUser),
        title: "Accept Team Invite?"
      )
    }
  )

private let validateTeamInvite: MT<Tuple2<TeamInvite.ID, User?>, Tuple3<TeamInvite, User, User?>> =
  redirectCurrentSubscribers
  <<< requireTeamInvite
  <<< filterMap(fetchTeamInviter, or: redirect(to: .home))

private let genericInviteError = "You need to be the inviter to do that!"

let revokeInviteMiddleware: M<Tuple2<TeamInvite.ID, User?>> =
  requireTeamInvite
  <<< filterMap(require2 >>> pure, or: loginAndRedirect)
  <<< filter(
    validateCurrentUserIsInviter,
    or: redirect(to: .account(), headersMiddleware: flash(.error, genericInviteError))
  )
  <| { conn in
    EitherIO { try await Current.database.deleteTeamInvite(get1(conn.data).id) }
      .run
      .flatMap(
        const(
          conn
            |> redirect(
              to: siteRouter.path(for: .account()),
              headersMiddleware: flash(
                .notice,
                "Invite to \(get1(conn.data).email.rawValue) has been revoked."
              )
            )
        )
      )
  }

let resendInviteMiddleware: M<Tuple2<TeamInvite.ID, User?>> =
  filterMap(require2 >>> pure, or: loginAndRedirect)
  <<< requireTeamInvite
  <<< filter(
    validateCurrentUserIsInviter,
    or: redirect(to: .account(), headersMiddleware: flash(.error, genericInviteError))
  )
  <| { conn in
    let (invite, inviter) = lower(conn.data)

    parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
      .run({ _ in })
    return conn
      |> redirect(
        to: .account(),
        headersMiddleware: flash(.notice, "Invite sent to \(invite.email).")
      )
  }

let acceptInviteMiddleware: M<Tuple2<TeamInvite.ID, User?>> =
  redirectCurrentSubscribers
  <<< requireTeamInvite
  <<< filterMap(require2 >>> pure, or: loginAndRedirect)
  <| { conn in
    let (teamInvite, currentUser) = lower(conn.data)

    let inviter = Current.database
      .fetchUserById(teamInvite.inviterUserId)
      .mapExcept(requireSome)

    // VERIFY: user is subscribed
    let subscription =
      inviter
      .flatMap(
        \.id >>> {
          ownerId in
          EitherIO {
            try await requireSome(Current.database.fetchSubscriptionByOwnerId(ownerId))
          }
        }
      )
      .flatMap { subscription in
        Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
          .mapExcept(validateActiveStripeSubscription)
          .bimap(const(unit as Error), id)
          .flatMap { _ in
            EitherIO {
              try await Current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
            }
          }
      }

    return subscription
      .run
      .flatMap { _ in
        let sendInviterEmailOfAcceptance = parallel(
          inviter
            .run
            .flatMap { errorOrInviter in
              errorOrInviter.right.map { inviter in
                sendEmail(
                  to: [inviter.email],
                  subject:
                    "\(currentUser.displayName) has accepted your Point-Free team invitation!",
                  content: inj2(inviteeAcceptedEmailView((inviter, currentUser)))
                )
                .run
                .map(const(unit))
              }
                ?? pure(unit)
            })

        let deleteInvite = parallel(
          subscription
            .flatMap { _ in
              EitherIO { try await Current.database.deleteTeamInvite(teamInvite.id) }
            }
            .run
        )

        // fire-and-forget email of acceptance and deletion of invite
        zip2(sendInviterEmailOfAcceptance, deleteInvite).run({ _ in })

        return conn |> redirect(to: siteRouter.path(for: .account()))
      }
  }

let addTeammateViaInviteMiddleware =
  requireUserAndValidEmail
  <<< requireStripeSubscription
  <<< requireActiveSubscription
  <| { (conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription, User, EmailAddress>>) in

    let (stripeSubscription, inviter, email) = lower(conn.data)
    let newPricing = Pricing(
      billing: stripeSubscription.plan.interval == .month ? .monthly : .yearly,
      quantity: stripeSubscription.quantity + 1
    )

    return
      conn
      .map(const((stripeSubscription, newPricing)))
      |> changeSubscription(
        error: subscriptionModificationErrorMiddleware,
        success: map(const(email .*. inviter .*. unit)) >>> sendInviteMiddleware
      )
  }

private let requireUserAndValidEmail: MT<Tuple2<User?, EmailAddress?>, Tuple2<User, EmailAddress>> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
  <<< filterMap(require2 >>> pure, or: invalidSubscriptionErrorMiddleware)

let sendInviteMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
  <<< filterMap(require1 >>> pure, or: redirect(to: .account()))
  <| { (conn: Conn<StatusLineOpen, Tuple2<EmailAddress, User>>) in

    let (email, inviter) = lower(conn.data)

    let seatsTaken = zip2(
      Current.database.fetchTeamInvites(inviter.id).run.parallel
        .map { $0.right?.count ?? 0 },
      EitherIO {
        try await Current.database.fetchSubscriptionTeammatesByOwnerId(inviter.id)
      }
      .run
      .parallel
      .map { $0.right?.count ?? 0 }
    )
    .map(+)

    let subscription = EitherIO {
      try await requireSome(Current.database.fetchSubscriptionByOwnerId(inviter.id))
    }
    .flatMap { Current.stripe.fetchSubscription($0.stripeSubscriptionId) }
    .run
    .parallel

    let subscriptionHasAvailableSeats: EitherIO<Error, Void> = EitherIO(
      run: zip2(
        subscription,
        seatsTaken
      )
      .map { subscription, seatsTaken in subscription.map { ($0, seatsTaken) } }
      .sequential
    )
    .flatMap { $0.status.isActive && $0.quantity > $1 ? pure(()) : throwE(unit) }

    return
      subscriptionHasAvailableSeats
      .flatMap { Current.database.insertTeamInvite(email, inviter.id) }
      .run
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn
            |> redirect(
              to: .account(),
              headersMiddleware: flash(
                .error,
                """
                Couldn't invite \(email.rawValue)
                """)
            )

        case let .right(invite):
          parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
            .run({ _ in })

          return conn
            |> redirect(
              to: .account(),
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
      to: .account(),
      headersMiddleware: flash(
        .error,
        "Invalid subscription data. Please try again or contact <support@pointfree.co>."
      )
    )
}

private func requireTeamInvite<A>(
  _ middleware: @escaping M<T2<TeamInvite, A>>
) -> M<T2<TeamInvite.ID, A>> {

  return { conn in
    Current.database.fetchTeamInvite(get1(conn.data))
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >=> respond(
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
  -> Either<Error, Stripe.Subscription>
{

  return errorOrSubscription.flatMap { stripeSubscription in
    !stripeSubscription.status.isActive ? .left(unit) : .right(stripeSubscription)
  }
}

private func redirectCurrentSubscribers<A, B>(
  _ middleware: @escaping M<T3<A, User?, B>>
) -> M<T3<A, User?, B>> {

  return { conn in
    guard
      let user = get2(conn.data),
      let subscriptionId = user.subscriptionId
    else { return middleware(conn) }

    let hasActiveSubscription = EitherIO {
      try await requireSome(Current.database.fetchSubscriptionById(subscriptionId))
    }
    .flatMap { Current.stripe.fetchSubscription($0.stripeSubscriptionId) }
    .run
    .map { $0.right?.isRenewing ?? false }

    return hasActiveSubscription.flatMap {
      $0
        ? conn
          |> redirect(
            to: .account(),
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
