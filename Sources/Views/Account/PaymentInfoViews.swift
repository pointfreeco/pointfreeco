import Css
import FunctionalCss
import Html
import PointFreeRouter
import Stripe
import Styleguide

public func paymentInfoView(
  paymentMethod: PaymentMethod?, publishableKey: String, stripeJsSrc: String
) -> Node {
  .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView,
        (paymentMethod?.card).map(currentPaymentInfoRowView(card:)) ?? [],
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

private func currentPaymentInfoRowView(card: PaymentMethod.Card) -> Node {
  .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Current Payment Info"),
        .p(.text("\(card.brand.description) ending in \(card.last4)")),
        .p(.text("Expires \(card.expMonth) / \(card.expYear)"))
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
            .action(siteRouter.path(for: .account(.paymentInfo(.update())))),
            .id(StripeHtml.formId),
            .method(.post),
          ],
          StripeHtml.cardInput(couponId: nil, publishableKey: publishableKey),
          StripeHtml.errors,
          StripeHtml.scripts(src: stripeJsSrc),
          .button(
            attributes: [
              .class([
                Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]]),
              ])
            ],
            "Update payment info"
          ),
          .a(
            attributes: [
              .href(siteRouter.path(for: .account())),
              .class([Class.pf.components.button(color: .black, style: .underline)]),
            ],
            "Cancel"
          )
        )
      )
    )
  )
}
