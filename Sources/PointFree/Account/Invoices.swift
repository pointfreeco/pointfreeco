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
    >=> map(lower)
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
      or: redirect(to: .account(.invoices(.index)), headersMiddleware: flash(.error, invoiceError))
    )
    <<< filter(
      invoiceBelongsToCustomer,
      or: redirect(to: .account(.invoices(.index)), headersMiddleware: flash(.error, invoiceError))
    )
    <| writeStatus(.ok)
    >=> map(lower)
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

private func fetchInvoices<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Stripe.ListEnvelope<Stripe.Invoice>, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return { conn in
      let subscription = conn.data.first

      return Current.stripe.fetchInvoices(subscription.customer.either(id, ^\.id))
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
    .map(^\.right)
}

private let invoiceError = """
We had some trouble loading your invoice! Please try again later.
If the problem persists, please notify <support@pointfree.co>.
"""

private func invoiceBelongsToCustomer(_ data: Tuple3<Stripe.Subscription, Database.User, Stripe.Invoice>) -> Bool {
  return get1(data).customer.either(id, ^\.id) == get3(data).customer
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
        h1([`class`([Class.pf.type.responsiveTitle2])], ["Payment history"])
        ])
      ])
    ])
}

private let invoicesRowView = View<Stripe.ListEnvelope<Stripe.Invoice>> { invoicesEnvelope in
  div(
    invoicesEnvelope.data.map { invoice in
      gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
        gridColumn(sizes: [.mobile: 4], [`class`([Class.type.fontFamily.monospace])], [
          div([text("#" + invoice.number.rawValue)])
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
                href(path(to: .account(.invoices(.show(invoice.id))))),
                target(.blank),
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
    gridColumn(sizes: [.mobile: 12], [], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        [
          gridRow([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            gridColumn(sizes: [.mobile: 12], [], [
              div(["Point-Free, Inc."]),
              div(["139 Skillman #5C"]),
              div(["Brooklyn, NY 11211"]),
              ]),
            ]),
          gridRow([`class`([Class.padding([.mobile: [.topBottom: 3]])])], [
            gridColumn(sizes: [.mobile: 12, .desktop: 6], [], [
              gridRow([
                gridColumn(sizes: [.mobile: 12, .desktop: 2], [`class`([Class.type.bold])], [
                  div(["Bill to"]),
                  ]),
                gridColumn(sizes: [.mobile: 12, .desktop: 10], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
                  div([text(currentUser.displayName)])
                  ]),
                ]),
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 6], [], [
              gridRow([
                gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.type.bold])], [
                  div(["Invoice number"]),
                  ]),
                gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
                  div([text(invoice.number.rawValue)]),
                  ]),
                ]),
              gridRow([
                gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.type.bold])], [
                  div(["Billed on"]),
                  ]),
                gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
                  div([text(dateFormatter.string(from: invoice.date))]),
                  ]),
                ]),
              ]
              <> (
                invoice.charge?.right.map {
                  [
                    gridRow([
                      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.type.bold])], [
                        div(["Payment method"]),
                        ]),
                      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
                        div([text($0.source.brand.rawValue + " ⋯ \($0.source.last4)")]),
                        ]),
                      ])
                  ]
                  }
                  ?? []
              )
              <> (
                subscription.customer.right?.businessVatId.map {
                  [
                    gridRow([
                      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.type.bold])], [
                        div(["VAT"]),
                        ]),
                      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
                        div([text($0.rawValue)]),
                        ]),
                      ])
                  ]
                  }
                  ?? []
              )
              <> extraInvoiceInfo(subscription: subscription)
            ),
            ]),
          gridRow([`class`([Class.padding([.mobile: [.bottom: 2]]), Class.type.bold])], [
            gridColumn(sizes: [.mobile: 4, .desktop: 6], [], [
              div(["Description"]),
              ]),
            gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
              div(["Quantity"]),
              ]),
            gridColumn(sizes: [.mobile: 0, .desktop: 2], [`class`([Class.type.align.end, Class.hide(.mobile)])], [
              div(["Unit price"]),
              ]),
            gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
              div(["Amount"]),
              ]),
            ]),
          ]
          <> invoice.lines.data.map { item in
            gridRow([`class`([Class.padding([.mobile: [.bottom: 1]])])], [
              gridColumn(sizes: [.mobile: 6, .desktop: 6], [], [
                div([text(item.description ?? subscription.plan.name)])
                ]),
              gridColumn(sizes: [.mobile: 2, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text("\(item.quantity)")]),
                ]),
              gridColumn(sizes: [.mobile: 0], [`class`([Class.type.align.end, Class.hide(.mobile)])], [
                div([text(format(cents: item.amount))]),
                ]),
              gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text(format(cents: item.amount))]),
                ]),
              ])
          }
          <> [
            gridRow([`class`([Class.padding([.mobile: [.topBottom: 1]])])], [
              gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
              gridColumn(sizes: [.mobile: 6, .desktop: 2], [`class`([Class.type.align.end])], [
                div(["Subtotal"]),
                ]),
              gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text(format(cents: invoice.subtotal))]),
                ]),
              ]),
            gridRow([`class`([Class.padding([.mobile: [.bottom: 1]])])], [
              gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
              gridColumn(sizes: [.mobile: 6, .desktop: 2], [`class`([Class.type.align.end])], [
                div(["Total"]),
                ]),
              gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text(format(cents: invoice.total))]),
                ]),
              ]),
            gridRow([`class`([Class.padding([.mobile: [.bottom: 1]])])], [
              gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
              gridColumn(sizes: [.mobile: 6, .desktop: 2], [`class`([Class.type.align.end])], [
                div(["Amount paid"]),
                ]),
              gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text(format(cents: -invoice.amountPaid))]),
                ]),
              ]),
            gridRow([`class`([Class.padding([.mobile: [.topBottom: 2]]), Class.type.bold])], [
              gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
              gridColumn(sizes: [.mobile: 6, .desktop: 2], [`class`([Class.type.align.end])], [
                div(["Amount due"]),
                ]),
              gridColumn(sizes: [.mobile: 4, .desktop: 2], [`class`([Class.type.align.end])], [
                div([text(format(cents: invoice.amountDue))]),
                ]),
              ]),
        ]
      )
      ])
    ])
}

private func extraInvoiceInfo(subscription: Stripe.Subscription) -> [Node] {
  guard let extraInvoiceInfo = subscription.customer.right?.extraInvoiceInfo else { return [] }

  let extraInvoiceInfoNodes = intersperse(Html.br)
    <| extraInvoiceInfo
      .components(separatedBy: CharacterSet.newlines)
      .filter { !$0.isEmpty }
      .map(Html.text)

  return [
    gridRow([
      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.type.bold])], [
        div(["User Info"]),
        ]),
      gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.padding([.mobile: [.bottom: 1]])])], [
        div(
          extraInvoiceInfoNodes
        )
        ])
      ])
  ]
}
