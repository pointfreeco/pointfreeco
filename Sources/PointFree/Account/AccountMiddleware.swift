import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple

func accountMiddleware(
  conn: Conn<StatusLineOpen, Tuple4<Models.Subscription?, User?, SubscriberState, Account>>
)
  -> IO<Conn<ResponseEnded, Data>>
{

  let (_, user, subscriberState, account) = lower(conn.data)

  switch account {
  case let .confirmEmailChange(payload):
    return conn.map(const(payload))
      |> confirmEmailChangeMiddleware

  case .index:
    return conn.map(const(user .*. subscriberState .*. unit))
      |> accountResponse

  case .invoices(.index):
    return conn.map(const(user .*. subscriberState .*. unit))
      |> invoicesResponse

  case let .invoices(.show(invoiceId)):
    return conn.map(const(user .*. invoiceId .*. unit))
      |> invoiceResponse

  case .paymentInfo(.show):
    return conn.map(const(user .*. subscriberState .*. unit))
      |> paymentInfoResponse

  case let .paymentInfo(.update(paymentMethodID)):
    return conn.map(const(user .*. paymentMethodID .*. unit))
      |> updatePaymentInfoMiddleware

  case let .rss(salt):
    return conn.map(const(salt .*. unit))
      |> accountRssMiddleware

  case let .rssLegacy(secret1, secret2):
    return
      conn
      .map(const(User.RssSalt(rawValue: "\(secret1)/\(secret2)") .*. unit))
      |> accountRssMiddleware

  case .subscription(.cancel):
    return conn.map(const(user .*. unit))
      |> cancelMiddleware

  case .subscription(.change(.show)):
    return conn
      |> redirect(to: .account())

  case let .subscription(.change(.update(pricing))):
    return conn.map(const(user .*. pricing .*. unit))
      |> subscriptionChangeMiddleware

  case .subscription(.reactivate):
    return conn.map(const(user .*. unit))
      |> reactivateMiddleware

  case let .update(data):
    return conn.map(const(user .*. data .*. unit))
      |> updateProfileMiddleware
  }
}
