import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney
import Views

func giftRedemptionLandingMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  giftId: Gift.ID
) async -> Conn<ResponseEnded, Data> {
  switch await fetchGiftAndDiscount(giftId: giftId) {
  case .notFound:
    return routeNotFoundMiddleware(conn)
  case .alreadyRedeemed:
    return conn.redirect(to: .gifts()) {
      $0.flash(.error, "This gift was already redeemed.")
    }
  case .success(let gift, _):
    return
      conn
      .writeStatus(.ok)
      .respond(
        view: giftRedeemLanding(gift:episodeStats:),
        layoutData: {
          @Dependency(\.episodes) var episodes
          return SimplePageLayoutData(
            data: (gift, stats(forEpisodes: episodes())),
            extraStyles: extraGiftLandingStyles <> testimonialStyle,
            style: .base(.some(.minimal(.black))),
            title: "Redeem your Point-Free gift"
          )
        }
      )
  }
}

func giftRedemptionMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  giftId: Gift.ID
) async -> Conn<ResponseEnded, Data> {
  switch await fetchGiftAndDiscount(giftId: giftId) {
  case .notFound:
    return routeNotFoundMiddleware(conn)
  case .alreadyRedeemed:
    return conn.redirect(to: .gifts()) {
      $0.flash(.error, "This gift was already redeemed.")
    }
  case .success(let gift, let discount):
    return await redeemGift(conn, gift: gift, discount: discount)
  }
}

private func redeemGift(
  _ conn: Conn<StatusLineOpen, Void>,
  gift: Gift,
  discount: Cents<Int>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.subscription) var subscription

  guard let currentUser = currentUser
  else { return conn.loginAndRedirect() }

  if let subscription = subscription, subscription.stripeSubscriptionStatus.isActive {
    guard subscriberState.isOwner
    else {
      return conn.redirect(to: .gifts(.redeem(gift.id))) {
        $0.flash(
          .error,
          "You are already part of an active team subscription."
        )
      }
    }

    do {
      let stripeSubscription = try await stripe.fetchSubscription(subscription.stripeSubscriptionId)
      // TODO: Should we disallow gifts from applying to team subscriptions?
      // guard stripeSubscription.quantity == 1 else { throw unit }
      async let customer = stripe.updateCustomerBalance(
        stripeSubscription.customer.id,
        (stripeSubscription.customer.right?.balance ?? 0) - discount
      )
      async let updatedGift = database.updateGift(
        id: gift.id,
        subscriptionID: stripeSubscription.id
      )
      _ = try await (customer, updatedGift)
      return conn.redirect(to: .account()) {
        $0.flash(
          .notice,
          "The gift has been applied to your account as credit."
        )
      }
    } catch {
      reportIssue(error)
      return conn.redirect(to: .gifts(.redeem(gift.id))) {
        $0.flash(
          .error,
          """
          We were unable to redeem your gift. Please try again, or contact \
          <support@pointfree.co> for more help.
          """
        )
      }
    }
  } else {
    do {
      let customer = try await stripe.createCustomer(
        nil,
        currentUser.id.rawValue.uuidString,
        currentUser.email,
        nil,
        -discount
      )
      let stripeSubscription =
        try await stripe
        .createSubscription(
          customerID: customer.id,
          planID: gift.monthsFree < 12 ? .monthly : .yearly,
          quantity: 1,
          coupon: gift.coupon
        )
      _ =
        try await database.createSubscription(
          subscription: stripeSubscription,
          userID: currentUser.id,
          isOwnerTakingSeat: true,
          referrerID: nil
        )
      _ = try await database.updateGift(id: gift.id, subscriptionID: stripeSubscription.id)
      return conn.redirect(to: .account()) {
        $0.flash(.notice, "You now have access to Point-Free!")
      }
    } catch {
      reportIssue(error)
      return conn.redirect(to: .gifts(.redeem(gift.id))) {
        $0.flash(
          .error,
          """
          We were unable to redeem your gift. Please try again, or contact \
          <support@pointfree.co> for more help.
          """
        )
      }
    }
  }
}

private enum GiftLookup {
  case notFound
  case alreadyRedeemed
  case success(Gift, Cents<Int>)
}

private func fetchGiftAndDiscount(giftId: Gift.ID) async -> GiftLookup {
  @Dependency(\.database) var database
  @Dependency(\.stripe) var stripe

  do {
    let gift = try await database.fetchGift(id: giftId)
    let paymentIntent = try await stripe.fetchPaymentIntent(gift.stripePaymentIntentId)
    guard gift.stripeSubscriptionId == nil
    else { return .alreadyRedeemed }
    return .success(gift, paymentIntent.amount)
  } catch {
    return .notFound
  }
}
