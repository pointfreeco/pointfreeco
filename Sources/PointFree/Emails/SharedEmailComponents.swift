import Html
import HtmlCssSupport
import Styleguide
import Prelude

let hostSignOffView = View<Prelude.Unit> { _ in
  [
    p([`class`([Class.padding([.mobile: [.top: 2]])])], [
      "Your hosts,"
      ]),
    p([
      a([href(twitterUrl(to: .mbrandonw))], [.text(unsafeUnencodedString("Brandon&nbsp;Williams"))]),
      " & ",
      a([href(twitterUrl(to: .stephencelis))], [.text(unsafeUnencodedString("Stephen&nbsp;Celis"))]),
      ])
  ]
}

let emailFooterView = View<Prelude.Unit> { _ in
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

// TODO: move into a package for html email helpers.
public func emailTable(_ attribs: [Attribute<Element.Table>], _ content: [ChildOf<Element.Table>]) -> Node {
  return table([border(0), cellpadding(0), cellspacing(0)] + attribs, content)
}
