import Html
import HtmlCssSupport
import Optics
import Prelude
import Styleguide
import View

let registrationEmailView = simpleEmailLayout(registrationEmailBody)
  .contramap { user in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Thanks for signing up!",
      preheader: "",
      template: .default,
      data: user
    )
}

private let registrationEmailBody = View<GitHub.User> { user in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([Styleguide.class([Class.padding([.mobile: [.all: 2]])])], [
          h3([Styleguide.class([Class.pf.type.responsiveTitle3])], ["Thanks for signing up!"]),
          p([Styleguide.class([Class.padding([.mobile: [.topBottom: 2]])])], [
            "You’re one step closer to our video series!"
            ]),

          p([Styleguide.class([Class.padding([.mobile: [.bottom: 2]])])], [
            """
            To get all that Point-Free has to offer, choose from one of our monthly or yearly plans by clicking
            the link below!
            """
            ]),

          p([Styleguide.class([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .pricing(nil, expand: nil))), Styleguide.class([Class.pf.components.button(color: .purple)])],
              ["Choose a subscription plan!"])
            ])
          ])
        ])
      ])
    ])
}
