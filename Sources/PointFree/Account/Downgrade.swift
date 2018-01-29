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

// MARK: Middleware

let confirmDowngradeResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualYearlySubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: confirmDowngradeView,
      layoutData: { subscription, currentUser in
        SimplePageLayoutData(
          currentSubscriptionStatus: subscription.status,
          currentUser: currentUser,
          data: (subscription, currentUser),
          title: "Downgrade to monthly billing?"
        )
    }
)

let downgradeMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireIndividualYearlySubscription
    <| map(lower)
    >>> downgrade

// MARK: -

private func downgrade(_ conn: Conn<StatusLineOpen, (Stripe.Subscription, Database.User)>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, user) = conn.data
    return AppEnvironment.current.stripe.updateSubscription(subscription, .individualMonthly, 1)
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.downgrade(.show))),
              headersMiddleware: flash(
                .error,
                """
                We couldn’t change your subscription at this time. Please try again later or contact
                <support@pointfree.co>.
                """
              )
            )
          )
        ) { _ in
          parallel(sendDowngradeEmail(to: user, for: subscription).run)
            .run { _ in }

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "We’ll start billing you monthly!")
          )
        }
    )
}

// MARK: - Transformers

func requireActiveSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.status == .active),
      or: redirect(
        to: .pricing(nil),
        headersMiddleware: flash(
          .error,
          "You don’t have an active subscription. Would you like to subscribe?"
        )
      )
      )
      <| middleware
}

private func requireIndividualYearlySubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Stripe.Subscription, Database.User, A>, Data> {

    return filter(
      get1 >>> (^\.plan.id.unwrap == Stripe.Plan.Id.individualYearly.unwrap),
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(
          .error,
          """
          Your current subscription can’t be downgraded. For more information, please contact
          <support@pointfree.co>.
          """
        )
      )
      )
      <| middleware
}

// MARK: - Views

let confirmDowngradeView = View<(Stripe.Subscription, Database.User)> { subscription, currentUser in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView.view(unit)
          <> formRowView.view(subscription)
      )
      ])
    ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title3])], ["Downgrade your subscription?"])
        ])
      ])
    ])
}

private let formRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      p([
        "You are currently enrolled in the ", text(subscription.plan.name), " plan. If you downgrade your ",
        "subscription, you’ll begin to be billed monthly at the end of your current billing cycle: ",
        text(dateFormatter.string(from: subscription.currentPeriodEnd)),
        "."
        ]),
      form([action(path(to: .account(.subscription(.downgrade(.update))))), method(.post)], [
        button(
          [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
          ["Yes, bill me monthly"]
        ),
        a(
          [
            href(path(to: .account(.index))),
            `class`([Class.pf.components.button(color: .black, style: .underline)])
          ],
          ["Never mind"]
        )
        ])
      ])
    ])
}

// MARK: - Emails

private func sendDowngradeEmail(to owner: Database.User, for subscription: Stripe.Subscription)
  -> EitherIO<Prelude.Unit, Mailgun.SendEmailResponse> {

    return sendEmail(
      to: [owner.email],
      subject: "Point-Free Subscription Change",
      content: inj2(upgradeEmailView.view((owner, subscription)))
    )
}

let downgradeEmailView = simpleEmailLayout(downgradeEmailBodyView)
  .contramap { owner, subscription in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Point-Free Subscription Change",
      preheader: "You will automatically move to monthly billing on \(dateFormatter.string(from: subscription.currentPeriodEnd)).",
      data: (owner, subscription)
    )
}

private let downgradeEmailBodyView = View<(Database.User, Stripe.Subscription)> { user, subscription in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["Point-Free Monthly"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "We’ve downgraded your subscription to monthly billing. ",
            "This change will take effect at the end of the current billing cycle, on ",
            text(dateFormatter.string(from: subscription.currentPeriodEnd)),
            "."
            ])
          ])
        ])
      ])
    ])
}
