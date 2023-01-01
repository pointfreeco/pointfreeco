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
    return IO { await accountRssMiddleware(conn.map { _ in salt }) }

  case let .rssLegacy(secret1, secret2):
    return IO { await accountRssMiddleware(conn.map { _ in "\(secret1)/\(secret2)" }) }

  case .subscription(.cancel):
    return IO { await cancelMiddleware(conn.map { _ in user }) }

  case .subscription(.change(.show)):
    return conn
      |> redirect(to: .account())

  case let .subscription(.change(.update(pricing))):
    return conn.map(const(user .*. pricing .*. unit))
      |> subscriptionChangeMiddleware

  case .subscription(.reactivate):
    return IO { await reactivateMiddleware(conn.map { _ in user }) }

  case let .update(data):
    return conn.map(const(user .*. data .*. unit))
      |> updateProfileMiddleware
  }
}
