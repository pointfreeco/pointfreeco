import ApplicativeRouter
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import PointFreePrelude
import Prelude
import Stripe
import Tuple

func renderAccount(conn: Conn<StatusLineOpen, Tuple4<Models.Subscription?, User?, SubscriberState, PointFreeRouter.Account>>)
  -> IO<Conn<ResponseEnded, Data>> {

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

    case let .paymentInfo(.show(expand)):
      return conn.map(const(user .*. (expand == .some(true) ? .full : .minimal) .*. subscriberState .*. unit))
        |> paymentInfoResponse

    case let .paymentInfo(.update(token)):
      return conn.map(const(user .*. token .*. unit))
        |> updatePaymentInfoMiddleware

    case let .rss(encryptedUserId, encryptedRssSalt):
      return conn.map(const(encryptedUserId .*. encryptedRssSalt .*. unit))
        |> accountRssMiddleware

    case .subscription(.cancel):
      return conn.map(const(user .*. unit))
        |> cancelMiddleware

    case .subscription(.change(.show)):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> subscriptionChangeShowResponse

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
