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
  <| toMiddleware(fetchAccountData)
  >=> writeStatus(.ok)
  >=> respond(
    view: Views.accountView(accountData:allEpisodes:currentDate:),
    layoutData: { accountData in
      @Dependency(\.date.now) var now
      @Dependency(\.episodes) var episodes

      return SimplePageLayoutData(
        data: (accountData, episodes(), now),
        title: "Account"
      )
    }
  )

private func fetchAccountData<I>(
  _ conn: Conn<I, Tuple2<User, SubscriberState>>
) async -> Conn<I, AccountData> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  let (user, subscriberState) = lower(conn.data)

  async let emailSettings = database.fetchEmailSettingsForUserId(user.id)
  async let episodeCredits = database.fetchEpisodeCredits(user.id)
  async let subscription = database.fetchSubscription(user: user)
  async let teamInvites = database.fetchTeamInvites(user.id)
  async let teammates = database.fetchSubscriptionTeammatesByOwnerId(user.id)

  var paymentMethod: Either<any CardProtocol, PaymentMethod>?
  var stripeSubscription: Stripe.Subscription?
  var subscriptionOwner: User?
  var upcomingInvoice: Invoice?

  if let subscription = try? await subscription {
    async let owner = database.fetchUserById(subscription.userId)

    if let subscription = try? await stripe.fetchSubscription(subscription.stripeSubscriptionId) {
      async let invoice = subscription.isRenewing
      ? stripe.fetchUpcomingInvoice(subscription.customer.id)
      : nil

      if let customer = subscription.customer.right {
        if let paymentMethodID = customer.invoiceSettings.defaultPaymentMethod {
          paymentMethod = try? await .right(stripe.fetchPaymentMethod(paymentMethodID))
        } else {
          paymentMethod = customer.defaultCard.map { .left($0) }
        }
      }

      stripeSubscription = subscription
      upcomingInvoice = try? await invoice
    }

    subscriptionOwner = try? await owner
  }

  let accountData = AccountData(
    currentUser: user,
    emailSettings: (try? await emailSettings) ?? [],
    episodeCredits: (try? await episodeCredits) ?? [],
    paymentMethod: paymentMethod,
    stripeSubscription: stripeSubscription,
    subscriberState: subscriberState,
    subscription: try? await subscription,
    subscriptionOwner: subscriptionOwner,
    teamInvites: (try? await teamInvites) ?? [],
    teammates: (try? await teammates) ?? [],
    upcomingInvoice: upcomingInvoice
  )

  return conn.map { _ in accountData }
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
