import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import Stripe
import PointFreeRouter

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
            )
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
          card.addEventListener("change", function(event) {
            if (event.error) {
              displayError.textContent = event.error.message
            } else {
              displayError.textContent = ""
            }
          });
          var form = document.getElementById("gift-form")
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
          var submitted = false
          form.addEventListener("submit", function(event) {
            displayError.textContent = ""
            event.preventDefault()
            if (submitted) { return }
            submitted = true
            var json = {}
            var formData = new FormData(form)
            formData.forEach(function(value, name) {
              json[name] = value
            })
            setFormEnabled(false, function() { return true })
            var httpRequest = new XMLHttpRequest()
            httpRequest.open("POST", "\(path(to: .gifts(.create(.empty))))")
            httpRequest.setRequestHeader("Content-Type", "application/json;charset=utf-8")
            httpRequest.onreadystatechange = function() {
              if (httpRequest.readyState == XMLHttpRequest.DONE) {
                setFormEnabled(true, function(el) { return true })
                var response = JSON.parse(httpRequest.responseText)
                  if (response.clientSecret) {
                  stripe.confirmCardPayment(response.clientSecret, {
                    payment_method: {
                      card: card,
                      billing_details: {
                        name: form.\(GiftFormData.CodingKeys.fromName.stringValue).value
                      }
                    }
                  })
                  .then(function(result) {
                    setFormEnabled(true, function(el) { return true })
                    if (result.error) {
                      displayError.textContent = result.error.message
                    } else if (result.paymentIntent.status === "succeeded") {
                      // TODO: Submit form to show flash message
                    }
                  });
                } else if (response.errorMessage) {
                  displayError.textContent = response.errorMessage
                } else {
                  displayError.innerHTML = "An error occurred. Please try again or contact <a href='mailto:support@pointfree.co'>support@pointfree.co</a>."
                }
              }
            }
            httpRequest.send(JSON.stringify(json))
          })
        })
        """
    )
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
      .action(path(to: .gifts(.create(.empty)))),
      .id("gift-form"),
      .method(.post),
      .onsubmit(unsafe: "event.preventDefault()"),
    ],
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

    .label(attributes: [.class([labelClass])], "Payment"),
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile),
          Class.border.all,
          Class.pf.colors.border.gray850,
          Class.padding([.mobile: [.all: 2]]),
          Class.margin([.mobile: [.top: 1]]),
        ]),
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

    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.mobile),
          Class.margin([.mobile: [.top: 3]])
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
                Class.margin([.mobile: [.topBottom: 0]])
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
                Class.padding([.mobile: [.bottom: 1]])
              ])
            ],
            "Total"
          )
        )
      ),
      .gridColumn(
        sizes: [:],
        attributes: [.class([Class.grid.end(.mobile)])],
        .input(
          attributes: [
            .type(.submit),
            .class([
              Class.pf.components.button(color: .black)
            ]),
            .value("Purchase"),
          ]
        )
      )
    ),

    .input(
      attributes: [
        .type(.hidden),
        .name(GiftFormData.CodingKeys.monthsFree.stringValue),
        .value("\(plan.monthCount)")
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
