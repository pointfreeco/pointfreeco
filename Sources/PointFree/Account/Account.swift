import Dependencies
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
      @Dependency(\.date.now) var now
      @Dependency(\.episodes) var episodes

      return SimplePageLayoutData(
        data: (accountData, episodes(), now),
        extraStyles: markdownBlockStyles,
        title: "Account"
      )
    }
  )

private func fetchAccountData<I>(
  _ conn: Conn<I, Tuple2<User, SubscriberState>>
) -> IO<Conn<I, AccountData>> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  let (user, subscriberState) = lower(conn.data)

  let subscription = EitherIO {
    try await database.fetchSubscription(user: user)
  }

  let owner =
    subscription
    .flatMap { subscription in
      EitherIO { try await database.fetchUserById(subscription.userId) }
    }

  let stripeSubscription =
    subscription
    .map(\.stripeSubscriptionId)
    .flatMap { id in EitherIO { try await stripe.fetchSubscription(id) } }

  let upcomingInvoice =
    stripeSubscription
    .flatMap { stripeSubscription in
      EitherIO {
        guard stripeSubscription.isRenewing else { throw unit }
        return try await stripe.fetchUpcomingInvoice(stripeSubscription.customer.id)
      }
    }

  let paymentMethod: EitherIO<Error, Either<Card, PaymentMethod>?> =
    stripeSubscription
    .flatMap { subscription in
      EitherIO<Error, Either<Card, PaymentMethod>?> {
        guard let customer = subscription.customer.right else { return nil }
        if let card = customer.defaultSource?.right {
          return .left(card)
        } else if let paymentMethod = customer.invoiceSettings.defaultPaymentMethod {
          return try await .right(stripe.fetchPaymentMethod(paymentMethod))
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
      IO { (try? await database.fetchEmailSettingsForUserId(user.id)) ?? [] }
        .parallel,

      IO { (try? await database.fetchEpisodeCredits(user.id)) ?? [] }
        .parallel,

      paymentMethod.run.map { $0.right ?? nil }.parallel,

      stripeSubscription.run.map(\.right).parallel,

      subscription.run.map(\.right).parallel,

      owner.run.map(\.right).parallel,

      IO { (try? await database.fetchTeamInvites(user.id)) ?? [] }.parallel,

      IO { (try? await database.fetchSubscriptionTeammatesByOwnerId(user.id)) ?? [] }
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

func requireStripeSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return requireSubscriptionAndOwner
    <<< fetchStripeSubscription
    <<< filterMap(
      require1 >>> pure,
      or: redirect(
        to: .account(),
        headersMiddleware: flash(.error, genericSubscriptionError)
      )
    )
    <| middleware
}

private func requireSubscriptionAndOwner<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Models.Subscription, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{

  return fetchSubscription
    <<< filterMap(
      require1 >>> pure,
      or: redirect(
        to: .pricingLanding,
        headersMiddleware: flash(.error, "Doesn’t look like you’re subscribed yet!")
      )
    )
    <<< filter(
      isSubscriptionOwner,
      or: redirect(
        to: .account(),
        headersMiddleware: flash(.error, "Only subscription owners can make subscription changes.")
      )
    )
    <| middleware
}

func fetchSubscription<A>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T3<Models.Subscription?, User, A>, Data
  >
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
{
  @Dependency(\.database) var database

  return { conn in
    let subscription = IO {
      try? await database.fetchSubscriptionByOwnerId(get1(conn.data).id)
    }

    return subscription.flatMap { conn.map(const($0 .*. conn.data)) |> middleware }
  }
}

private func isSubscriptionOwner<A>(_ subscriptionAndUser: T3<Models.Subscription, User, A>)
  -> Bool
{

  return get1(subscriptionAndUser).userId == get2(subscriptionAndUser).id
}

private func fetchStripeSubscription<A>(
  _ middleware: (
    @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription?, A>, Data>
  )
)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Models.Subscription, A>, Data>
{
  @Dependency(\.stripe) var stripe

  return { conn in
    IO { try? await stripe.fetchSubscription(conn.data.first.stripeSubscriptionId) }
      .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
  }
}
