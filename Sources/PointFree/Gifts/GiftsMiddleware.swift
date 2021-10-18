import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple

public func giftsMiddleware(
  _ conn: Conn<StatusLineOpen, Tuple5<User?, Subscription?, SubscriberState, Route, Gifts>>
) -> IO<Conn<ResponseEnded, Data>> {

  let (user, subscription, subscriberState, route, gift) = lower(conn.data)

  switch gift {
  case let .create(formData):
    return conn.map(const(formData))
    |> giftCreateMiddleware
    >=> respondJson

  case .index:
    return conn.map(const(user .*. route .*. subscriberState .*. unit))
    |> giftsIndexMiddleware

  case let .plan(plan):
    return conn.map(const(plan .*. user .*. route .*. subscriberState .*. unit))
    |> giftPaymentMiddleware

  case let .redeem(giftId):
    return conn.map(const(giftId .*. user .*. subscription .*. subscriberState .*. unit))
    |> giftRedemptionMiddleware

  case let .redeemLanding(giftId):
    return conn.map(const(giftId .*. user .*. subscription .*. subscriberState .*. route .*. unit))
    |> giftRedemptionLandingMiddleware
  }
}
