import Css
import FunctionalCss
import Html
import Stripe

public enum StripeHtml {
  public static let formId = "card-form"

  public static func cardInput(couponId: Stripe.Coupon.Id?, publishableKey: String) -> Node {
    return [
      .input(attributes: [.name("token"), .type(.hidden)]),
      .div(
        attributes: [.class(couponId != nil ? [] : [Class.display.none])],
        .input(
          attributes: [
            .class([blockInputClass]),
            .name("coupon"),
            .placeholder("Coupon Code"),
            .type(.text),
            .value(couponId?.rawValue ?? ""),
          ]
        )
      ),
      .div(
        attributes: [
          .class([stripeInputClass]),
          // TODO: StripeHtmlSupport?
          .data("stripe-key", publishableKey),
          .id("card-element"),
        ]
      ),
    ]
  }

  public static let errors = Node.div(
    attributes: [
      .class([Class.pf.colors.fg.red]),
      .id("card-errors"),
      .role(.alert),
    ]
  )

  public static func scripts(src: String) -> Node {
    return [
      .script(attributes: [.src(src)]),
      .script(
        safe:
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

            stripe.createToken(card).then(function(result) {
              if (result.error) {
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;

                setFormEnabled(form, true, function(el) {
                  return true;
                });
              } else {
                setFormEnabled(form, true, function(el) {
                  return el.tagName != 'BUTTON';
                });

                form.token.value = result.token.id;
                form.submit();
              }
            }).catch(function() {
              setFormEnabled(form, true, function(el) {
                return true;
              });
            });
          });
          """
      ),
    ]
  }
}

private let stripeInputClass =
  regularInputClass
  | Class.flex.column
  | Class.flex.flex
  | Class.flex.justify.center
  | Class.size.width100pct
