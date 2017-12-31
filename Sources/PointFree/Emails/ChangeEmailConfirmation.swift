import Html
import HtmlCssSupport
import Optics
import Prelude
import Styleguide

let confirmEmailChangeEmailView = simpleEmailLayout(confirmEmailChangeEmailBody)
  .contramap { user, newEmailAddress in
    SimpleEmailLayoutData(
      user: user,
      newsletter: nil,
      title: "Email change confirmation",
      preheader: "",
      data: (user, newEmailAddress)
    )
}

private let confirmEmailChangeEmailBody = View<(Database.User, EmailAddress)> { user, newEmailAddress in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["Confirm email change!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "We received a request to change your email on Point-Free. Your current email is ",
            span([], [.text(encode(user.email.unwrap))]),
            ", and the new email is ",
            span([], [.text(encode(newEmailAddress.unwrap))]),
            ". If you want to make this change, just click the confirmation link below:"
            ]),

          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a(
              [ href(url(to: .confirmEmailChange(userId: user.id, emailAddress: newEmailAddress))),
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
