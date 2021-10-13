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
  stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
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
  )
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
    attributes: [.action(path(to: .gifts(.create))), .method(.post)],
    [
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
        attributes: [.class([Class.flex.flex, Class.grid.middle(.mobile)])],
        .div(
          attributes: [
            .class([Class.size.width100pct]),
            .data("stripe-key", stripePublishableKey.rawValue),
            .id("card-element"),
          ]
        )
      ),

      .input(
        attributes: [
          .type(.submit),
          .class([
            Class.pf.components.button(color: .black),
            Class.margin([.mobile: [.top: 3]])
          ]),
          .value("Purchase"),
        ]
      )
    ]
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
