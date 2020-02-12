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

let invoiceResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< filterMap(
      over3(fetchInvoice) >>> sequence3 >>> map(require3),
      or: redirect(to: .account(.invoices(.index)), headersMiddleware: flash(.error, invoiceError))
    )
    <<< filter(
      invoiceBelongsToCustomer,
      or: redirect(to: .account(.invoices(.index)), headersMiddleware: flash(.error, invoiceError))
    )
    <| writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
      view: Views.invoiceView(subscription:currentUser:invoice:),
      layoutData: { subscription, currentUser, invoice in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (subscription, currentUser, invoice),
          style: .minimal,
          title: "Invoice"
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

private func fetchInvoice(id: Stripe.Invoice.Id) -> IO<Stripe.Invoice?> {
  return Current.stripe.fetchInvoice(id)
    .run
    .map(\.right)
}

private let invoiceError = """
We had some trouble loading your invoice! Please try again later.
If the problem persists, please notify <support@pointfree.co>.
"""

private func invoiceBelongsToCustomer(_ data: Tuple3<Stripe.Subscription, User, Stripe.Invoice>) -> Bool {
  return get1(data).customer.either(id, \.id) == get3(data).customer
}
