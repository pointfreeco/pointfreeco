import Css
import FunctionalCss
import Foundation
import Html
import Models
import Optics
import PointFreeRouter
import Prelude
import Stripe

public func invoicesView(
  subscription: Stripe.Subscription,
  invoicesEnvelope: Stripe.ListEnvelope<Stripe.Invoice>,
  currentUser: User
) -> Node {
  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView,
        invoicesRowView(invoicesEnvelope: invoicesEnvelope)
      )
    )
  )
}

private let titleRowView = Node.gridRow(
  attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
  .gridColumn(
    sizes: [.mobile: 12],
    .div(
      .h1(
        attributes: [.class([Class.pf.type.responsiveTitle2])],
        "Payment history"
      )
    )
  )
)

private func invoicesRowView(invoicesEnvelope: Stripe.ListEnvelope<Stripe.Invoice>) -> Node {
  return .div(
    .fragment(
      invoicesEnvelope.data.map { invoice in
        .gridRow(
          attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
          .gridColumn(
            sizes: [.mobile: 4],
            attributes: [.class([Class.type.fontFamily.monospace])],
            .div(.text("#" + invoice.number.rawValue))
          ),
          .gridColumn(
            sizes: [.mobile: 4],
            attributes: [.class([Class.type.align.end, Class.type.fontFamily.monospace])],
            .div(.text(dateFormatter.string(from: invoice.created)))
          ),
          .gridColumn(
            sizes: [.mobile: 2],
            attributes: [.class([Class.type.align.end, Class.type.fontFamily.monospace])],
            .div(.text(format(cents: invoice.total)))
          ),
          .gridColumn(
            sizes: [.mobile: 2],
            attributes: [.class([Class.grid.end(.mobile), Class.grid.end(.desktop)])],
            .div(
              .a(
                attributes: [
                  .class([Class.pf.components.button(color: .purple, size: .small)]),
                  .href(invoice.invoicePdf),
                  .target(.blank),
                ],
                "Print"
              )
            )
          )
        )
      }
    )
  )
}

private let dateFormatter = DateFormatter()
  |> \.dateStyle .~ .short
  |> \.timeStyle .~ .none
  |> \.timeZone .~ TimeZone(secondsFromGMT: 0)
