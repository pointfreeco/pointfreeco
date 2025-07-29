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
        title: "Account"
      )
    }
  )

private func fetchAccountData<I>(
  _ conn: Conn<I, Tuple2<User, SubscriberState>>
) -> IO<Conn<I, AccountData>> {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe
  @Dependency(\.fireAndForget) var fireAndForget

  let (user, subscriberState) = lower(conn.data)

  return IO { () -> AccountData in
    await fireAndForget {
      try await refreshStripeSubscription(for: user)
    }

    let subscription = try? await database.fetchSubscription(user: user)
    let stripeSubscription =
      if let stripeSubscriptionID = subscription?.stripeSubscriptionId {
        try? await stripe.fetchSubscription(id: stripeSubscriptionID)
      } else {
        Stripe.Subscription?.none
      }

    async let paymentMethod: Either<any CardProtocol, PaymentMethod>? = {
      if let card = stripeSubscription?.customer.right?.defaultCard {
        .left(card)
      } else if let defaultPaymentMethod = stripeSubscription?.customer.right?.invoiceSettings
        .defaultPaymentMethod
      {
        try? await .right(stripe.fetchPaymentMethod(id: defaultPaymentMethod))
      } else {
        nil
      }
    }()
    async let owner = {
      if let userID = subscription?.userId {
        try? await database.fetchUser(id: userID)
      } else {
        User?.none
      }
    }()
    async let upcomingInvoice = {
      if let customID = stripeSubscription?.customer.id {
        try? await stripe.fetchUpcomingInvoice(customerID: customID)
      } else {
        Invoice?.none
      }
    }()
    async let emailSettings = {
      (try? await database.fetchEmailSettings(userID: user.id)) ?? []
    }()
    async let episodeCredits = {
      (try? await database.fetchEpisodeCredits(userID: user.id)) ?? []
    }()
    async let teamInvites = {
      (try? await database.fetchTeamInvites(inviterID: user.id)) ?? []
    }()
    async let teammates = {
      (try? await database.fetchSubscriptionTeammates(ownerID: user.id)) ?? []
    }()

    return await AccountData(
      currentUser: user,
      emailSettings: emailSettings,
      episodeCredits: episodeCredits,
      paymentMethod: paymentMethod,
      stripeSubscription: stripeSubscription,
      subscriberState: subscriberState,
      subscription: subscription,
      subscriptionOwner: owner,
      teamInvites: teamInvites,
      teammates: teammates,
      upcomingInvoice: upcomingInvoice
    )
  }
  .map { conn.map(const($0)) }
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
      try? await database.fetchSubscription(ownerID: get1(conn.data).id)
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
    IO { try? await stripe.fetchSubscription(id: conn.data.first.stripeSubscriptionId) }
      .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
  }
}

func regenerateTeamInviteCode(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database

  guard
    let currentUser = currentUser,
    let subscriptionID = currentUser.subscriptionId,
    (try? await database.regenerateTeamInviteCode(subscriptionID: subscriptionID)) != nil
  else {
    return
      conn
      .redirect(to: .account()) {
        $0.flash(.error, "Something went wrong")
      }
  }

  return
    conn
    .redirect(to: .account()) {
      $0.flash(.notice, "A new team invite link has been generated.")
    }
}
