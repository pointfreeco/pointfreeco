import Css
import FunctionalCss
import Html
import PointFreeRouter
import Stripe
import Styleguide

public func paymentInfoView(card: Stripe.Card?, publishableKey: String, stripeJsSrc: String) -> Node {
  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView,
        card.map(currentPaymentInfoRowView(card:)) ?? [],
        updatePaymentInfoRowView(publishableKey: publishableKey, stripeJsSrc: stripeJsSrc)
      )
    )
  )
}

private let titleRowView = Node.gridRow(
  attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
  .gridColumn(
    sizes: [.mobile: 12],
    .div(
      .h1(attributes: [.class([Class.pf.type.responsiveTitle3])], "Payment Info")
    )
  )
)

private func currentPaymentInfoRowView(card: Stripe.Card) -> Node {
  return Node.gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
    Node.gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Current Payment Info"),
        .p(.text(card.brand.rawValue + " ending in " + String(card.last4))),
        .p(.text("Expires " + String(card.expMonth) + "/" + String(card.expYear)))
      )
    )
  )
}

private func updatePaymentInfoRowView(publishableKey: String, stripeJsSrc: String) -> Node {
  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Update"),
        .form(
          attributes: [
            .action(path(to: .account(.paymentInfo(.update(nil))))),
            .id(StripeHtml.formId),
            .method(.post)
          ],
          StripeHtml.cardInput(couponId: nil, publishableKey: publishableKey),
          StripeHtml.errors,
          StripeHtml.scripts(src: stripeJsSrc),
          .button(
            attributes: [.class([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
            "Update payment info"
          ),
          .a(
            attributes: [
              .href(path(to: .account(.index))),
              .class([Class.pf.components.button(color: .black, style: .underline)])
            ],
            "Cancel"
          )
        )
      )
    )
  )
}
