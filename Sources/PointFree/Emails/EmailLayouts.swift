import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

enum EmailLayoutTemplate {
  case blog
  case `default`

  var headerImgSrc: String {
    switch self {
    case .blog:
      return Current.assets.pointersEmailHeaderImgSrc
    case .default:
      return Current.assets.emailHeaderImgSrc
    }
  }
}

/// The data needed to use the simple email layout.
struct SimpleEmailLayoutData<A> {
  let user: Database.User?
  let newsletter: Database.EmailSetting.Newsletter?
  let title: String
  /// Content of the hidden preheader tag at the top of the body. Many email clients will render this as a
  /// preview of the email in the inbox.
  let preheader: String
  let template: EmailLayoutTemplate
  /// Any other data the email view needs to do its job.
  let data: A
}

let emailStylesheet = styleguide
  <> a % key("border-bottom", "1px solid black")

func simpleEmailLayout<A>(_ bodyView: View<A>) -> View<SimpleEmailLayoutData<A>> {
  return View { layoutData in
    document([
      html([xmlns("http://www.w3.org/1999/xhtml")], [
        head([
          style(emailStylesheet),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          meta([httpEquiv(.contentType), content("html"), charset(.utf8)]),
          title(layoutData.title),
          ]),

        body([bgcolor("#FFFFFF")], [
          span([style(preheaderStyles)], [text(layoutData.preheader)]),

          emailTable([height(.pct(100)), style(bodyTableStyles)], [
            tr([
              td([
                img(
                  src: layoutData.template.headerImgSrc,
                  alt: "",
                  [style(maxWidth(.pct(100)))]
                )
                ])
              ]),

            tr([
              td([align(.center), valign(.top)],
                 bodyView.view(layoutData.data)
                  <> emailFooterView.view((layoutData.user, layoutData.newsletter)))
              ])
            ])
          ])
        ])
      ])
    }
    .map { applyInlineStyles(nodes: $0, stylesheet: emailStylesheet) }
}

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

private let preheaderStyles =
  color(.transparent)
    <> display(.none)
    <> opacity(0)
    <> height(0)
    <> width(0)
    <> maxHeight(0)
    <> maxWidth(0)
    <> overflow(.hidden)
