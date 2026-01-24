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
    return IO {
      await giftsIndexMiddleware(conn.map(const(())))
    }

  case let .plan(plan):
    return conn.map(const(plan))
      |> giftPaymentMiddleware

  case let .redeem(giftId, .confirm):
    return IO { await giftRedemptionMiddleware(conn.map { _ in }, giftId: giftId) }

  case let .redeem(giftId, .landing):
    return IO { await giftRedemptionLandingMiddleware(conn.map { _ in }, giftId: giftId) }
  }
}
