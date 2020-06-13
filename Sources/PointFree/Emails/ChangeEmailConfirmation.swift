import EmailAddress
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

let confirmEmailChangeEmailView =
  simpleEmailLayout(confirmEmailChangeEmailBody) <<< { user, newEmailAddress, payload in
    SimpleEmailLayoutData(
      user: user,
      newsletter: nil,
      title: "Email change confirmation",
      preheader: "We received a request to change your email on Point-Free.",
      template: .default,
      data: (user, newEmailAddress, payload)
    )
  }

private func confirmEmailChangeEmailBody(
  user: User,
  newEmailAddress: EmailAddress,
  payload: Encrypted<String>
) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "Confirm email change"),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "We received a request to change your email on Point-Free. Your current email is ",
            .span(attributes: [.class([Class.type.semiBold])], .text(user.email.rawValue)),
            ", and the new email is ",
            .span(attributes: [.class([Class.type.semiBold])], .text(newEmailAddress.rawValue)),
            ". If you want to make this change, just click the confirmation link below:"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.top: 2, .bottom: 3]])])],
            .a(
              attributes: [
                .href(url(to: .account(.confirmEmailChange(payload: payload)))),
                .class([Class.pf.components.button(color: .purple)]),
              ],
              "Confirm email change"
            )
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
            """
            If you do not want to make this change, or did not request to make this change, simply ignore
            this email.
            """
          )
        )
      )
    )
  )
}

let emailChangedEmailView =
  simpleEmailLayout(emailChangedEmailBody) <<< { user, newEmailAddress in
    SimpleEmailLayoutData(
      user: user,
      newsletter: nil,
      title: "Your email has been changed",
      preheader: "",
      template: .default,
      data: newEmailAddress
    )
  }

private func emailChangedEmailBody(newEmailAddress: EmailAddress) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "Your email has been changed"),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "Your email has been successfully changed to ",
            .strong(
              .span(attributes: [.class([Class.type.semiBold])], .text(newEmailAddress.rawValue))),
            ". If you did not make this change, please get in touch with us immediately: ",
            .a(attributes: [.mailto("support@pointfree.co")], "support@pointfree.co")
          )
        )
      )
    )
  )
}
