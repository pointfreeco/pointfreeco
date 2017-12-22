import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

let bodyTableStyles =
  display(.block)
    <> width(.pct(100))
    <> maxWidth(.px(600))
    <> margin(topBottom: 0, leftRight: .auto)
    <> clear(.both)

let contentTableStyles =
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
          style(styleguide),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          meta([httpEquiv(.contentType), content("html"), charset(.utf8)]),
          Html.title(title(data)),
          ]),

        body([bgcolor("#FFFFFF")], [
          span([style(preheaderStyles)], [.text(encode(preheader(data)))]),

          emailTable([height(.pct(100)), width(.pct(100)), style(bodyTableStyles)], [
            tr([
              td([
                img(src: "https://s3.amazonaws.com/pointfree.co/email-assets/pf-email-header.png", alt: "", [style(maxWidth(.pct(100)))])
                ])
              ]),

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
    .map { applyInlineStyles(nodes: $0, stylesheet: styleguide) }
}

public func emailTable(_ attribs: [Attribute<Element.Table>], _ content: [ChildOf<Element.Table>]) -> Node {
  return table([border(0), cellpadding(0), cellspacing(0)] + attribs, content)
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
