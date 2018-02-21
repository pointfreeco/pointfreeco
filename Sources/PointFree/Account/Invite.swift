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
    <<< filter(
      validateCurrentUserIsNotInviter,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.warning, "You can’t view your own team invite!")
      )
    )
    <<< filterMap(fetchTeamInviter, or: redirect(to: .home))
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: showInviteView,
      layoutData: { teamInvite, inviter, currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (teamInvite, inviter, currentUser),
          title: "Accept Team Invite?"
        )
    }
)

private let genericInviteError = "You need to be the inviter to do that!"

let revokeInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.TeamInvite.Id, Database.User?>, Data> =
  requireTeamInvite
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filter(
      validateCurrentUserIsInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, genericInviteError))
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
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, genericInviteError))
    )
    <| { conn in
      let (invite, inviter) = lower(conn.data)

      parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
        .run({ _ in })
      return conn
        |> redirect(
          to: .account(.index),
          headersMiddleware: flash(.notice, "Invite sent to \(invite.email.unwrap).")
      )
}

let acceptInviteMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.TeamInvite.Id, Database.User?>, Data> =
  redirectCurrentSubscribers
    <<< requireTeamInvite
    <<< filter(
      validateCurrentUserIsNotInviter,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(.warning, "You can’t accept your own team invite!")
      )
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
                subject: "\(currentUser.name ?? currentUser.email.unwrap) has accepted your Point-Free team invitation!",
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

      let deleteInvite = parallel(
        subscription
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
    <<< filter(
      validateEmailDoesNotBelongToInviter,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "You can’t invite yourself :/"))
    )
    <| { (conn: Conn<StatusLineOpen, Tuple2<EmailAddress, Database.User>>) in

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

            return conn
              |> redirect(
                to: .account(.index),
                headersMiddleware: flash(.notice, "Invite sent to \(invite.email.unwrap).")
            )
          }
      }
}

let showInviteView = View<(Database.TeamInvite, Database.User, Database.User?)> { teamInvite, inviter, currentUser in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          currentUser
            .map { showInviteLoggedInView.view(($0, teamInvite, inviter)) }
            ?? showInviteLoggedOutView.view((teamInvite, inviter))
      )
      ])
    ])
}

private let showInviteLoggedOutView = View<(Database.TeamInvite, Database.User)> { invite, inviter in
  gridRow([`class`([Class.padding([.mobile: [.topBottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h3([`class`([Class.pf.type.title3])], ["You’ve been invited!"]),

        p([
          "Your colleague ",
          a([mailto(inviter.email.unwrap)], [.text(encode(inviter.name ?? inviter.email.unwrap))]),
          """
           has invited you to join their team on Point-Free, a video series exploring functional programming
          concepts using the Swift programming language. Accepting this invitation gives you access to all of
          the videos, transcripts, and code samples on this site.
          """
          ]),

        p([
          "You must be logged in to accept this invitation. Would you like to log in with GitHub?"
          ]),

        p([`class`([Class.padding([.mobile: [.top: 3]])])], [
          gitHubLink(text: "Login with GitHub", type: .black, redirectRoute: .invite(.show(invite.id)))
          ])
        ])
      ])
    ])
}

private let showInviteLoggedInView = View<(Database.User, Database.TeamInvite, Database.User)> { currentUser, teamInvite, inviter in
  gridRow([`class`([Class.padding([.mobile: [.topBottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h3([`class`([Class.pf.type.title3])], ["You’ve been invited!"]),

        p([
          "Your colleague ",
          a([mailto(inviter.email.unwrap)], [.text(encode(inviter.name ?? inviter.email.unwrap))]),
          """
           has invited you to join their team account on Point-Free, a video series exploring functional
          programming concepts using the Swift programming language. Accepting this invitation gives you
          access to all of the videos, transcripts, and code samples on this site.
          """
          ]),

        form([action(path(to: .invite(.accept(teamInvite.id)))), method(.post)], [
          input([
              type(.submit),
              value("Accept"),
              `class`([Class.pf.components.button(color: .purple)])
            ])
          ])
        ])
      ])
    ])
}

private let inviteNotFoundView = View<Prelude.Unit> { _ in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])], [
        h3([`class`([Class.pf.type.title3])], ["Invite not found"]),

        p([
          """
          Yikes! We couldn’t find that invite. Perhaps it was already taken, or it may have been revoked by
          the sender. To see subscription plans available, click the link below:
          """
          ]),

        p([`class`([Class.padding([.mobile: [.top: 3]])])], [
          a(
            [
              href(path(to: .pricing(nil, expand: nil))),
              `class`([Class.pf.components.button(color: .purple)])
            ],
            ["Subscribe"])
          ])
        ])
      ])
    ])
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
            >-> respond(
              view: inviteNotFoundView,
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

private func sendInviteEmail(
  invite: Database.TeamInvite, inviter: Database.User
  ) ->  EitherIO<Error, Mailgun.SendEmailResponse> {

  return sendEmail(
    to: [invite.email],
    subject: "You’re invited to join \(inviter.name ?? inviter.email.unwrap)’s team on Point-Free",
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
  _ errorOrSubscription: Either<Error, Stripe.Subscription>
  )
  -> Either<Error, Stripe.Subscription> {

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

private func fetchTeamInviter<A>(_ data: T2<Database.TeamInvite, A>) -> IO<T3<Database.TeamInvite, Database.User, A>?> {

  return AppEnvironment.current.database.fetchUserById(get1(data).inviterUserId)
    .mapExcept(requireSome)
    .run
    .map { $0.right.map { get1(data) .*. $0 .*. data.second } }
}
