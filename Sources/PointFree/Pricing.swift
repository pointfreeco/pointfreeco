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
          + _pricingView.view(unit)
          + footerView.view(unit)
      )
    ])
  ])
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
