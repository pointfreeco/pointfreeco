import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple
import Views

let accountResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
  <| fetchAccountData
  >=> writeStatus(.ok)
  >=> respond(
    view: Views.accountView(accountData:allEpisodes:currentDate:),
    layoutData: { accountData in
      SimplePageLayoutData(
        currentSubscriberState: accountData.subscriberState,
        currentUser: accountData.currentUser,
        data: (accountData, Current.episodes(), Current.date()),
        extraStyles: markdownBlockStyles,
        title: "Account"
      )
    }
  )

private func fetchAccountData<I>(
  _ conn: Conn<I, Tuple2<User, SubscriberState>>
) -> IO<Conn<I, AccountData>> {

  let (user, subscriberState) = lower(conn.data)

  let subscription = EitherIO {
    try await Current.database.fetchSubscription(user: user)
  }

  let owner =
    subscription
    .flatMap { subscription in
      EitherIO { try await Current.database.fetchUserById(subscription.userId) }
    }

  let stripeSubscription =
    subscription
    .map(\.stripeSubscriptionId)
    .flatMap { id in EitherIO { try await Current.stripe.fetchSubscription(id) } }

  let upcomingInvoice =
    stripeSubscription
    .flatMap { $0.isRenewing ? pure($0) : throwE(unit) }
    .map(\.customer.id)
    .flatMap(Current.stripe.fetchUpcomingInvoice)

  let paymentMethod: EitherIO<Error, Either<Card, PaymentMethod>?> =
    stripeSubscription
    .flatMap { subscription in
      EitherIO<Error, Either<Card, PaymentMethod>?> {
        guard let customer = subscription.customer.right else { return nil }
        if let card = customer.defaultSource?.right {
          return .left(card)
        } else if let paymentMethod = customer.invoiceSettings.defaultPaymentMethod {
          return try await .right(Current.stripe.fetchPaymentMethod(paymentMethod))
        } else {
          return nil
        }
      }
    }

  let everything:
    Parallel<
      (
        [EmailSetting],
        [EpisodeCredit],
        Either<Card, PaymentMethod>?,
        Stripe.Subscription?,
        Models.Subscription?,
        User?,
        [TeamInvite],
        [User],
        Invoice?
      )
    > = zip9(
      IO { (try? await Current.database.fetchEmailSettingsForUserId(user.id)) ?? [] }
        .parallel,

      IO { (try? await Current.database.fetchEpisodeCredits(user.id)) ?? [] }
        .parallel,

      paymentMethod.run.map { $0.right ?? nil }.parallel,

      stripeSubscription.run.map(\.right).parallel,

      subscription.run.map(\.right).parallel,

      owner.run.map(\.right).parallel,

      IO { (try? await Current.database.fetchTeamInvites(user.id)) ?? [] }.parallel,

      IO { (try? await Current.database.fetchSubscriptionTeammatesByOwnerId(user.id)) ?? [] }
        .parallel,

      upcomingInvoice.run.map(\.right).parallel
    )

  return
    everything
    .map {
      conn.map(
        const(
          AccountData(
            currentUser: user,
            emailSettings: $0,
            episodeCredits: $1,
            paymentMethod: $2,
            stripeSubscription: $3,
            subscriberState: subscriberState,
            subscription: $4,
            subscriptionOwner: $5,
            teamInvites: $6,
            teammates: $7,
            upcomingInvoice: $8
          )
        )
      )
    }
    .sequential
}
