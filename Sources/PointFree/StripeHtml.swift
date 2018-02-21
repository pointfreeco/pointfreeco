import Css
import Html
import Styleguide

extension Stripe {
  public enum html {
    public static let formId = "card-form"

    public static func cardInput(billingName: String, expand: Bool) -> [Node] {
      return [
        input([name("token"), type(.hidden)]),
        input([
          `class`([blockInputClass]),
          name("stripe_name"),
          placeholder("Billing Name"),
          type(.text),
          value(billingName),
          ]),
        div([`class`(expand ? [] : [Class.display.none])], [
          input([
            `class`([blockInputClass]),
            name("stripe_address_line1"),
            placeholder("Address"),
            type(.text),
            ]),
          gridRow([
            gridColumn(sizes: [.mobile: 12, .desktop: 5], [
              div([`class`([Class.padding([.desktop: [.right: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_city"),
                  placeholder("City"),
                  type(.text),
                  ])
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 3], [
              div([`class`([Class.padding([.desktop: [.leftRight: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_state"),
                  placeholder("State"),
                  type(.text),
                  ])
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 2], [
              div([`class`([Class.padding([.desktop: [.leftRight: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_zip"),
                  placeholder("Zip"),
                  type(.text),
                  ]),
                ])
              ]),
            gridColumn(sizes: [.mobile: 12, .desktop: 2], [
              div([`class`([Class.padding([.desktop: [.left: 1]])])], [
                input([
                  `class`([blockInputClass]),
                  name("stripe_address_country"),
                  placeholder("Country"),
                  type(.text),
                  ])
                ])
              ]),
            ]),
          input([
            `class`([blockInputClass]),
            name("vatNumber"),
            placeholder("VAT Number (Optional)"),
            type(.text),
            ]),
          ]),
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
          function setFormEnabled(form, isEnabled, elementsMatching) {
            for (var idx = 0; idx < form.length; idx++) {
              var formElement = form[idx];
              if (elementsMatching(formElement)) {
                formElement.disabled = !isEnabled;
                if (formElement.tagName == 'BUTTON') {
                  formElement.textContent = isEnabled ? 'Subscribe to Point‑Free' : 'Subscribing…';
                }
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

            setFormEnabled(form, false, function() {
              return true;
            });

            stripe.createToken(
              card,
              {
                name: form.stripe_name.value,
                address_line1: form.stripe_address_line1.value,
                address_city: form.stripe_address_city.value,
                address_state: form.stripe_address_state.value,
                address_zip: form.stripe_address_zip.value,
                address_country: form.stripe_address_country.value
              }
            ).then(function(result) {
              setFormEnabled(form, true, function(el) {
                return el.tagName != 'BUTTON'
              });

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
