import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

// MARK: Middleware

let invoicesResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< fetchInvoices
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: invoicesView,
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
      or: redirect(
        to: .account(.invoices(.index)),
        headersMiddleware: flash(
          .error,
          """
          We had some trouble loading your invoice! Please try again later.
          If the problem persists, please notify <support@pointfree.co>.
          """
        )
      )
    )
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: invoiceView,
      layoutData: { subscription, currentUser, invoice in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (subscription, currentUser, invoice),
          style: .minimal,
          title: "Invoice"
        )
    }
)

private func fetchInvoice(id: Stripe.Invoice.Id) -> IO<Stripe.Invoice?> {
  return AppEnvironment.current.stripe.fetchInvoice(id)
    .run
    .map(^\.right)
}

private func fetchInvoices<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Stripe.ListEnvelope<Stripe.Invoice>, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return { conn in
      let subscription = conn.data.first

      return AppEnvironment.current.stripe.fetchInvoices(subscription.customer)
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

// MARK: Views

let invoicesView = View<(Stripe.Subscription, Stripe.ListEnvelope<Stripe.Invoice>, Database.User)> { subscription, invoicesEnvelope, currentUser -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          titleRowView.view(unit)
            <> invoicesRowView.view(invoicesEnvelope)
      )
      ])
    ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Payment history"])
        ])
      ])
    ])
}

private let invoicesRowView = View<Stripe.ListEnvelope<Stripe.Invoice>> { invoicesEnvelope in
  div(
    invoicesEnvelope.data.map { invoice in
      gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
        gridColumn(sizes: [.mobile: 4], [`class`([Class.type.fontFamily.monospace])], [
          div([text("#" + invoice.number.unwrap)])
          ]),
        gridColumn(sizes: [.mobile: 4], [`class`([Class.type.align.end, Class.type.fontFamily.monospace])], [
          div([text(dateFormatter.string(from: invoice.date))])
          ]),
        gridColumn(sizes: [.mobile: 2], [`class`([Class.type.align.end, Class.type.fontFamily.monospace])], [
          div([text(format(cents: invoice.total))])
          ]),
        gridColumn(sizes: [.mobile: 2], [`class`([Class.grid.end(.mobile), Class.grid.end(.desktop)])], [
          div([
            a(
              [
                `class`([Class.pf.components.button(color: .purple, size: .small)]),
                href(path(to: .account(.invoices(.show(invoice.id)))))
              ],
              ["Print"]
            )
            ])
          ]),
        ])
    }
  )
}

let invoiceView = View<(Stripe.Subscription, Database.User, Stripe.Invoice)> { subscription, currentUser, invoice -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        [
          "hi"
        ]
      )
      ])
    ])
}
