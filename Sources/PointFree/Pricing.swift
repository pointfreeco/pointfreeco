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

enum PricingType {
  case individual(BillingType)
  case team(count: Int)

  enum BillingType {
    case monthly
    case yearly
  }
}

let pricingResponse: Middleware<StatusLineOpen, ResponseEnded, Stripe.Plan.Id, Data> =
  writeStatus(.ok)
    >-> respond(pricingView)

private let pricingView = View<Stripe.Plan.Id> { plan in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(pricingExtraStyles),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),

      body(
        headerView.view(unit)
          + pricingOptionsView.view(unit)
          + footerView.view(unit)
      )
    ])
  ])
}

let pricingOptionsView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.pf.colors.bg.purple150, Class.grid.center(.desktop), Class.padding([.desktop: [.topBottom: 4]])])], [
    gridColumn(sizes: [.desktop: 6], [], [

      h2(
        [`class`([Class.pf.colors.fg.white, Class.pf.type.title2])],
        ["Subscribe to Point", nbHyphen, "Free"]
      ),

      p(
        [`class`([Class.pf.colors.fg.green])],
        ["Unlock full episodes and receive new updates every week."]
      ),

      gridRow([`class`([Class.pf.colors.bg.white, Class.margin([.desktop: [.top: 3]])])], [
        gridColumn(sizes: [.mobile: 12], [], [
          div(
            pricingTabsView.view(unit)
              + individualPricingRowView.view(unit)
              + teamPricingRowView.view(unit)
              + pricingFooterView.view(unit)
          )
          ])
        ])
      ])
    ])
}

private let pricingTabsView = View<Prelude.Unit> { _ in
  [
    input([
      `class`([Class.display.none]),
      id(selectors.input.0),
      type(.radio),
      name("tabs"),
      checked(true)
      ]),
    label([`for`(selectors.input.0), `class`([Class.pf.components.buttons.pricingTab])], [
      "For you"
      ]),

    input([
      `class`([Class.display.none]),
      id(selectors.input.1),
      type(.radio),
      name("tabs")
      ]),
    label([`for`(selectors.input.1), `class`([Class.pf.components.buttons.pricingTab])], [
      "For your team"
      ])
  ]
}

private let individualPricingRowView: View<Prelude.Unit> =
  (curry(gridRow)([id(selectors.content.0)]) >>> pure)
    <¢> individualPricingColumnView.contramap(const(PricingType.BillingType.monthly))
    <> individualPricingColumnView.contramap(const(PricingType.BillingType.yearly))

private let individualPricingColumnView = View<PricingType.BillingType> { billingType in

  gridColumn(sizes: [.desktop: 6], [], [
    label([`for`(radioId(for: billingType)), `class`([Class.display.block, Class.padding([.desktop: [.all: 3]])])], [
      gridRow([style(flex(direction: .columnReverse))], [
        input([
          id(radioId(for: billingType)), name("individual"), type(.radio), checked(billingType == .monthly)]),
        gridColumn(sizes: [.desktop: 12], [], [
          h2([`class`([Class.pf.type.title2, Class.type.light, Class.pf.colors.fg.gray650])], [.text(encode(pricingText(for: billingType)))]),
          ]),
        gridColumn(sizes: [.desktop: 12], [], [
          h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.gray650])], [.text(encode(title(for: billingType)))]),
          ]),
        ])
      ])
    ])
}

private let teamPricingRowView = View<Prelude.Unit> { _ in
  gridRow([id(selectors.content.1)], [
    gridColumn(sizes: [.desktop: 12], [], [
      div([`class`([Class.padding([.desktop: [.topBottom: 3]])])], [
        h6([`class`([Class.pf.type.title6, Class.pf.colors.fg.purple])], ["Yearly Plan"]),
        p([`class`([Class.pf.colors.fg.purple])], ["How many in your team?"]),
        input([
          type(.number),
          min(2),
          max(100),
          step(1),
          value("2"),
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

private let pricingFooterView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.desktop: 12], [], [
      div([`class`([Class.padding([.desktop: [.top: 2, .bottom: 3]])])], [
        gitHubLink(redirectRoute: .pricing(nil))
        ])
      ])
    ])
}

private func title(for type: PricingType.BillingType) -> String {
  switch type {
  case .monthly:
    return "Monthly Plan"
  case .yearly:
    return "Yearly Plan"
  }
}

private func radioId(for type: PricingType.BillingType) -> String {
  switch type {
  case .monthly:
    return "monthly"
  case .yearly:
    return "yearly"
  }
}

private func pricingText(for type: PricingType.BillingType) -> String {
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

private func gitHubLink(redirectRoute: Route) -> Node {
  return a(
    [
      href(path(to: .login(redirect: url(to: redirectRoute)))),
      `class`([Class.pf.components.buttons.black])
    ],
    [
      img(
        base64: gitHubSvgBase64(fill: "#ffffff"),
        mediaType: .image(.svg),
        alt: "",
        [
          `class`([Class.margin([.mobile: [.right: 1]])]),
          style(margin(bottom: .px(-4))),
          width(20),
          height(20)]
      ),
      span(["Sign in with GitHub"])
    ]
  )
}

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
        let id = (inputSelector.idString ?? "")
        let selector = CssSelector.star["for"==id]
        return (inputSelector & .pseudo(.checked) ~ selector) % (
          color(Colors.purple) <> backgroundColor(Colors.white)
        )
      }
      .concat()

    return
      hideContentStyles
        <> showContentStyles
        <> selectedStyles
}

private let stripe = [
  script([src("https://js.stripe.com/v3/")]),
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
