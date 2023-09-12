import Dependencies
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
    @Dependency(\.database) var database
    @Dependency(\.siteRouter) var siteRouter

    return EitherIO { try await database.deleteTeamInvite(get1(conn.data).id) }
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
    @Dependency(\.database) var database
    @Dependency(\.fireAndForget) var fireAndForget
    @Dependency(\.siteRouter) var siteRouter
    @Dependency(\.stripe) var stripe

    let (teamInvite, currentUser) = lower(conn.data)

    return EitherIO {
      let inviter = try await database.fetchUserById(teamInvite.inviterUserId)
      let subscription = try await database.fetchSubscriptionByOwnerId(inviter.id)
      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      guard stripeSubscription.status.isActive else { throw unit }
      try await database.addUserIdToSubscriptionId(currentUser.id, subscription.id)

      await fireAndForget {
        _ = try await sendEmail(
          to: [inviter.email],
          subject:
            "\(currentUser.displayName) has accepted your Point-Free team invitation!",
          content: inj2(inviteeAcceptedEmailView((inviter, currentUser)))
        )
      }
      await fireAndForget {
        try await database.deleteTeamInvite(teamInvite.id)
      }
    }
    .run
    .flatMap { _ in
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
    @Dependency(\.database) var database
    @Dependency(\.stripe) var stripe

    let (email, inviter) = lower(conn.data)

    return EitherIO<_, TeamInvite> {
      async let invites = database.fetchTeamInvites(inviter.id).count
      async let teammates = database.fetchSubscriptionTeammatesByOwnerId(inviter.id).count

      async let subscription = database.fetchSubscriptionByOwnerId(inviter.id)

      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      let seatsTaken = try await invites + teammates

      guard stripeSubscription.status.isActive && stripeSubscription.quantity > seatsTaken
      else { throw unit }

      return try await database.insertTeamInvite(email, inviter.id)
    }
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
              """
            )
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
  @Dependency(\.database) var database

  return { conn in
    EitherIO { try await database.fetchTeamInvite(get1(conn.data)) }
      .run
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >=> respond(
              view: { _ in inviteNotFoundView() },
              layoutData: { data in
                SimplePageLayoutData(
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
  EitherIO {
    try await sendEmail(
      to: [invite.email],
      subject: "You’re invited to join \(inviter.displayName)’s team on Point-Free",
      content: inj2(teamInviteEmailView((inviter, invite)))
    )
  }
}

private func validateIsNot(currentUser: User) -> (User) -> EitherIO<Error, User> {
  return { user in
    user.id == currentUser.id
      ? lift(.left(unit))
      : lift(.right(user))
  }
}

private func redirectCurrentSubscribers<A, B>(
  _ middleware: @escaping M<T3<A, User?, B>>
) -> M<T3<A, User?, B>> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  return { conn in
    guard
      let user = get2(conn.data),
      let subscriptionId = user.subscriptionId
    else { return middleware(conn) }

    let hasActiveSubscription = EitherIO {
      let subscription = try await database.fetchSubscriptionById(subscriptionId)
      let stripeSubscription =
        try await stripe
        .fetchSubscription(subscription.stripeSubscriptionId)
      return stripeSubscription.isRenewing
    }
    .run
    .map { $0.right ?? false }

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
  @Dependency(\.database) var database

  return IO {
    guard let inviter = try? await database.fetchUserById(get1(data).inviterUserId)
    else { return nil }
    return get1(data) .*. inviter .*. data.second
  }
}
