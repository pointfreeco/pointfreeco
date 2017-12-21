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

let tmp: (Conn<StatusLineOpen, Tuple2<Database.User, Prelude.Unit>>)
  -> IO<Conn<StatusLineOpen, (Database.User, Stripe.Subscription?)>>
  = requireUser <<< fetchPaymentInfoData

let paymentInfoResponse =
//  requireUser
//    <| fetchPaymentInfoData
//    >->
    writeStatus(.ok)
    >-> respond(paymentInfoView)

func fetchPaymentInfoData<I, A>(
  _ conn: Conn<I, Tuple2<Database.User, A>>
  ) -> IO<Conn<I, (Database.User, Stripe.Subscription?)>> {

  let (user, _) = lower(conn.data)

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
    .map { conn.map(const((user, $0))) }
}

//let paymentInfoView = View<(Database.User, Stripe.Subscription?)> { currentUser, subscription in
let paymentInfoView = View<Prelude.Unit> { _ in
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
