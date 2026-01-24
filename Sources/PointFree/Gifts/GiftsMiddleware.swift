import Foundation
import HttpPipeline
import Models
import PointFreeRouter

public func giftsMiddleware(
  _ conn: Conn<StatusLineOpen, Void>, route: Gifts
) async -> Conn<ResponseEnded, Data> {
  switch route {
  case let .create(formData):
    return await giftCreateMiddleware(conn, formData: formData)

  case .index:
    return giftsIndexMiddleware(conn)

  case let .plan(plan):
    return giftPaymentMiddleware(conn, plan: plan)

  case let .redeem(giftId, .confirm):
    return await giftRedemptionMiddleware(conn, giftId: giftId)

  case let .redeem(giftId, .landing):
    return await giftRedemptionLandingMiddleware(conn, giftId: giftId)
  }
}
