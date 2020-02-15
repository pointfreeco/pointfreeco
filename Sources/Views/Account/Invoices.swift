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
  func invoiceRow(_ invoice: Stripe.Invoice) -> Node {
    Node.gridRow(
      attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
      .gridColumn(
        sizes: [.mobile: 4],
        attributes: [.class([Class.type.fontFamily.monospace])],
        .div(.text("#" + (invoice.number?.rawValue ?? "")))
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
              .href(invoice.id.map { path(to: .account(.invoices(.show($0)))) } ?? "#"),
              .target(.blank),
            ],
            "Print"
          )
        )
      )
    )
  }

  return .div(
    .fragment(
      invoicesEnvelope.data.map(invoiceRow)
    )
  )
}

private func discountDescription(for discount: Stripe.Discount, invoice: Stripe.Invoice) -> String {
  return "\(format(cents: invoice.total - invoice.subtotal)) (\(discount.coupon.name ?? discount.coupon.id.rawValue))"
}

public func invoiceView(
  subscription: Stripe.Subscription,
  currentUser: User,
  invoice: Stripe.Invoice
) -> Node {
  let discountRow: Node = invoice.discount.map { discount in
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 1]])])],
      .gridColumn(
        sizes: [.mobile: 2, .desktop: 8],
        []
      ),
      .gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div("Discount")
      ),
      .gridColumn(
        sizes: [.mobile: 4, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div(.text(discountDescription(for: discount, invoice: invoice)))
      )
    )
    } ?? []

  let pfAddress = Node.gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div("Point-Free, Inc."),
      .div("139 Skillman #5C"),
      .div("Brooklyn, NY 11211")
    )
  )

  func section(_ pairs: [(Int, String, Int, String)]) -> Node {
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      .fragment(
        pairs.map { lcol, lstr, rcol, rstr in
          .gridRow(
            .gridColumn(
              sizes: [.mobile: 12, .desktop: lcol],
              attributes: [.class([Class.type.bold])],
              .div(.text(lstr))
            ),
            .gridColumn(
              sizes: [.mobile: 12, .desktop: rcol],
              attributes: [.class([Class.padding([.mobile: [.bottom: 1]])])],
              .div(.text(rstr))
            )
          )
        }
      )
    )
  }

  let billingHeader = Node.gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 3]])])],
    section([(2, "Bill to", 10, currentUser.displayName)]),
    section(
      [
        invoice.number.map { (6, "Invoice number", 6, $0.rawValue) },
        (6, "Billed on", 6, dateFormatter.string(from: invoice.created)),
        invoice.charge?.right?.source.left.map { (6, "Payment method", 6, $0.brand.rawValue + " ⋯ \($0.last4)") },
        subscription.customer.right?.businessVatId.map { (6, "VAT", 6, $0.rawValue) }
        ].compactMap { $0 }
    )
  )

  let invoiceColumnsHeader = Node.gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 2]]), Class.type.bold])],
    .gridColumn(
      sizes: [.mobile: 4, .desktop: 6],
      .div("Description")
    ),
    .gridColumn(
      sizes: [.mobile: 4, .desktop: 2],
      attributes: [.class([Class.type.align.end])],
      .div("Quantity")
    ),
    .gridColumn(
      sizes: [.mobile: 0, .desktop: 2],
      attributes: [.class([Class.type.align.end, Class.hide(.mobile)])],
      .div("Unit price")
    ),
    .gridColumn(
      sizes: [.mobile: 4, .desktop: 2],
      attributes: [.class([Class.type.align.end])],
      .div("Amount")
    )
  )

  let invoiceItems = Node.fragment(
    invoice.lines.data.map { item in
      .gridRow(
        attributes: [.class([Class.padding([.mobile: [.bottom: 1]])])],
        .gridColumn(
          sizes: [.mobile: 6, .desktop: 6],
          .div(.text(item.description ?? subscription.plan.nickname))
        ),
        .gridColumn(
          sizes: [.mobile: 2, .desktop: 2],
          attributes: [.class([Class.type.align.end])],
          .div(.text("\(item.quantity)"))
        ),
        .gridColumn(
          sizes: [.mobile: 0],
          attributes: [.class([Class.type.align.end, Class.hide(.mobile)])],
          .div(.text(format(cents: item.amount)))
        ),
        .gridColumn(
          sizes: [.mobile: 4, .desktop: 2],
          attributes: [.class([Class.type.align.end])],
          .div(.text(format(cents: item.amount)))
        )
      )
    }
  )

  let totals: Node = [
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 1]])])],
      .gridColumn(sizes: [.mobile: 2, .desktop: 8], []),
      .gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div("Subtotal")
      ),
      .gridColumn(
        sizes: [.mobile: 4, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div(.text(format(cents: invoice.subtotal)))
      )
    ),
    discountRow,
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.bottom: 1]])])],
      .gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
      .gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div("Total")
      ),
      .gridColumn(
        sizes: [.mobile: 4, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div(.text(format(cents: invoice.total)))
      )
    ),
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.bottom: 1]])])],
      .gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
      .gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div("Amount paid")
      ),
      .gridColumn(
        sizes: [.mobile: 4, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div(.text(format(cents: -invoice.amountPaid)))
      )
    ),
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 2]]), Class.type.bold])],
      .gridColumn(sizes: [.mobile: 2, .desktop: 8], [], []),
      .gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div("Amount due")
      ),
      .gridColumn(
        sizes: [.mobile: 4, .desktop: 2],
        attributes: [.class([Class.type.align.end])],
        .div(.text(format(cents: invoice.amountDue)))
      )
    )
  ]

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        pfAddress,
        billingHeader,
        invoiceColumnsHeader,
        invoiceItems,
        totals
      )
    )
  )
}

private func extraInvoiceInfo(subscription: Stripe.Subscription) -> Node {
  guard let extraInvoiceInfo = subscription.customer.right?.extraInvoiceInfo else { return [] }

  let extraInvoiceInfoNodes = Node.fragment(
    intersperse(.br)(
      extraInvoiceInfo
        .components(separatedBy: CharacterSet.newlines)
        .filter { !$0.isEmpty }
        .map(Node.text)
    )
  )

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [.class([Class.type.bold])],
      .div("User Info")
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [.class([Class.padding([.mobile: [.bottom: 1]])])],
      .div(extraInvoiceInfoNodes)
    )
  )
}

private let dateFormatter = DateFormatter()
  |> \.dateStyle .~ .short
  |> \.timeStyle .~ .none
  |> \.timeZone .~ TimeZone(secondsFromGMT: 0)
