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
  requireUser
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
    ])
  ])
}
