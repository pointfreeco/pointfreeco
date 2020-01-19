import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import PointFreePrelude
import Prelude
import Stripe
import Tuple
import Views

// MARK: Middleware

let invoicesResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< fetchInvoices
    <| writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
      view: Views.invoicesView(subscription:invoicesEnvelope:currentUser:),
      layoutData: { subscription, invoicesEnvelope, currentUser, subscriberState in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (subscription, invoicesEnvelope, currentUser),
          title: "Payment history"
        )
    }
)

private func fetchInvoices<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Stripe.ListEnvelope<Stripe.Invoice>, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return { conn in
      let subscription = conn.data.first

      return Current.stripe.fetchInvoices(subscription.customer.either(id, \.id))
        .withExcept(notifyError(subject: "Couldn't load invoices"))
        .run
        .flatMap {
          switch $0 {
          case let .right(invoices):
            return conn.map(const(subscription .*. invoices .*. conn.data.second))
              |> middleware
          case .left:
            return conn |> redirect(
              to: .account(.index),
              headersMiddleware: flash(
                .error,
                """
                We had some trouble loading your invoices! Please try again later.
                If the problem persists, please notify <support@pointfree.co>.
                """
              )
            )
          }
      }
    }
}
