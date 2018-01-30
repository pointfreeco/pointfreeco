import Css
import Html
import Styleguide

extension Stripe {
  public enum html {
    public static let formId = "card-form"

    public static var cardInput: [Node] {
      return [
        input([name("token"), type(.hidden)]),
        div(
          [
            `class`([stripeInputClass]),
            data("stripe-key", AppEnvironment.current.envVars.stripe.publishableKey),
            id("card-element"),
          ],
          []
        )
      ]
    }

    public static let errors = [
      div(
        [
          `class`([Class.pf.colors.fg.red]),
          id("card-errors"),
          role(.alert),
        ],
        []
      )
    ]

    public static var scripts: [Node] {
      return [
        script([src(AppEnvironment.current.stripe.js)]),
        script(
          """
          function setFormEnabled(form, isEnabled) {
            for (var idx = 0; idx < form.length; idx++) {
              var formElement = form[idx];
              formElement.disabled = !isEnabled;
              if (formElement.tagName == 'BUTTON') {
                formElement.textContent = isEnabled ? 'Subscribe to Point‑Free' : 'Subscribing…';
              }
            }
          }

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

          var form = document.getElementById('card-form');
          form.addEventListener('submit', function(event) {
            event.preventDefault();

            setFormEnabled(form, false);

            stripe.createToken(card).then(function(result) {
              setFormEnabled(form, true);

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
    }
  }
}

private let stripeInputClass =
  regularInputClass
    | Class.flex.column
    | Class.flex.flex
    | Class.flex.justify.center
    | Class.size.width100pct
