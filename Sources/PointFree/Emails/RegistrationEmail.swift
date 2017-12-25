import Html
import HtmlCssSupport
import Optics
import Prelude
import Styleguide

let registrationEmailView = simpleEmailLayout(registrationEmailBody)
  .contramap { user in
    SimpleEmailLayoutData(
      title: "Thanks for signing up!",
      preheader: "",
      data: user
    )
}

private let registrationEmailBody = View<GitHub.User> { user in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["Thanks for signing up!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "You’re one step closer to our weekly video series!"
            ]),

          p([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
            """
          To get all that Point-Free has to offer, choose from one of our monthly or yearly plans by clicking
          the link below!
          """
            ]),

          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .pricing(nil, nil))), `class`([Class.pf.components.button(color: .purple)])],
              ["Choose a subscription plan!"])
            ])
          ])
        ])
      ])
    ])
}
