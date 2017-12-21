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
  writeStatus(.ok)
    >-> respond(pricingView)

private let pricingView = View<(Pricing, Database.User?, Route)> { pricing, user, currentRoute in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(pricingExtraStyles),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),

      body(
        darkNavView.view((user, currentRoute))
          + pricingOptionsView.view((pricing, user))
          + footerView.view(unit)
      )
    ])
  ])
}

let pricingOptionsView = View<(Pricing, Database.User?)> { pricing, user in
  gridRow([`class`([Class.pf.colors.bg.purple150, Class.grid.center(.mobile), Class.padding([.desktop: [.top: 4, .bottom: 4]])])], [
    gridColumn(sizes: [.desktop: 6, .mobile: 12], [], [

      h2(
        [`class`([Class.pf.colors.fg.white, Class.pf.type.title2])],
        ["Subscribe to Point", .text(unsafeUnencodedString("&#8209;")), "Free"]
      ),

      p(
        [`class`([Class.pf.colors.fg.yellow])],
        ["Unlock full episodes and receive new updates every week."]
      ),

      gridRow([`class`([Class.pf.colors.bg.white, Class.padding([.mobile: [.bottom: 3]]), Class.margin([.mobile: [.top: 4]])])], [
        gridColumn(sizes: [.mobile: 12], [], [
          form([action(path(to: .subscribe(nil))), id("payment-form"), method(.post)],
            pricingTabsView.view(pricing)
              + individualPricingRowView.view(pricing)
              + teamPricingRowView.view(pricing)
              + pricingFooterView.view(user)
          )
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
    label([`for`(selectors.input.0), `class`([Class.pf.components.buttons.pricingTab])], [
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
    label([`for`(selectors.input.1), `class`([Class.pf.components.buttons.pricingTab])], [
      "For your team"
      ])
  ]
}

private let individualPricingRowView: View<Pricing> =
  (curry(gridRow)([id(selectors.content.0)]) >>> pure)
    <¢> individualPricingColumnView.contramap { (Pricing.Billing.monthly, $0) }
    <> individualPricingColumnView.contramap { (Pricing.Billing.yearly, $0) }

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
    gridColumn(sizes: [.mobile: 12], [], [
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
}

// TODO: move to point free base styles
private let numberSpinnerClass = CssSelector.class("num-spinner")
private let numberSpinner =
  numberSpinnerClass
    | Class.type.align.center
    | Class.pf.type.title1
    | Class.border.pill
    | Class.border.all
    | Class.pf.colors.border.gray650
private let extraSpinnerStyles =
  numberSpinnerClass % padding(left: .px(20))
    <> maxWidth(.px(200))

private let pricingFooterView = View<Database.User?> { user in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [], [
      div(
        [`class`([Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
        user.map(stripeForm.view) ?? [gitHubLink(text: "Sign in with GitHub", type: .black, redirectRoute: .pricing(nil, nil))]
        )
      ])
    ])
}

private let stripeInputClass =
  regularInputClass
    | Class.flex.column
    | Class.flex.flex
    | Class.flex.justify.center
    | Class.size.width100pct

private let stripeForm = View<Database.User> { user in
  div(
    [`class`([Class.padding([.mobile: [.left: 3, .right: 3]])])],
    [
      input([name("token"), type(.hidden)]),
      div(
        [
          `class`([stripeInputClass]),
          data("stripe-key", AppEnvironment.current.envVars.stripe.publishableKey),
          id("card-element"),
        ],
        []
      ),
      div(
        [
          `class`([Class.pf.colors.fg.red]),
          id("card-errors"),
          role(.alert),
        ],
        []
      ),
      button(
        [`class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])])],
        ["Subscribe to Point-Free"])
      ]
      + stripeScripts)
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

private let stripeScripts = [
  script([src(AppEnvironment.current.stripe.js)]),
  script(
    """
    var apiKey = document.getElementById('card-element').dataset.stripeKey;
    var stripe = Stripe(apiKey);
    var elements = stripe.elements();

    var style = {
      base: {
        color: '#32325d',
        fontSize: '16px',
      }
    };

    var card = elements.create('card', {style: style});
    card.mount('#card-element');

    card.addEventListener('change', function(event) {
      var displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = '';
      }
    });

    var form = document.getElementById('payment-form');
    form.addEventListener('submit', function(event) {
      event.preventDefault();

      stripe.createToken(card).then(function(result) {
        if (result.error) {
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
        } else {
          form.token.value = result.token.id;
          form.submit();
        }
      });
    });
    """
  )
]
