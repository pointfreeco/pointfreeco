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

let pricingResponse: Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> =
  writeStatus(.ok)
    >-> respond(pricingView)

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

private let extraStyles: Stylesheet = tabStyles(
  idSelectors: [
    (selectors.input.0, selectors.content.0),
    (selectors.input.1, selectors.content.1),
    ]
)

private let pricingView = View<Prelude.Unit> { _ in
  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(render(config: pretty, css: extraStyles)),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),

      body([
        gridRow([`class`([Class.padding.all(4)])], [
          gridColumn(sizes: [.xs: 12], [
            div([
              input([id(selectors.input.0), type(.radio), name("tabs"), checked(true)]),
              label([`for`(selectors.input.0)], [
                button([`class`([Class.btn.base])], ["Just Me"]),
                ]),

              input([id(selectors.input.1), type(.radio), name("tabs")]),
              label([`for`(selectors.input.1)], [
                button([`class`([Class.btn.base])], ["My Whole Squad"])
                ]),

              gridRow([
                gridColumn(sizes: [.xs: 12], [
                  div(individualPricingView.view(unit) + teamPricingView.view(unit))
                  ])
                ]),

              ]),
            form([action("/subscribe"), id("payment-form"), method(.post)], [
              input([name("plan"), type(.hidden), value(StripeSubscriptionPlan.Id.monthly.rawValue)]),
              input([name("token"), type(.hidden)]),
              div([id("card-element"), data("stripe-key", AppEnvironment.current.envVars.stripe.publishableKey)], []),
              div([id("card-errors"), role(.alert)], []),
              button(["Submit Payment"])
              ])
            ]),

          ]),
        ]
        <> footerView.view(unit)
        <> [
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
      )
    ])
  ])
}

// FIXME: Move to swift-web
public func data<T>(_ name: StaticString, _ value: String) -> Attribute<T> {
  return .init("data-\(name)", value)
}

private let individualPricingView = View<Prelude.Unit> { _ in
  gridRow([id(selectors.content.0)], [
    gridColumn(sizes: [.xs: 12, .md: 6], [
      div(individualMonthlyView.view(unit))
      ]),

    gridColumn(sizes: [.xs: 12, .md: 6], [
      div(individualYearlyView.view(unit))
      ]),
    ])
}

private let individualMonthlyView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.type.align.center, Class.padding.all(2), Class.pf.colors.bg.light, Class.border.rounded.all])], [
    gridColumn(sizes: [.xs: 12], [
      div([
        h3([`class`([Class.h3])], ["Monthly"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        h4([`class`([Class.h4])], ["$18"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        p([`class`([Class.type.caps])], ["per month"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        button([`class`([Class.btn.base])], ["Choose monthly"])
        ])
      ]),
    ])
}

private let individualYearlyView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.type.align.center, Class.padding.all(2), Class.pf.colors.bg.light, Class.border.rounded.all])], [
    gridColumn(sizes: [.xs: 12], [
      div([
        h3([`class`([Class.h3])], ["Yearly"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        h4([`class`([Class.h4])], ["$14"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        p([`class`([Class.type.caps])], ["per month, billed annually"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        button([`class`([Class.btn.base])], ["Choose monthly"])
        ])
      ]),
    gridColumn(sizes: [.xs: 12], [
      div([
        h6([`class`([Class.h6])], ["Save 22%"])
        ])
      ]),
    ])
}

private let teamPricingView = View<Prelude.Unit> { _ in
  gridRow([id(selectors.content.1)], [
    p(["Squad pricing..."])
    ])
}

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
        (inputSelector & .pseudo(.checked) ~ .star ** contentSelector) % showTabStyles
      }
      .concat()

    let hideInputStyles = idSelectors
      .map { inputSelector, _ in inputSelector % display(.none) }
      .concat()

    let selectedStyles = idSelectors
      .map { inputSelector, contentSelector -> Stylesheet in
        let id = (inputSelector.idString ?? "")
        let selector = CssSelector.star["for"==id] ** CssSelector.star
        return (inputSelector & .pseudo(.checked) ~ selector) % color(.orange)
      }
      .concat()

    return
      hideContentStyles
        <> showContentStyles
        <> hideInputStyles
        <> selectedStyles
}
