import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

public func bgcolor<T>(_ value: String) -> Attribute<T> {
  return .init("bgcolor", value)
}

func simpleEmailBody(_ nodes: [Node]) -> [Node] {
  return [
    emailTable([width(.px(600))], [
      tr([
        td([valign(.top)], nodes)
        ])
      ])
  ]
}

private let debugStyles =
  (table | td | tr) % (
    borderColor(all: .red)
      <> borderWidth(all: .px(1))
      <> borderStyle(all: .solid)
)

private let bodyTableStyles =
  display(.block)
    <> width(.pct(100))
    <> maxWidth(.px(600))
    <> margin(topBottom: 0, leftRight: .auto)
    <> clear(.both)

private let contentTableStyles =
  padding(all: .px(16))
    <> maxWidth(.px(600))
    <> margin(topBottom: 0, leftRight: .auto)
    <> display(.block)

func simpleEmailLayout<A>(
  title: @escaping (A) -> String,
  preheader: @escaping (A) -> String = { _ in "" },
  bodyView: View<A>
  ) -> View<A> {

  return View { data in
    document([
      html([xmlns("http://www.w3.org/1999/xhtml")], [
        head([
          style(designSystems),
          style(emailBaseStyles),
//          style(debugStyles),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          meta([httpEquiv(.contentType), content("html"), charset(.utf8)]),
          Html.title(title(data)),
          ]),

        body([bgcolor("#FFFFFF")], [
          span([style(preheaderStyles)], [.text(encode(preheader(data)))]),

          emailTable([height(.pct(100)), width(.pct(100)), style(bodyTableStyles)], [
            tr([
              td([align(.center), valign(.top)],
                 bodyView.view(data)
                  <> emailFooterView.view(unit))
              ])
            ])
          ])
        ])
      ])
  }
}

public func emailTable(_ attribs: [Attribute<Element.Table>], _ content: [ChildOf<Element.Table>]) -> Node {
  return table([border(0), cellpadding(0), cellspacing(0)] + attribs, content)
}


let teamInviteEmailView = simpleEmailLayout(
  title: { "You’re invited to join \($0.0.name)’s team on Point-Free" },
  preheader: { "Your colleage \($0.0.name) has invited you to join their team account on Point-Free." },
  bodyView: inviteBodyView
)

private let inviteBodyView = View<(Database.User, Database.TeamInvite)> { inviter, invite in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.h3])], ["You’re invited!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Your colleague ",
            .text(encode(inviter.name)),
            """
       has invited you to join their team account on Point-Free, a weekly video series discussing
      functional programming and the Swift programming language. To accept, simply click the link below!
      """
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .invite(.show(invite.id)))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["Click here to accept!"])
            ])
          ])
        ])
      ])
    ])
}


let inviteeAcceptedEmailView = simpleEmailLayout(
  title: { _ in "Your invitation was accepted!" },
  bodyView: acceptanceBodyView
)

private let acceptanceBodyView = View<(Database.User, Database.User)> { inviter, invitee in
  emailTable([], [
    tr([
      td([valign(.top)], [
        h3([`class`([Class.pf.type.title4]), `class`([Class.padding([.mobile: [.bottom: 2]])])], [
          "Your invitation was accepted!"
          ]),
        p([
          "Hey ", .text(encode(inviter.name)), "!"
          ]),
        p([
          "Your colleague ",
          .text(encode(invitee.name)),
          " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
          ]),

        p([
          "To review your who is on your team, ",
          a([href(url(to: .account))], ["click here"]),
          "."
          ])
        ])
      ])
    ])
}

private let emailFooterView = View<Prelude.Unit> { _ in
  emailTable([`class`([Class.pf.colors.bg.gray900]), style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          p([`class`([Class.pf.type.body.small])], [
            "Contact us via email at ",
            a([mailto("support@pointfree.co")], ["support@pointfree.co"]),
            ", or on Twitter ",
            a([href(twitterUrl(to: .pointfreeco))], ["@pointfreeco"]),
            "."
            ]),

          p([`class`([Class.pf.type.body.small])], [
            "Our postal address: 139 Skillman #5C, Brooklyn, NY 11211"
            ])
          ])
        ])
      ])
    ])
}

private let preheaderStyles =
  color(.transparent)
    <> display(.none)
    <> opacity(0)
    <> height(0)
    <> width(0)
    <> maxHeight(0)
    <> maxWidth(0)
    <> overflow(.hidden)
