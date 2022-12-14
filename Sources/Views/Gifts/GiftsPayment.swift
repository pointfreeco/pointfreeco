import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Stripe

public func giftsPayment(
  plan: Gifts.Plan,
  currentUser: User?,
  stripeJs: String,
  stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
  [
    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 8],
        attributes: [.style(margin(leftRight: .auto))],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          [
            titleView(plan: plan),
            formView(
              plan: plan,
              currentUser: currentUser,
              stripePublishableKey: stripePublishableKey
            ),
          ]
        )
      )
    ),
    .script(attributes: [.src(stripeJs)]),
    .script(
      unsafe: """
        window.addEventListener("load", function() {
          var apiKey = document.getElementById("card-element").dataset.stripeKey
          var stripe = Stripe(apiKey, { apiVersion: "2020-08-27" })
          var elements = stripe.elements()
          var style = {
            base: {
              fontSize: "16px",
            }
          }
          var card = elements.create("card", { style: style })
          card.mount("#card-element")
          var displayError = document.getElementById("card-errors")
          var form = document.getElementById("gift-form")

          card.addEventListener("change", function(event) {
            if (event.error) {
              displayError.textContent = event.error.message
            } else {
              displayError.textContent = ""
            }
          });

          const paymentRequest = stripe.paymentRequest({
            country: 'US',
            currency: 'usd',
            total: { label: '', amount: \(plan.amount), }
          });
          const paymentRequestButton = elements.create('paymentRequestButton', {
            paymentRequest,
          });

          (async () => {
            const result = await paymentRequest.canMakePayment();
            if (result) {
              paymentRequestButton.mount('#payment-request-button');
              document.getElementById("apple-pay-container").style.display = 'block'
            } else {
              document.getElementById('payment-request-button').style.display = 'none';
            }
          })();

          paymentRequest.on('paymentmethod', async (ev) => {
            setFormEnabled(false, () => { return true })
            ev.complete('success')
            form.paymentMethodID.value = ev.paymentMethod.id
            setFormEnabled(true, function(el) { return el.tagName != "BUTTON" })
            form.submit()
          });

          function setFormEnabled(isEnabled, elementsMatching) {
            for (var idx = 0; idx < form.length; idx++) {
              var formElement = form[idx]
              if (elementsMatching(formElement)) {
                formElement.disabled = !isEnabled
                if (formElement.tagName == "BUTTON") {
                  formElement.textContent = isEnabled ? "Purchase" : "Purchasing…"
                }
              }
            }
          }
          var submitting = false
          form.addEventListener("submit", async (event) => {
            event.preventDefault()
            if (submitting) { return }
        
            submitting = true
            setFormEnabled(false, () => { return true })
            displayError.textContent = ""

            try {
              const result = await stripe.createPaymentMethod({
                type: 'card',
                card: card,
                billing_details: {
                  name: form.\(GiftFormData.CodingKeys.fromName.stringValue).value
                }
              })
              if (result.error) {
                if (result.error.message) {
                  displayError.textContent = result.error.message
                } else {
                  displayError.innerHTML = "An error occurred. Please try again or contact <a href='mailto:support@pointfree.co'>support@pointfree.co</a>."
                }
              } else {
                form.\(GiftFormData.CodingKeys.paymentMethodID.stringValue).value = result.paymentMethod.id
                setFormEnabled(true, function(el) { return el.tagName != "BUTTON" })
                form.submit()
                return // NB: Early out so to not re-enable form.
              }
            } catch(error) {
              displayError.innerHTML = "An error occurred. Please try again or contact <a href='mailto:support@pointfree.co'>support@pointfree.co</a>."
            }

            setFormEnabled(true, () => { return true })
            submitting = false
          })
        })
        """
    ),
  ]
}

private func titleView(plan: Gifts.Plan) -> Node {
  .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h1(attributes: [.class([Class.pf.type.responsiveTitle2])], "Gift subscription"),
        .p(.text("Give \(plan.monthCount) months of Point-Free access"))
      )
    )
  )
}

private func formView(
  plan: Gifts.Plan,
  currentUser: User?,
  stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
  .form(
    attributes: [
      .action(siteRouter.path(for: .gifts(.create(.empty)))),
      .id("gift-form"),
      .method(.post),
      .onsubmit(safe: "event.preventDefault()"),
    ],

    .input(
      attributes: [
        .type(.hidden),
        .name("testing"),
        .value("what"),
      ]
    ),

    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        attributes: [.class([Class.padding([.desktop: [.right: 2]])])],
        .div(
          .label(attributes: [.class([labelClass])], "Your name"),
          .input(
            attributes: [
              .class([blockInputClass]),
              .name(GiftFormData.CodingKeys.fromName.stringValue),
              .type(.text),
              .value(currentUser?.displayName ?? ""),
              .required(true),
            ]
          )
        )
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        attributes: [.class([Class.padding([.desktop: [.right: 2]])])],
        .div(
          .label(attributes: [.class([labelClass])], "Your email"),
          .input(
            attributes: [
              .class([blockInputClass]),
              .name(GiftFormData.CodingKeys.fromEmail.stringValue),
              .type(.email),
              .value(currentUser?.email.rawValue ?? ""),
              .required(true),
            ]
          )
        )
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        attributes: [.class([Class.padding([.desktop: [.right: 2]])])],
        .div(
          .label(attributes: [.class([labelClass])], "Recipient's name"),
          .input(
            attributes: [
              .class([blockInputClass]),
              .name(GiftFormData.CodingKeys.toName.stringValue),
              .type(.text),
              .required(true),
              .value("asdf") // TODO: remove debug code
            ]
          )
        )
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        attributes: [.class([Class.padding([.desktop: [.right: 2]])])],
        .div(
          .label(attributes: [.class([labelClass])], "Recipient's email"),
          .input(
            attributes: [
              .class([blockInputClass]),
              .name(GiftFormData.CodingKeys.toEmail.stringValue),
              .type(.email),
              .required(true),
              .value("asdf@asdf.com") // TODO: remove debug code
            ]
          )
        )
      )
    ),

    .label(attributes: [.class([labelClass])], "Delivery Date"),
    .input(
      attributes: [
        .class([blockInputClass]),
        .name(GiftFormData.CodingKeys.deliverAt.stringValue),
        .type(.date),
        .required(false),
      ]
    ),

    .label(attributes: [.class([labelClass])], "Message"),
    .textarea(
      attributes: [
        .class([textAreaClass]),
        .name(GiftFormData.CodingKeys.message.stringValue),
        .rows(5),
      ],
      """
      Hope you enjoy \(plan.monthCount) months of Point-Free!
      """
    ),

    .label(attributes: [.class([labelClass])], "Pay with credit or debit card"),
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile),
          Class.border.all,
          Class.pf.colors.border.gray850,
          Class.padding([.mobile: [.all: 2]]),
          Class.margin([.mobile: [.top: 1]]),
        ])
      ],
      .div(
        attributes: [
          .class([Class.size.width100pct]),
          .data("stripe-key", stripePublishableKey.rawValue),
          .id("card-element"),
        ]
      )
    ),

    .div(
      attributes: [
        .class([
          Class.pf.colors.fg.red,
          Class.pf.type.body.small,
        ]),
        .id("card-errors"),
      ]
    ),

    .gridColumn(
      sizes: [.mobile: 12, .desktop: 12],
      attributes: [
        .id("apple-pay-container"),
        .class([
          Class.padding([.desktop: [.right: 2]]),
          Class.display.none
        ])
      ],
      .label(
        attributes: [
          .class([
            labelClass,
            Class.margin([.mobile: [.top: 2]]),
          ])
        ],
        "or Apple Pay"
      ),
      .div(
        attributes: [
          .id("payment-request-button"),
          .class([
            Class.grid.col(.mobile, 12),
            Class.grid.col(.desktop, 4),
            Class.margin([.mobile: [.top: 2]]),
          ]),
        ],
        []
      )
    ),

    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.mobile),
          Class.margin([.mobile: [.top: 3]]),
        ])
      ],
      .gridColumn(
        sizes: [:],
        attributes: [.class([Class.grid.start(.mobile)])],
        .div(
          attributes: [
            .class([
              Class.flex.flex,
              Class.flex.align.center,
              Class.grid.middle(.mobile),
            ])
          ],
          .h3(
            attributes: [
              .class([
                Class.pf.type.responsiveTitle2,
                Class.type.normal,
                Class.margin([.mobile: [.topBottom: 0]]),
              ])
            ],
            .text("$\(Int(plan.amount.map(Double.init).dollars.rawValue))")
          ),
          .span(
            attributes: [
              .class([
                Class.pf.type.body.small,
                Class.pf.colors.fg.gray400,
                Class.margin([.mobile: [.left: 1]]),
                Class.padding([.mobile: [.bottom: 1]]),
              ])
            ],
            "Total"
          )
        )
      ),
      .gridColumn(
        sizes: [:],
        attributes: [.class([Class.grid.end(.mobile)])],
        .button(
          attributes: [
            .class([
              Class.pf.components.button(color: .black)
            ])
          ],
          "Purchase"
        )
      )
    ),

    .input(
      attributes: [
        .type(.hidden),
        .name(GiftFormData.CodingKeys.monthsFree.stringValue),
        .value("\(plan.monthCount)"),
      ]
    ),
    .input(
      attributes: [
        .type(.hidden),
        .name(GiftFormData.CodingKeys.paymentMethodID.stringValue),
      ]
    )
  )
}

private let textAreaClass =
  Class.size.width100pct
  | Class.display.block
  | Class.type.fontFamily.inherit
  | Class.pf.colors.fg.black
  | ".border-box"
  | Class.border.rounded.all
  | Class.border.all
  | Class.pf.colors.border.gray800
  | Class.padding([.mobile: [.all: 1]])
  | Class.margin([.mobile: [.bottom: 2]])
