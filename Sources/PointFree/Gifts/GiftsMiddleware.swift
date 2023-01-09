import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple

public func giftsMiddleware(
  _ conn: Conn<StatusLineOpen, Gifts>
) -> IO<Conn<ResponseEnded, Data>> {
  let giftRoute = conn.data

  switch giftRoute {
  case let .create(formData):
    return conn.map(const(formData))
      |> giftCreateMiddleware

  case .index:
    return conn.map(const(()))
      |> giftsIndexMiddleware

  case let .plan(plan):
    return conn.map(const(plan))
      |> giftPaymentMiddleware

  case let .redeem(giftId, .confirm):
    return conn.map(const(giftId))
      |> giftRedemptionMiddleware

  case let .redeem(giftId, .landing):
    return conn.map(const(giftId))
      |> giftRedemptionLandingMiddleware
  }
}
