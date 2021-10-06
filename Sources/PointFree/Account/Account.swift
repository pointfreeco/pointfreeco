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

let accountResponse
  = filterMap(require1 >>> pure, or: loginAndRedirect)
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

  let userSubscription: EitherIO<Error, Models.Subscription> = user.subscriptionId
    .map(
      Current.database.fetchSubscriptionById
        >>> mapExcept(requireSome)
    )
    ?? throwE(unit)

  let ownerSubscription = Current.database.fetchSubscriptionByOwnerId(user.id)
    .mapExcept(requireSome)

  let subscription = userSubscription <|> ownerSubscription

  let owner = subscription
    .flatMap(Current.database.fetchUserById <<< ^\.userId)
    .mapExcept(requireSome)

  let stripeSubscription = subscription
    .map(^\.stripeSubscriptionId)
    .flatMap(Current.stripe.fetchSubscription)

  let upcomingInvoice = stripeSubscription
    .flatMap { $0.isRenewing ? pure($0) : throwE(unit) }
    .map(^\.customer >>> either(id, ^\.id))
    .flatMap(Current.stripe.fetchUpcomingInvoice)

  let everything = zip8(
    Current.database.fetchEmailSettingsForUserId(user.id).run.parallel
      .map { $0.right ?? [] },

    Current.database.fetchEpisodeCredits(user.id).run.parallel
      .map { $0.right ?? [] },

    stripeSubscription.run.map(^\.right).parallel,

    subscription.run.map(^\.right).parallel,

    owner.run.map(^\.right).parallel,

    Current.database.fetchTeamInvites(user.id).run.parallel
      .map { $0.right ?? [] },

    Current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run.parallel
      .map { $0.right ?? [] },

    upcomingInvoice.run.map(^\.right).parallel
  )

  return everything
    .map {
      conn.map(
        const(
          AccountData(
            currentUser: user,
            emailSettings: $0,
            episodeCredits: $1,
            stripeSubscription: $2,
            subscriberState: subscriberState,
            subscription: $3,
            subscriptionOwner: $4,
            teamInvites: $5,
            teammates: $6,
            upcomingInvoice: $7
          )
        )
      )
    }
    .sequential
}
