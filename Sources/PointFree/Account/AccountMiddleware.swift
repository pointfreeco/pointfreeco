import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Tuple

func accountMiddleware(
  conn: Conn<StatusLineOpen, Account>
)
  -> IO<Conn<ResponseEnded, Data>>
{
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  let account = conn.data

  switch account {
  case let .confirmEmailChange(payload):
    return conn.map(const(payload))
      |> confirmEmailChangeMiddleware

  case .index:
    return conn.map(const(currentUser .*. subscriberState .*. unit))
      |> accountResponse

  case .invoices(.index):
    return conn.map(const(currentUser .*. unit))
      |> invoicesResponse

  case let .invoices(.show(invoiceId)):
    return conn.map(const(currentUser .*. invoiceId .*. unit))
      |> invoiceResponse

  case .paymentInfo(.show):
    return conn.map(const(currentUser .*. subscriberState .*. unit))
      |> paymentInfoResponse

  case let .paymentInfo(.update(paymentMethodID)):
    return conn.map(const(currentUser .*. paymentMethodID .*. unit))
      |> updatePaymentInfoMiddleware

  case .regenerateTeamInviteCode:
    return IO { await regenerateTeamInviteCode(conn.map { _ in }) }

  case let .rss(salt):
    return IO { await accountRssMiddleware(conn.map { _ in salt }) }

  case let .rssLegacy(secret1, secret2):
    return IO { await accountRssMiddleware(conn.map { _ in "\(secret1)/\(secret2)" }) }

  case .subscription(.cancel):
    return IO { await cancelMiddleware(conn.map { _ in currentUser }) }

  case .subscription(.change(.show)):
    return IO { conn.redirect(to: .account()) }

  case let .subscription(.change(.update(pricing))):
    return conn.map(const(currentUser .*. pricing .*. unit))
      |> subscriptionChangeMiddleware

  case .subscription(.reactivate):
    return IO { await reactivateMiddleware(conn.map { _ in currentUser }) }

  case let .update(data):
    return conn.map(const(currentUser .*. data .*. unit))
      |> updateProfileMiddleware
  }
}
