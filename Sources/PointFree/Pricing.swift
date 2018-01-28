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

  public static let teamYearlyBase = 160

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
      return .individualMonthly
    case .individual(.yearly):
      return .individualYearly
    case .team:
      return .teamYearly
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
  redirectActiveSubscribers(user: get1)
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: pricingView,
      layoutData: { currentUser, pricing, route in
        SimplePageLayoutData(
          currentRoute: route,
          currentUser: currentUser,
          data: (currentUser, pricing),
          extraStyles: pricingExtraStyles <> whatToExpectStyles,
          navStyle: .minimal(.dark),
          title: "Subscribe to Point-Free"
        )
    }
)

private let pricingView =
  pricingOptionsView
    <> faqView.contramap(const(unit))

private let pricingOptionsRowClass =
  Class.pf.colors.bg.purple150
    | Class.grid.center(.mobile)
    | Class.padding([.mobile: [.topBottom: 3, .leftRight: 2], .desktop: [.topBottom: 4, .leftRight: 0]])

let pricingOptionsView = View<(Database.User?, Pricing)> { currentUser, pricing in

  gridRow([`class`([pricingOptionsRowClass])], [
    gridColumn(sizes: [.mobile: 12, .desktop: 7], [], [
      div([
        h2(
          [`class`([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle2])],
          [.text(unsafeUnencodedString("Subscribe to Point&#8209;Free"))]
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

        gridRow([`class`([Class.pf.colors.bg.white, Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]])])], [
          gridColumn(sizes: [.mobile: 12], [], [
            form([action(path(to: .subscribe(nil))), id(Stripe.html.formId), method(.post)],
                 pricingTabsView.view(pricing)
                  + individualPricingRowView.view(pricing)
                  + teamPricingRowView.view(pricing)
                  + pricingFooterView.view(currentUser)
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
      [`class`([Class.pf.colors.fg.white, Class.pf.type.title4])],
      [.text(unsafeUnencodedString("What to expect?"))]
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
      [`class`([Class.pf.colors.fg.white, Class.pf.type.title4, Class.padding([.mobile: [.top: 2]])])],
      [.text(unsafeUnencodedString("What kind of topics will you cover?"))]
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
      [`class`([Class.pf.colors.fg.white, Class.pf.type.title4, Class.padding([.mobile: [.top: 2]])])],
      [.text(unsafeUnencodedString("Can I suggest a topic?"))]
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

private let whoAreYou = View<Prelude.Unit> { _ in
  [
    h4(
      [`class`([Class.pf.colors.fg.white, Class.pf.type.title4, Class.padding([.mobile: [.top: 2]])])],
      [.text(unsafeUnencodedString("Who are you?"))]
    ),

    p(
      [`class`([Class.pf.colors.fg.white])],
      [
        "We’re ",
        a([href("http://www.fewbutripe.com"), style(faqLinkStyles)], ["Brandon Williams"]),
        " and ",
        a([href("http://www.stephencelis.com"), style(faqLinkStyles)], ["Stephen Celis"]),
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
          a([href("http://www.stephencelis.com"), style(faqLinkStyles)],
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
            + topicsView.view(unit)
            + suggestATopic.view(unit)
            + whoAreYou.view(unit)
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
  gridRow(
    [id(selectors.content.0)],
    individualPricingColumnView.view((.monthly, pricing))
      <> individualPricingColumnView.view((.yearly, pricing))
  )
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

private let teamPricingRowView = View<Pricing> { pricing -> Node in

  let quantity = clamp(Pricing.validTeamQuantities) <| pricing.quantity

  return gridRow([id(selectors.content.1)], [
    gridColumn(sizes: [.mobile: 12], [], [
      div([`class`([Class.padding([.mobile: [.all: 3]])])], [

        p([`class`([Class.pf.colors.fg.black, Class.pf.type.body.regular])], ["How many in your team?"]),
        
        input([
          `class`([numberSpinner, Class.pf.colors.fg.purple]),
          max(Pricing.validTeamQuantities.upperBound),
          min(Pricing.validTeamQuantities.lowerBound),
          name("pricing[team]"),
          onchange(
            """
            document.getElementById('team-rate').textContent =
              (this.valueAsNumber * \(Pricing.teamYearlyBase))
              .toString()
              .replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");
            """
          ),
          step(1),
          type(.number),
          value(quantity),
          ]),

        hr([
          `class`([
            Class.pf.components.divider,
            Class.margin([.mobile: [.topBottom: 3]])
            ]),
          ]),

        h6([`class`([Class.pf.type.responsiveTitle7, Class.pf.colors.fg.black])], ["Yearly Plan"]),

        h6([
          `class`([
            Class.pf.type.responsiveTitle1,
            Class.type.light,
            Class.pf.colors.fg.black,
            Class.margin([.mobile: [.bottom: 0]])
            ])
          ], [
            "$",
            span(
              [id("team-rate")],
              [text(String(format: "%d", Pricing.teamYearlyBase * quantity))]
            ),
            "/yr"
          ]),

        p([
          `class`([
            Class.pf.type.body.small,
            Class.type.normal,
            Class.pf.colors.fg.gray400,
            Class.margin([.mobile: [.top: 0]])
            ])
          ],
          ["20% off individual monthly"]
        )
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
private let extraSpinnerStyles =
  numberSpinnerClass % (
    padding(left: .px(20))
      <> maxWidth(.px(160))
      <> key("border", "0")
      <> borderStyle(top: .none, right: .none, bottom: .solid, left: .none)
      <> borderColor(top: .none, right: .none, bottom: Colors.gray650, left: .none)
      <> borderWidth(top: .none, right: .none, bottom: .px(1), left: .none)
)

private let pricingFooterView = View<Database.User?> { currentUser in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [], [
      div(
        [`class`([Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
        currentUser
          .map(const(unit) >>> stripeForm.view)
          ?? [gitHubLink(text: "Sign in with GitHub", type: .black, redirectRoute: .pricing(nil))]
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
    return "$170/yr"
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


func redirectActiveSubscribers<A>(
  user: @escaping (A) -> Database.User?
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data> {

    return { middleware in
      return { conn in
        guard
          let user = user(conn.data),
          let subscriptionId = user.subscriptionId
          else { return middleware(conn) }

        let hasActiveSubscription = AppEnvironment.current.database.fetchSubscriptionById(subscriptionId)
          .mapExcept(requireSome)
          .run
          .map { $0.right?.stripeSubscriptionStatus == .some(.active) }

        return hasActiveSubscription.flatMap {
          $0
            ? (conn |> redirect(to: .account(.index),
                                headersMiddleware: flash(.warning, "You already have an active subscription."))
              )
            : middleware(conn)
        }
      }
    }
}
