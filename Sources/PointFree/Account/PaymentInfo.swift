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
  filterMap(require1)
    <| fetchPaymentInfoData
    >-> writeStatus(.ok)
    >-> respond(paymentInfoView)

func fetchPaymentInfoData<I, A>(
  _ conn: Conn<I, Tuple2<Database.User, A>>
  ) -> IO<Conn<I, (Database.User, Stripe.Subscription?, A)>> {

  let (user, rest) = lower(conn.data)

  let subscription = user.subscriptionId
    .map {
      AppEnvironment.current.database.fetchSubscriptionById($0)
        .mapExcept(requireSome)
        .withExcept(const(unit))
        .flatMap { AppEnvironment.current.stripe.fetchSubscription($0.stripeSubscriptionId) }
        .run
        .map(^\.right)
    }
    ?? pure(nil)

  return subscription
    .map { conn.map(const((user, $0, rest))) }
}

let paymentInfoView = View<(Database.User, Stripe.Subscription?, Prelude.Unit)> { currentUser, subscription, _ in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(render(config: pretty, css: pricingExtraStyles)),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(
        darkNavView.view((currentUser, nil))
          <> [
            gridRow([
              gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))],  [
                div(
                  [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
                  titleRowView.view(unit)
                    <> updatePaymentInfoRowView.view(unit)
                )
              ])
            ])
          ]
          <> footerView.view(unit)
      )
    ])
  ])
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
