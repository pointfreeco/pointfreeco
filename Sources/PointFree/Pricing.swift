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

public enum Pricing: Codable, DerivePartialIsos {
  case individual(Billing)
  case team(Int)

  public static let `default` = individual(.monthly)

  public static let validTeamQuantities = 2..<100

  public enum Billing: String, Codable {
    case monthly
    case yearly
  }

  private enum CodingKeys: String, CodingKey {
    case individual
    case team
    case lane
  }

  private enum Lane: String, Codable {
    case individual
    case team
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let billing = try container.decodeIfPresent(Billing.self, forKey: .individual)
    let quantity = try container.decodeIfPresent(Int.self, forKey: .team)
    let lane = try container.decodeIfPresent(Lane.self, forKey: .lane)

    if let lane = lane, let billing = billing, let quantity = quantity {
      self = lane == .individual ? .individual(billing) : .team(quantity)
    } else if let billing = billing {
      self = .individual(billing)
    } else if let quantity = quantity {
      self = .team(quantity)
    } else {
      throw unit // FIXME
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .individual(billing):
      try container.encode(billing, forKey: .individual)
    case let .team(quantity):
      try container.encode(quantity, forKey: .team)
    }
  }

  var plan: Stripe.Plan.Id {
    switch self {
    case .individual(.monthly):
      return .init(unwrap: "individual-monthly")
    case .individual(.yearly):
      return .init(unwrap: "individual-yearly")
    case .team:
      return .init(unwrap: "team-yearly")
    }
  }

  var quantity: Int {
    switch self {
    case .individual:
      return 1
    case let .team(quantity):
      return quantity
    }
  }

  var billing: Billing {
    switch self {
    case let .individual(billing):
      return billing
    case .team:
      return .yearly
    }
  }

  var isIndividual: Bool {
    switch self {
    case .individual:
      return true
    case .team:
      return false
    }
  }

  var isTeam: Bool {
    switch self {
    case .team:
      return true
    case .individual:
      return false
    }
  }
}

let pricingResponse =
  redirectCurrentSubscribers
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: pricingOptionsView,
      layoutData: { currentUser, pricing, route in
        SimplePageLayoutData(
          currentRoute: route,
          currentUser: currentUser,
          data: (currentUser, pricing),
          extraStyles: pricingExtraStyles,
          title: "Subscribe to Point-Free"
        )
    }
)

let pricingOptionsView = View<(Database.User?, Pricing)> { currentUser, pricing in
  gridRow([`class`([Class.pf.colors.bg.purple150, Class.grid.center(.mobile), Class.padding([.desktop: [.top: 4, .bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12, .desktop: 7], [], [

      h2(
        [`class`([Class.pf.colors.fg.white, Class.pf.type.title2])],
        [.text(unsafeUnencodedString("Subscribe to Point&#8209;Free"))]
      ),

      p([`class`([Class.pf.colors.fg.yellow])],
        ["Unlock full episodes and explore a new functional programming concept each week."]),
//        ["""
//         Unlock full episodes and explore a new functional programming concept each week. Here’s just a
//         small sample of what we’re excited to talk about:
//         """]


//      ul(
//        [`class`([Class.pf.colors.fg.yellow, Class.type.align.start])], [
//        li(["Pure functions and side effects"]),
//        li(["Code reuse through function composition"]),
//        li(["Maximizing the use of the type-system"]),
//        li(["Turning programming problems into algebraic problems"]),
//        ]),

      gridRow([`class`([Class.pf.colors.bg.white, Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]])])], [
        gridColumn(sizes: [.mobile: 12], [], [
          form([action(path(to: .subscribe(nil))), id(Stripe.html.formId), method(.post)],
            pricingTabsView.view(pricing)
              + individualPricingRowView.view(pricing)
              + teamPricingRowView.view(pricing)
              + pricingFooterView.view(currentUser)
          )
          ])
        ]),

      gridRow([`class`([Class.pf.colors.bg.white, Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]])])], [
        gridColumn(sizes: [.mobile: 12], [], [


          h3(
            [`class`([Class.pf.colors.fg.white, Class.pf.type.title3])],
            [.text(unsafeUnencodedString("Subscribe to Point&#8209;Free"))]
          ),

          ])
        ])

      ])
    ])
}

private let pricingTabsView = View<Pricing> { pricing in
  [
    input([
      checked(pricing.isIndividual),
      `class`([Class.display.none]),
      id(selectors.input.0),
      name("pricing[lane]"),
      type(.radio),
      value("individual"),
      ]),
    label([`for`(selectors.input.0), `class`([Class.pf.components.pricingTab])], [
      "For you"
      ]),

    input([
      checked(pricing.isTeam),
      `class`([Class.display.none]),
      id(selectors.input.1),
      name("pricing[lane]"),
      type(.radio),
      value("team"),
      ]),
    label([`for`(selectors.input.1), `class`([Class.pf.components.pricingTab])], [
      "For your team"
      ])
  ]
}

private let individualPricingRowView = View<Pricing> { pricing in
  gridRow([id(selectors.content.0)], [
    gridColumn(sizes: [.mobile: 12], [`class`([Class.padding([.mobile: [.top: 3]])])], [
      h5([`class`([Class.pf.type.title5])], ["Invest in your career!"]),

      gridRow(
        individualPricingColumnView.view((.monthly, pricing))
          <> individualPricingColumnView.view((.yearly, pricing))
      ),
      ])
    ])
}

private func isChecked(_ billing: Pricing.Billing, _ pricing: Pricing) -> Bool {
  return pricing.isIndividual
    ? billing == pricing.billing
    : billing == .monthly
}

private let individualPricingColumnView = View<(billing: Pricing.Billing, pricing: Pricing)> {
  gridColumn(sizes: [.mobile: 6], [], [
    label([`for`(radioId(for: $0.billing)), `class`([Class.display.block, Class.padding([.mobile: [.all: 3]])])], [
      gridRow([style(flex(direction: .columnReverse))], [
        input([
          checked(isChecked($0.billing, $0.pricing)),
          id(radioId(for: $0.billing)),
          name("pricing[individual]"),
          type(.radio),
          value($0.billing.rawValue),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h2([`class`([Class.pf.type.title2, Class.type.light, Class.pf.colors.fg.gray650])], [.text(encode(pricingText(for: $0.billing)))]),
          ]),
        gridColumn(sizes: [.mobile: 12], [], [
          h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.gray650])], [.text(encode(title(for: $0.billing)))]),
          ]),
        ])
      ])
    ])
}

private let teamPricingRowView = View<Pricing> { pricing in

  gridRow([id(selectors.content.1)], [
    gridColumn(sizes: [.mobile: 12], [`class`([Class.padding([.mobile: [.top: 3]])])], [
      h5([`class`([Class.pf.type.title5])], ["Invest in your team!"]),

      gridRow([
        gridColumn(sizes: [.mobile: 12], [

          div([`class`([Class.padding([.mobile: [.topBottom: 3]])])], [
            h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.purple])], ["Yearly Plan"]),
            p([`class`([Class.pf.colors.fg.purple])], ["How many in your team?"]),
            input([
              type(.number),
              min(Pricing.validTeamQuantities.lowerBound),
              max(Pricing.validTeamQuantities.upperBound),
              name("pricing[team]"),
              step(1),
              value(clamp(Pricing.validTeamQuantities) <| pricing.quantity),
              `class`([numberSpinner, Class.pf.colors.fg.purple])
              ]),
            h6([`class`([Class.pf.type.title2, Class.type.light, Class.pf.colors.fg.purple])], ["$60/mo"])
            ])
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
    | Class.pf.type.title1
    | Class.border.pill
    | Class.border.all
    | Class.pf.colors.border.gray650
private let extraSpinnerStyles =
  numberSpinnerClass % padding(left: .px(20))
    <> maxWidth(.px(200))

private let pricingFooterView = View<Database.User?> { currentUser in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [], [
      div(
        [`class`([Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
        currentUser
          .map(const(unit) >>> stripeForm.view)
          ?? [gitHubLink(text: "Sign in with GitHub", type: .black, redirectRoute: .pricing(nil, nil))]
        )
      ])
    ])
}

private let stripeForm = View<Prelude.Unit> { _ in
  div(
    [`class`([Class.padding([.mobile: [.left: 3, .right: 3]])])],
    Stripe.html.cardInput
      <> Stripe.html.errors
      <> Stripe.html.scripts
      <> [
        button(
          [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
          ["Subscribe to Point", .text(unsafeUnencodedString("&#8209;")), "Free"]
        )
    ]
  )
}

private func title(for type: Pricing.Billing) -> String {
  switch type {
  case .monthly:
    return "Monthly Plan"
  case .yearly:
    return "Yearly Plan"
  }
}

private func radioId(for type: Pricing.Billing) -> String {
  switch type {
  case .monthly:
    return "monthly"
  case .yearly:
    return "yearly"
  }
}

private func pricingText(for type: Pricing.Billing) -> String {
  switch type {
  case .monthly:
    return "$17/mo"
  case .yearly:
    return "$13/mo"
  }
}

let pricingExtraStyles: Stylesheet =
  ((".block" ** input & .pseudo(.checked) ~ .star) > .star) % color(Colors.purple)
    <> input % color(Colors.gray650)
    <> input % margin(leftRight: .auto)
    <> tabStyles(idSelectors: [(selectors.input.0, selectors.content.0), (selectors.input.1, selectors.content.1)])
    <> extraSpinnerStyles

    // TODO: swift-web needs to support custom pseudoElem and pseudoClass
    <> (input & .elem(.other("::-webkit-inner-spin-button"))) % opacity(1)
    <> (input & .elem(.other("::-webkit-outer-spin-button"))) % opacity(1)

private let selectors = (
  input: (
    CssSelector.id("tab0"),
    CssSelector.id("tab1")
  ),
  content: (
    CssSelector.id("content0"),
    CssSelector.id("content1")
  )
)

private func tabStyles(
  idSelectors: [(input: CssSelector, content: CssSelector)],
  showTabStyles: Stylesheet = display(.flex)
  )
  -> Stylesheet {

    let hideContentStyles = idSelectors
      .map { _, contentSelector in contentSelector % display(.none) }
      .concat()

    let showContentStyles = idSelectors
      .map { inputSelector, contentSelector in
        (inputSelector & .pseudo(.checked) ~ contentSelector) % showTabStyles
      }
      .concat()

    let selectedStyles = idSelectors
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

private func redirectCurrentSubscribers<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {

  return { conn in
    guard
      let user = get1(conn.data),
      let subscriptionId = user.subscriptionId
      else { return middleware(conn) }

    let hasActiveSubscription = AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
      .mapExcept(requireSome)
      .bimap(const(unit), id)
      .flatMap { AppEnvironment.current.stripe.fetchSubscription($0.stripeSubscriptionId) }
      .run
      .map { $0.right?.status == .some(.active) }

    return hasActiveSubscription.flatMap {
      $0
        ? (conn |> redirect(to: .account(.index), headersMiddleware: flash(.warning, "You already have an active subscription.")))
        : middleware(conn)
    }
  }
}
