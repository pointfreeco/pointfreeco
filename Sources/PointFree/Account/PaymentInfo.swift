import Css
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

let paymentInfoView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
  titleRowView.view(unit)
    <> updatePaymentInfoRowView.view(unit)
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Payment Info"])
        ])
      ])
    ])
}

private let updatePaymentInfoRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h2([`class`([Class.pf.type.title4])], ["Update"]),

        form(
          [action("#"), method(.post)],
          Stripe.html.cardInput
            <> Stripe.html.errors
            <> Stripe.html.scripts
            <> [

          ]
        )
      ])
    ])
  ])
}
