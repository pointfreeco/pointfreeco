import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

let teamInviteEmailView = View<(inviter: Database.User, invite: Database.TeamInvite)> { inviter, invite in
  document([
    html([
      head([
        style(styleguide),
        ]),

      body([
        gridRow([
          gridColumn(sizes: [:], [
            div([`class`([Class.padding([.mobile: [.all: 2]])])], [
              h3([`class`([Class.h3])], ["You've been invited!"]),
              p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
                "Your colleague ",
                .text(encode(inviter.name)),
                """
                 has invited you to join their team account on Point-Free, a weekly video series discussing
                functional programming and the Swift language. To accept, simply click the link below!
                """
                ]),
              p([], [
                a([href(url(to: .invite(.show(invite.id))))], ["Click here!"])
                ])
              ])
            ])
          ])
        ])
      ])
    ])
}
