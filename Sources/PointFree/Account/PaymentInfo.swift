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

let paymentInfoResponse =
  requireStripeSubscription
    <| writeStatus(.ok)
    >-> respond(
      paymentInfoView.contramap(lower),
      layout: simplePageLayout(title: "Update Payment Info", currentUser: get2)
)

let updatePaymentInfoMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, Stripe.Token.Id?>, Data> =
  filterMap(
    require2 >>> pure,
    or: redirect(to: .account(.paymentInfo(.show)), headersMiddleware: flash(.error, "An error occurred!"))
    )
    <<< requireStripeSubscription
    <| { conn in
      let (subscription, _, token) = lower(conn.data)

      return AppEnvironment.current.stripe.updateCustomer(subscription.customer, token)
        .run
        .flatMap {
          conn |> redirect(
            to: .account(.paymentInfo(.show)),
            headersMiddleware: $0.isLeft
              ? flash(.error, "There was an error updating your payment info!")
              : flash(.notice, "We’ve updated your payment info!")
          )
      }
}

let paymentInfoView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
  titleRowView.view(unit)
    <> (subscription.customer.sources.data.first.map(currentPaymentInfoRowView.view) ?? [])
    <> updatePaymentInfoRowView.view(unit)
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Payment Info"])
        ])
      ])
    ])
}

private let currentPaymentInfoRowView = View<Stripe.Card> { card in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h2([`class`([Class.pf.type.title4])], ["Current Payment Info"]),
        p([text(card.brand.rawValue + " ending in " + String(card.last4))]),
        p([text("Expires " + String(card.expMonth) + "/" + String(card.expYear))]),
        ])
      ])
    ])
}

private let updatePaymentInfoRowView = View<Prelude.Unit> { _ in
  return gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h2([`class`([Class.pf.type.title4])], ["Update"]),
        form(
          [action(path(to: .account(.paymentInfo(.update(nil))))), id(Stripe.html.formId), method(.post)],
          Stripe.html.cardInput
            <> Stripe.html.errors
            <> Stripe.html.scripts
            <> [
              button(
                [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
                ["Update payment info"]
              ),
              a(
                [
                  href(path(to: .account(.index))),
                  `class`([Class.pf.components.button(color: .black, style: .underline)])
                ],
                ["Cancel"]
              )
          ]
        )
      ])
    ])
  ])
}
