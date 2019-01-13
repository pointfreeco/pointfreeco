import Html
import HtmlCssSupport
import Optics
import Prelude
import Styleguide
import View

let confirmEmailChangeEmailView = simpleEmailLayout(confirmEmailChangeEmailBody)
  .contramap { user, newEmailAddress in
    SimpleEmailLayoutData(
      user: user,
      newsletter: nil,
      title: "Email change confirmation",
      preheader: "We received a request to change your email on Point-Free.",
      template: .default,
      data: (user, newEmailAddress)
    )
}

private let confirmEmailChangeEmailBody = View<(Database.User, EmailAddress)> { user, newEmailAddress in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Confirm email change"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "We received a request to change your email on Point-Free. Your current email is ",
            span([`class`([Class.type.semiBold])], [.text(user.email.rawValue)]),
            ", and the new email is ",
            span([`class`([Class.type.semiBold])], [.text(newEmailAddress.rawValue)]),
            ". If you want to make this change, just click the confirmation link below:"
            ]),

          p([`class`([Class.padding([.mobile: [.top: 2, .bottom: 3]])])], [
            a(
              [ href(url(to: .account(.confirmEmailChange(userId: user.id, emailAddress: newEmailAddress)))),
                `class`([Class.pf.components.button(color: .purple)]) ],
              ["Confirm email change"]
            )
            ]),

          p([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
            """
            If you do not want to make this change, or did not request to make this change, simply ignore
            this email.
            """
            ])
          ])
        ])
      ])
    ])
}

let emailChangedEmailView = simpleEmailLayout(emailChangedEmailBody)
  .contramap { user, newEmailAddress in
    SimpleEmailLayoutData(
      user: user,
      newsletter: nil,
      title: "Your email has been changed",
      preheader: "",
      template: .default,
      data: newEmailAddress
    )
}

private let emailChangedEmailBody = View<EmailAddress> { newEmailAddress in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.responsiveTitle3])], ["Your email has been changed"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Your email has been successfully changed to ",
            strong([span([`class`([Class.type.semiBold])], [.text(newEmailAddress.rawValue)])]),
            ". If you did not make this change, please get in touch with us immediately: ",
            a([mailto("support@pointfree.co")], ["support@pointfree.co"])
            ])
          ])
        ])
      ])
    ])
}
