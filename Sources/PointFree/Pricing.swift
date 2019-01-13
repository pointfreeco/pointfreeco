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
import View

public struct Pricing: Equatable {
  var billing: Billing
  var quantity: Int

  public static let `default` = Pricing(billing: .monthly, quantity: 1)

  public static let validTeamQuantities = 2..<100

  public enum Billing: String, Codable {
    case monthly
    case yearly
  }

  enum Lane: String, Codable {
    case individual
    case team
  }

  private enum CodingKeys: String, CodingKey {
    case lane
    case billing
    case quantity
  }

  var interval: Stripe.Plan.Interval {
    switch self.billing {
    case .monthly:
      return .month
    case .yearly:
      return .year
    }
  }

  var isIndividual: Bool {
    return self.lane == .individual
  }

  var isTeam: Bool {
    return self.lane == .team
  }

  var lane: Lane {
    return self.quantity == 1
      ? .individual
      : .team
  }

  var plan: Stripe.Plan.Id {
    switch (self.billing, self.quantity) {
    case (.monthly, 1):
      return .individualMonthly
    case (.yearly, 1):
      return .individualYearly
    case (.monthly, _):
      return .teamMonthly
    case (.yearly, _):
      return .teamYearly
    }
  }
}

extension Pricing: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let lane = try container.decodeIfPresent(Lane.self, forKey: .lane)
    let billing = try container.decode(Billing.self, forKey: .billing)
    if lane == .some(.individual) {
      self.init(billing: billing, quantity: 1)
    } else {
      let quantity = try container.decode(Int.self, forKey: .quantity)
      self.init(billing: billing, quantity: quantity)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.lane, forKey: .lane)
    try container.encode(self.billing, forKey: .billing)
    try container.encode(self.quantity, forKey: .quantity)
  }
}

private let couponError = "That coupon code is invalid or has expired."

let discountResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple5<Database.User?, Pricing, PricingFormStyle, Stripe.Coupon.Id, Route?>, Data> =
  redirectActiveSubscribers(user: get1)
    <<< filterMap(
      over4(fetchCoupon) >>> sequence4 >>> map(require4),
      or: redirect(to: .pricing(nil, expand: nil), headersMiddleware: flash(.error, couponError))
    )
    <<< filter(
      get4 >>> ^\.valid,
      or: redirect(to: .pricing(nil, expand: nil), headersMiddleware: flash(.error, couponError))
    )
    <| map(over4(Optional.some)) >>> pure
    >=> basePricingResponse

let pricingResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple5<Database.User?, Pricing, PricingFormStyle, Stripe.Coupon.Id?, Route?>, Data> =
  redirectActiveSubscribers(user: get1)
    <| map(over4(const(Stripe.Coupon?.none))) >>> pure
    >=> basePricingResponse

let basePricingResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple5<Database.User?, Pricing, PricingFormStyle, Stripe.Coupon?, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: pricingView,
      layoutData: { currentUser, pricing, formStyle, coupon, route in
        SimplePageLayoutData(
          currentRoute: route,
          currentUser: currentUser,
          data: (currentUser, pricing, formStyle, coupon, route),
          description: pricingPageDescription(coupon: coupon),
          extraStyles: pricingExtraStyles <> whatToExpectStyles,
          style: .base(.minimal(.dark)),
          title: "Subscribe to Point-Free"
        )
    }
)

private func pricingPageDescription(coupon: Stripe.Coupon?) -> String {
  return coupon.map {
    """
Limited time Point-Free discount: Get \($0.formattedDescription). Subscribe today!
"""
  } ?? """
Subscribe to an individual or team membership on Point-Free, a video series exploring Swift \
and Functional Programming
"""
}

private func fetchCoupon(_ couponId: Stripe.Coupon.Id) -> IO<Stripe.Coupon?> {
  return Current.stripe.fetchCoupon(couponId)
    .run
    .map(^\.right)
}

private let pricingView =
  pricingOptionsView
    <> faqView.contramap(const(unit))

private let pricingOptionsRowClass =
  Class.pf.colors.bg.purple150
    | Class.grid.center(.mobile)
    | Class.padding([.mobile: [.topBottom: 3, .leftRight: 2], .desktop: [.topBottom: 4, .leftRight: 0]])

public enum PricingFormStyle {
  case minimal
  case full
}

let pricingOptionsView = View<(Database.User?, Pricing, PricingFormStyle, Stripe.Coupon?, Route?)> { currentUser, pricing, formStyle, coupon, route in

  gridRow([`class`([pricingOptionsRowClass])], [
    gridColumn(sizes: [.mobile: 12, .desktop: 7], [], [
      div([
        h2(
          [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle2])],
          [.raw("Subscribe to Point&#8209;Free")]
        ),

        p(
          [`class`([Class.pf.colors.fg.green])],
          [
            """
            Become a subscriber to unlock every full episode and explore new functional programming concepts
            as episodes are released.
            """
          ]
        ),

        gridRow([`class`([Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]])])], [
          gridColumn(sizes: [.mobile: 12], [], [
            form(
              [
                action(path(to: .subscribe(nil))),
                id(Stripe.html.formId),
                method(.post),
                onsubmit("event.preventDefault()")
              ],
              pricingTabsView.view(pricing)
                <> [div([`class`([Class.margin([.mobile: [.bottom: 3]])])], [])]
                <> quantityRowView.view(pricing)
                <> pricingIntervalRowView.view((pricing, coupon))
                <> pricingFooterView.view((currentUser, formStyle, coupon?.id, route))
            )
            ])
          ])
        ])
      ])
    ])
}

private let _whatToExpectBoxClass = CssSelector.class("what-to-expect")
private let whatToExpectBoxClass =
  _whatToExpectBoxClass
    | Class.type.align.start
    | Class.padding([.mobile: [.all: 2], .desktop: [.all: 3]])
    | Class.border.all
    | Class.border.rounded.all

private let whatToExpectStyles =
  _whatToExpectBoxClass % (
    backgroundColor(.rgba(0, 0, 0, 0.2))
)

private let whatToExpect = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle4])],
      [.raw("What to expect?")]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        """
        Quality video content dissecting some of the most important topics in functional programming. Each
        episode is transcribed for easy searching and reference, and comes with a fully-functioning Swift
        playground so that you can experiment with the concepts discussed.
        """
      ]
    )
  ]
}

private let topicsView = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 2]])])],
      [.raw("What kind of topics will you cover?")]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        """
        We will of course cover all of the classic topics such as functors, monads and applicatives (oh
        my!), but more broadly we will be focusing on some very general themes. Here’s just a small sample
        of some of the things we’re excited to talk about
        """
      ]
    ),

    ul(
      [`class`([Class.pf.colors.fg.green, Class.type.align.start])], [
        li(["Pure functions and side effects"]),
        li(["Code reuse through function composition"]),
        li(["Maximizing use of the type-system"]),
        li(["Turning programming problems into algebraic problems"]),
        ])
  ]
}

private let suggestATopic = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 2]])])],
      [.raw("Can I suggest a topic?")]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        "Sure thing! Send us an ",
        a(
          [mailto("support@pointfree.co"), style(faqLinkStyles)],
          ["email"]
        ),
        "."
      ]
    )
  ]
}

private let studentDiscounts = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 2]])])],
      [.text("Do you offer student discounts?")]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        "We do! If you ",
        a([mailto("support@pointfree.co?subject=Student%20Discount"), style(faqLinkStyles)], ["email us"]),
        " proof of your student status (e.g. scan of ID card) we will give you a 50% discount off of the",
        " individual plan."
      ]
    )
  ]
}

private let whoAreYou = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle4, Class.padding([.mobile: [.top: 2]])])],
      [.raw("Who are you?")]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        "We’re ",
        a([href("http://www.fewbutripe.com"), style(faqLinkStyles)], ["Brandon Williams"]),
        " and ",
        a([href("https://www.stephencelis.com"), style(faqLinkStyles)], ["Stephen Celis"]),
        ". We’ve been in the iOS and Swift communities for a long time, and have collectively given lots of ",
        "talks on various topics. Check out some of our talks here:"
      ]
    ),

    ul(
      [`class`([Class.pf.colors.fg.blue, Class.type.align.start])], [
        li([
          a([href("http://www.fewbutripe.com/talks/"), style(faqLinkStyles)],
            ["Brandon’s talks"])
          ]),

        li([
          a([href("https://www.stephencelis.com"), style(faqLinkStyles)],
            ["Stephen’s talks"])
          ])
      ])
  ]
}

private let faqView = View<Prelude.Unit> { _ in
  gridRow([`class`([pricingOptionsRowClass])], [
    gridColumn(sizes: [.mobile: 12, .desktop: 7], [], [
      div([`class`([whatToExpectBoxClass])],
          whatToExpect.view(unit)
            <> topicsView.view(unit)
            <> studentDiscounts.view(unit)
            <> suggestATopic.view(unit)
            <> whoAreYou.view(unit)
      )
      ])
    ])
}

private let faqLinkStyles =
  color(Colors.blue)
    <> key("text-decoration", "underline")

private let pricingTabsView = View<Pricing> { pricing in
  [
    input([
      checked(pricing.isIndividual),
      `class`([Class.display.none]),
      id(selectors.input.0),
      name("pricing[lane]"),
      type(.radio),
      value("individual"),
      role(.button)
      ]),
    label([`for`(selectors.input.0), `class`([Class.pf.components.pricingTab]), style(extraTabStyles)], [
      "For you"
      ]),

    span([`class`([Class.padding([.mobile: [.leftRight: 2]]), Class.pf.colors.fg.gray850])], ["or"]),

    input([
      checked(pricing.isTeam),
      `class`([Class.display.none]),
      id(selectors.input.1),
      name("pricing[lane]"),
      type(.radio),
      value("team"),
      role(.button)
      ]),
    label([`for`(selectors.input.1), `class`([Class.pf.components.pricingTab]), style(extraTabStyles)], [
      "For your team"
      ])
  ]
}

private let pricingIntervalRowView = View<(Pricing, Stripe.Coupon?)> { pricing, coupon in
  gridRow(
    [`class`([Class.pf.colors.bg.white])],
    individualPricingColumnView.view((.monthly, pricing, coupon))
      <> individualPricingColumnView.view((.yearly, pricing, coupon))
      <> [
        gridColumn(
          sizes: [.mobile: 12], [`class`([Class.pf.colors.bg.white])],
          (
            coupon
              .map {
                [
                  p([
                    `class`([
                      selectors.content.0,
                      Class.padding([.mobile: [.bottom: 1]]),
                      Class.pf.colors.fg.gray400,
                      Class.pf.type.body.small,
                      Class.size.width100pct,
                      Class.type.align.center,
                      Class.type.normal,
                      ])
                    ],
                    [.text("You get \($0.formattedDescription) for using the \($0.name ?? $0.id.rawValue) coupon.")])
                ]
              }
              ?? []
            )
            <> [
              p([
                `class`([
                  selectors.content.1,
                  Class.padding([.mobile: [.bottom: 1]]),
                  Class.pf.colors.fg.gray400,
                  Class.pf.type.body.small,
                  Class.size.width100pct,
                  Class.type.align.center,
                  Class.type.normal,
                  ])
                ],
                ["20% off the Individual Monthly plan"]
              )
          ])
    ])
}

func isChecked(_ billing: Pricing.Billing, _ pricing: Pricing) -> Bool {
  return billing == pricing.billing
}

let teamPriceClass = CssSelector.class("team-price")

private let individualPricingColumnView = View<(Pricing.Billing, Pricing, Stripe.Coupon?)> { billing, pricing, coupon -> Node in
  return gridColumn(sizes: [.mobile: 6], [`class`([Class.pf.colors.bg.white])], [
    label([`for`(billing.rawValue), `class`([Class.display.block, Class.margin([.mobile: [.all: 3]])])], [
      gridRow([style(flex(direction: .columnReverse))], [
        input([
          checked(isChecked(billing, pricing)),
          id(billing.rawValue),
          name("pricing[billing]"),
          type(.radio),
          value(billing.rawValue),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h2([`class`([Class.pf.type.responsiveTitle2, Class.type.light, Class.pf.colors.fg.gray650])], [
            span([`class`([selectors.content.0])], [
              .text(individualPricingText(for: billing, coupon: coupon)),
              ]),
            span([`class`([selectors.content.1])], [
              "$",
              span(
                [`class`([teamPriceClass]), data("price", String(defaultTeamPricing(for: billing)))],
                [.text(String(defaultTeamPricing(for: billing) * clamp(Pricing.validTeamQuantities)(pricing.quantity)))]
              ),
              "/",
              .text(pricingInterval(for: billing)),
              ]),
            ]),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h6([`class`([Class.pf.type.responsiveTitle7, Class.pf.colors.fg.gray650, Class.display.inline])], [
            .text(title(for: billing))
            ]),
          ]),
        ]),
      ])
    ])
}

private let quantityRowView = View<Pricing> { pricing -> Node in

  let quantity = clamp(Pricing.validTeamQuantities) <| pricing.quantity

  return div([`class`([Class.flex.flex])], [
    gridRow([`class`([selectors.content.1, Class.pf.colors.bg.white, Class.size.width100pct])], [
      gridColumn(sizes: [.mobile: 12], [], [
        div([`class`([Class.padding([.mobile: [.top: 3, .left: 3, .right: 3]])])], [

          p([`class`([Class.pf.colors.fg.black, Class.pf.type.body.regular])], ["How many in your team?"]),

          input([
            `class`([numberSpinner, Class.pf.colors.fg.black]),
            max(Pricing.validTeamQuantities.upperBound),
            min(Pricing.validTeamQuantities.lowerBound),
            name("pricing[quantity]"),
            .init(
              "onblur",
              """
              javascript:
              this.value = Math.min(Math.max(+this.value, +this.min), +this.max);
              var multiplier = +this.value;
              var elements = document.getElementsByClassName('team-price');
              for (var idx = 0; idx < elements.length; idx++) {
                var element = elements[idx];
                element.textContent = (multiplier * element.dataset.price)
                  .toString()
                  .replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');
              }
              """
            ),
            .init(
              "oninput",
              """
              javascript:
              var value = +this.value;
              var multiplier = Math.min(Math.max(value, 0), +this.max);
              var elements = document.getElementsByClassName('team-price');
              if (this.value != "" && value != multiplier) {
                this.value = multiplier;
              }
              for (var idx = 0; idx < elements.length; idx++) {
                var element = elements[idx];
                element.textContent = (multiplier * element.dataset.price)
                  .toString()
                  .replace(/\\B(?=(\\d{3})+(?!\\d))/g, ',');
              }
              """
            ),
            step(1),
            type(.number),
            value(quantity),
            ]),

          hr([
            `class`([
              Class.pf.components.divider,
              Class.margin([.mobile: [.top: 3]])
              ]),
            ]),
          ])
        ])
      ])
    ])
}

// TODO: move to point free base styles
private let numberSpinnerClass = CssSelector.class("num-spinner")
let numberSpinner =
  numberSpinnerClass
    | Class.type.align.center
    | Class.pf.type.responsiveTitle1
let extraSpinnerStyles =
  numberSpinnerClass % (
    padding(left: .px(20))
      <> maxWidth(.px(160))
      <> key("border", "0")
      <> borderStyle(top: .none, right: .none, bottom: .solid, left: .none)
      <> borderColor(top: .none, right: .none, bottom: Colors.gray650, left: .none)
      <> borderWidth(top: .none, right: .none, bottom: .px(1), left: .none)
    )
    <> (input & .elem(.other("::-webkit-inner-spin-button"))) % opacity(1)
    <> (input & .elem(.other("::-webkit-outer-spin-button"))) % opacity(1)

private let pricingFooterView = View<(Database.User?, PricingFormStyle, Stripe.Coupon.Id?, Route?)> { currentUser, formStyle, couponId, route in
  gridRow([`class`([Class.pf.colors.bg.white])], [
    gridColumn(sizes: [.mobile: 12], [], [
      div(
        [`class`([Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
        currentUser
          .map(const(stripeForm.view((couponId, formStyle))))
          ?? (
            loggedOutStripeForm.view(couponId)
              <> [
                gitHubLink(
                  text: "Sign in with GitHub",
                  type: .black,
                  redirectRoute: route ?? .pricing(nil, expand: false)
                )
            ])
      )
      ])
    ])
}

private let stripeForm = View<(Stripe.Coupon.Id?, PricingFormStyle)> { couponId, formStyle in
  div(
    [`class`([Class.padding([.mobile: [.left: 3, .right: 3]])])],
    Stripe.html.cardInput(couponId: couponId, formStyle: formStyle)
      <> Stripe.html.errors
      <> Stripe.html.scripts
      <> [
        button(
          [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
          ["Subscribe to Point", .raw("&#8209;"), "Free"]
        )
    ]
  )
}

private let loggedOutStripeForm = View<Stripe.Coupon.Id?> { couponId -> [Node] in
  guard let couponId = couponId else { return [] }
  return [
    div(
      [`class`([Class.padding([.mobile: [.left: 3, .right: 3, .bottom: 2]])])],
      [
        div([
          input([
            `class`([blockInputClass]),
            disabled(true),
            name("coupon"),
            placeholder("Coupon Code"),
            type(.text),
            value(couponId.rawValue)
            ]),
          ]),
        ]
    )
  ]
}

func title(for type: Pricing.Billing) -> String {
  switch type {
  case .monthly:
    return "Monthly Plan"
  case .yearly:
    return "Yearly Plan"
  }
}

private func individualTeamPricing(for type: Pricing.Billing, coupon: Stripe.Coupon?) -> Double {
  let rate = 1 - (Double(coupon?.rate.percentOff ?? 0) / 100)

  switch type {
  case .monthly:
    return 17 * rate
  case .yearly:
    return 170 * rate
  }
}

func individualPricingText(for type: Pricing.Billing, coupon: Stripe.Coupon?) -> String {
  let value = Double(Int(individualTeamPricing(for: type, coupon: coupon) * 100)) / 100

  let formatted = value.truncatingRemainder(dividingBy: 1) == 0
    ? "$\(Int(value))"
    : (currencyFormatter.string(from: NSNumber(value: value)) ?? "$\(value)")

  return formatted + "/" + pricingInterval(for: type)
}

private func defaultTeamPricing(for type: Pricing.Billing) -> Int {
  switch type {
  case .monthly:
    return 16
  case .yearly:
    return 160
  }
}

func pricingInterval(for type: Pricing.Billing) -> String {
  switch type {
  case .monthly:
    return "mo"
  case .yearly:
    return "yr"
  }
}

let pricingExtraStyles: Stylesheet =
  ((".block" ** input & .pseudo(.checked) ~ .star) > .star) % color(Colors.purple)
    <> input % color(Colors.gray650)
    <> input % margin(leftRight: .auto)
    <> tabStyles(selectors: [(selectors.input.0, selectors.content.0), (selectors.input.1, selectors.content.1)])
    <> extraSpinnerStyles

private let selectors = (
  input: (
    CssSelector.id("tab0"),
    CssSelector.id("tab1")
  ),
  content: (
    CssSelector.class("content0"),
    CssSelector.class("content1")
  )
)

private func tabStyles(
  selectors: [(input: CssSelector, content: CssSelector)],
  showTabStyles: Stylesheet = display(.inherit)
  )
  -> Stylesheet {

    let hideContentStyles = selectors
      .map { _, contentSelector in contentSelector % display(.none) }
      .concat()

    let showContentStyles = selectors
      .map { inputSelector, contentSelector in
        (inputSelector & .pseudo(.checked) ~ .star ** contentSelector) % showTabStyles
      }
      .concat()

    let selectedStyles = selectors
      .map { inputSelector, contentSelector -> Stylesheet in
        (inputSelector & .pseudo(.checked) + .star) % (
          color(Colors.purple) <> backgroundColor(Colors.white)
        )
      }
      .concat()

    return
      hideContentStyles
        <> showContentStyles
        <> selectedStyles
}

func redirectActiveSubscribers<A>(
  user: @escaping (A) -> Database.User?
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        let user = user(conn.data)

        let userSubscription = (user?.subscriptionId)
          .map(
            Current.database.fetchSubscriptionById
              >>> mapExcept(requireSome)
          )
          ?? throwE(unit)

        let ownerSubscription = (user?.id)
          .map(
            Current.database.fetchSubscriptionByOwnerId
              >>> mapExcept(requireSome)
          )
          ?? throwE(unit)

        let race = (userSubscription.run.parallel <|> ownerSubscription.run.parallel).sequential

        return EitherIO(run: race)
          .flatMap {
            $0.stripeSubscriptionStatus == .canceled
              ? throwE(unit as Error)
              : pure($0)
          }
          .run
          .flatMap(
            either(
              const(
                middleware(conn)
              ),
              const(
                conn
                  |> redirect(
                    to: .account(.index),
                    headersMiddleware: flash(.warning, "You already have an active subscription.")
                )
              )
            )
        )
      }
    }
}

private let extraTabStyles: Stylesheet =
  boxShadow(
    hShadow: .px(0),
    vShadow: .px(0),
    blurRadius: .px(5),
    spreadRadius: .px(5),
    color: Color.rgba(0, 0, 0, 0.1)
    )
    <> width(.pct(35))
