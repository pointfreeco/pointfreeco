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

let subscriptionChangeShowResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: subscriptionChangeShowView,
      layoutData: { subscription, currentUser, seatsTaken, subscriberState in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (subscription, currentUser, seatsTaken),
          extraStyles: extraStyles,
          title: "Modify subscription"
        )
    }
)

let subscriptionChangeMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(
      require2 >>> pure,
      or: redirect(
        to: .account(.subscription(.change(.show))),
        headersMiddleware: flash(
          .error,
          "Invalid subscription data. Please try again or contact <support@pointfree.co>."
        )
      )
    )
    <<< fetchSeatsTaken
    <<< requireStripeSubscription
    <<< requireActiveSubscription
    <<< requireValidSeating
    <| map(lower)
    >>> subscriptionChange

private func subscriptionChange(_ conn: Conn<StatusLineOpen, (Stripe.Subscription, Database.User, Int, Pricing)>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (currentSubscription, _, _, newPricing) = conn.data

    let newPrice = (defaultPricing(for: newPricing.lane, billing: newPricing.billing) * 100) * newPricing.quantity
    let currentPrice = currentSubscription.plan.amount.rawValue * currentSubscription.quantity

    let shouldProrate = newPrice > currentPrice
    let shouldInvoice = newPricing.plan == currentSubscription.plan.id
      && newPricing.quantity > currentSubscription.quantity
      || shouldProrate
      && newPricing.interval == currentSubscription.plan.interval

    return Current.stripe
      .updateSubscription(currentSubscription, newPricing.plan, newPricing.quantity, shouldProrate)
      .flatMap { sub -> EitherIO<Error, Stripe.Subscription> in
        if shouldInvoice {
          parallel(
            Current.stripe.invoiceCustomer(sub.customer.either(id, ^\.id))
              .withExcept(notifyError(subject: "Invoice Failed"))
              .run
            )
            .run(const(()))
        }

        return pure(sub)
      }
      .run
      .flatMap(
        either(
          const(
            conn |> redirect(
              to: .account(.subscription(.change(.show))),
              headersMiddleware: flash(
                .error,
                """
                We couldn’t modify your subscription at this time. Please try again or contact
                <support@pointfree.co>.
                """
              )
            )
          )
        ) { _ in
          // TODO: Send email?

          return conn |> redirect(
            to: .account(.index),
            headersMiddleware: flash(.notice, "We’ve modified your subscription.")
          )
        }
    )
}

func requireActiveSubscription<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription, A>, Data> {

    return filter(
      get1 >>> (^\.status == .active),
      or: redirect(
        to: .pricing(nil, expand: nil),
        headersMiddleware: flash(
          .error,
          "You don’t have an active subscription. Would you like to subscribe?"
        )
      )
      )
      <| middleware
}

private func requireValidSeating(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, Database.User, Int, Pricing>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Tuple4<Stripe.Subscription, Database.User, Int, Pricing>, Data> {

    return filter(
      seatsAvailable,
      or: redirect(
        to: .account(.index),
        headersMiddleware: flash(
          .error,
          "We can’t reduce the number of seats below the number that are active."
        )
      )
      )
      <| middleware
}

private func seatsAvailable(_ data: Tuple4<Stripe.Subscription, Database.User, Int, Pricing>) -> Bool {
  let (_, _, seatsTaken, pricing) = lower(data)

  return pricing.quantity >= seatsTaken
}

private let extraStyles =
  ((input & .pseudo(.checked) ~ .star) > .star) % (
    color(Colors.black)
      <> fontWeight(.bold)
    )
    <> extraSpinnerStyles

private func fetchSeatsTaken<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T3<Database.User, Int, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

    return { conn -> IO<Conn<ResponseEnded, Data>> in
      let user = conn.data.first

      let invitesAndTeammates = sequence([
        parallel(Current.database.fetchTeamInvites(user.id).run)
          .map { $0.right?.count ?? 0 },
        parallel(Current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run)
          .map { $0.right?.count ?? 0 }
        ])

      return invitesAndTeammates
        .sequential
        .flatMap { middleware(conn.map(const(user .*. $0.reduce(1, +) .*. conn.data.second))) }
    }
}

let subscriptionChangeShowView = View<(Stripe.Subscription, Database.User, Int)> { subscription, currentUser, seatsTaken -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        titleRowView.view(subscription)
          <> formRowView.view((subscription, seatsTaken))
          <> cancelRowView.view(subscription)
      )
      ])
    ])
}

private let titleRowView = View<Stripe.Subscription> { subscription in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.responsiveTitle2])], ["Modify subscription"]),
        p([
          "You are currently enrolled in the ", strong([text(subscription.plan.name)]), " plan. ",
          "Your subscription will ",
          subscription.isRenewing ? "renew" : "end",
          " on ",
          strong([text(dateFormatter.string(from: subscription.currentPeriodEnd))]),
          ".",
          subscription.isRenewing
            ? ""
            : " Reactivate your subscription by submitting the form below."
          ]),
        ])
      ])
    ])
}

private let formRowView = View<(Stripe.Subscription, Int)> { subscription, seatsTaken -> Node in

  return form(
    [action(path(to: .account(.subscription(.change(.update(nil)))))), method(.post), `class`([Class.margin([.mobile: [.bottom: 3]])])],
    changeSeatsRowView.view((subscription, seatsTaken))
      <> changeBillingIntervalRowView.view(subscription)
      <> [
        hr([`class`([Class.pf.components.divider])])
    ]
  )
}

private let changeSeatsRowView = View<(Stripe.Subscription, Int)> { subscription, seatsTaken -> Node in

  let pricing = PointFree.pricing(for: subscription)
  let subtitle = pricing.isIndividual
    ? "Change to a team subscription?"
    : "Add or remove seats?"
  let description: [Node] = pricing.isIndividual
    ? ["Specify the total number of seats you’d like."]
    : [
      "You are currently using ", strong([text(String(seatsTaken)), " of ",
      strong([text(String(subscription.quantity))]), " seats"]), " available."
  ]

  return gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      h3([`class`([Class.pf.type.responsiveTitle4])], [text(subtitle)]),
      p(description + [" ",
        """
        Additional costs will be billed immediately, prorated against the remaining time of
        the current billing period.
        """
        ]),
      input([
        type(.number),
        min(max(1, seatsTaken)),
        max(Pricing.validTeamQuantities.upperBound),
        name("quantity"),
        onchange(
          unsafeJavascript: """
          var multiplier = this.valueAsNumber;
          console.log(multiplier);
          var elements = document.getElementsByClassName('price');
          for (var idx = 0; idx < elements.length; idx++) {
            var element = elements[idx];
            var price = multiplier == 1
              ? element.dataset.priceIndividual
              : element.dataset.priceTeam;
            element.textContent = (multiplier * price)
              .toString()
              .replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');
          }
          """
        ),
        step(1),
        value(clamp(1..<Pricing.validTeamQuantities.upperBound) <| subscription.quantity),
        `class`([numberSpinner, Class.pf.colors.fg.black])
        ])
      ])
    ])
}

let priceClass = CssSelector.class("price")

private let changeBillingIntervalRowView = View<Stripe.Subscription> { subscription -> Node in

  let pricing = PointFree.pricing(for: subscription)
  let subtitle = pricing.billing == .monthly
    ? "Change to yearly billing?"
    : "Change to monthly billing?"

  return gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      h3([`class`([Class.pf.type.responsiveTitle4])], [text(subtitle)]),
      p([
        """
        Your regular billing rate will be reflected below. Upgrades and downgrades will take
        place at the end of the current billing period.
        """]),
      gridRow(
        [],
        individualPricingColumnView.view((.monthly, pricing))
          <> individualPricingColumnView.view((.yearly, pricing))
      ),
      button(
        [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
        [subscription.isRenewing ? "Update my subscription" : "Reactivate my subscription"]
      ),
      a(
        [
          href(path(to: .account(.index))),
          `class`([Class.pf.components.button(color: .black, style: .underline)])
        ],
        ["Never mind"]
      )
      ]
    )
    ])
}

private let individualPricingColumnView = View<(Pricing.Billing, Pricing)> { billing, pricing -> Node in
  return gridColumn(sizes: [.mobile: 16], [`class`([Class.pf.colors.bg.white])], [
    label([`for`(billing.rawValue), `class`([Class.display.block, Class.margin([.mobile: [.topBottom: 3]])])], [
      gridRow([style(flex(direction: .columnReverse))], [
        input([
          `class`([Class.h3]),
          checked(isChecked(billing, pricing)),
          id(billing.rawValue),
          name("billing"),
          type(.radio),
          value(billing.rawValue),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h2([`class`([Class.pf.type.responsiveTitle2, Class.type.light, Class.pf.colors.fg.gray650])], [
            "$",
            span(
              [
                `class`([priceClass]),
                data("price-individual", String(defaultPricing(for: .individual, billing: billing))),
                data("price-team", String(defaultPricing(for: .team, billing: billing)))
              ],
              [text(String(defaultPricing(for: pricing.lane, billing: billing) * pricing.quantity))]
            ),
            "/",
            text(pricingInterval(for: billing)),
            ]),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h6([`class`([Class.pf.type.responsiveTitle7, Class.pf.colors.fg.gray650, Class.display.inline])], [
            text(title(for: billing))
            ])
          ])
        ])
      ])
    ])
}

private func defaultPricing(for lane: Pricing.Lane, billing: Pricing.Billing) -> Int {
  switch (lane, billing) {
  case (.individual, .monthly):
    return 17
  case (.individual, .yearly):
    return 170
  case (.team, .monthly):
    return 16
  case (.team, .yearly):
    return 160
  }
}

private let cancelRowView = View<Stripe.Subscription> { subscription -> [Node] in

  guard subscription.isRenewing else { return [] }

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        h3([`class`([Class.pf.type.responsiveTitle4])], ["Cancel your subscription?"]),
        p([
          "If you cancel your subscription, you’ll lose access to Point-Free on ",
          strong([text(dateFormatter.string(from: subscription.currentPeriodEnd))]),
          """
           and you won’t be billed again. If you change your mind, you may reactivate your
          subscription at any time before this period ends.
          """
          ]),
        form([action(path(to: .account(.subscription(.cancel)))), method(.post)], [
          button(
            [`class`([Class.pf.components.button(color: .red), Class.margin([.mobile: [.top: 3]])])],
            ["Yes, cancel my subscription"]
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
  ]
}

private func pricing(for subscription: Stripe.Subscription) -> Pricing {
  return Pricing(billing: billing(for: subscription.plan), quantity: subscription.quantity)
}

private func billing(for plan: Stripe.Plan) -> Pricing.Billing {
  switch plan.interval {
  case .month:
    return .monthly
  case .year:
    return .yearly
  }
}
