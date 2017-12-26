import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
@testable import Tuple

let confirmCancelResponse =
  requireUser
    <<< requireSubscription
    <<< requireSubscriptionOwner
    <<< requireStripeSubscription
    <| { conn in conn.map(const((conn.data.first, conn.data.second.first, conn.data.second.second))) }
    >-> writeStatus(.ok)
    >-> respond(confirmCancelView)

func requireStripeSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data> {

    return { conn in

      let (databaseSub, user, rest) = (conn.data.first, conn.data.second.first, conn.data.second.second)

      return AppEnvironment.current.stripe.fetchSubscription(databaseSub.stripeSubscriptionId)
        .run
        .map(^\.right)
        .flatMap { sub in

          guard let sub = sub else {
            return conn
              |> writeStatus(.notFound)
              >-> respond(text: "Stripe subscription not found :(")
          }

          return conn.map(const(.init(first: sub, second: .init(first: user, second: rest))))
            |> middleware
      }
    }
}

func requireSubscriptionOwner<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data> {

    return { conn in
      guard conn.data.first.userId == conn.data.second.first.id else {
        return conn
          |> writeStatus(.notFound)
          >-> respond(text: "Not the subscription owner :(")
      }

      return conn |> middleware
    }
}

func requireSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {
    return { conn in
      let (currentUser, rest) = (conn.data.first, conn.data.second)
      let subscription = currentUser.subscriptionId
        .map {
          AppEnvironment.current.database.fetchSubscriptionById($0)
            .mapExcept(requireSome)
            .run
            .map(^\.right)
        }
        ?? pure(nil)

      return subscription.flatMap { sub in
        guard let sub = sub else {
          return conn
            |> writeStatus(.notFound)
            >-> respond(text: "No subscription found :(")
        }
        return conn.map(const(.init(first: sub, second: .init(first: currentUser, second: rest))))
          |> middleware
      }
    }
}

let confirmCancelView = View<(Stripe.Subscription, Database.User, Prelude.Unit)> { subscription, currentUser, _ in
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
              gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
                div(
                  [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
                  titleRowView.view(unit)
                    <> [div(["really?"])]
                )
              ])
          ]
          <> footerView.view(unit)
      )
      ])
    ])
  ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Cancel Subscription?"])
        ])
      ])
    ])
}
