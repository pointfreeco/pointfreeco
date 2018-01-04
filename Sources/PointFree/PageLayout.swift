import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

func respond<A>(_ view: View<A>, layout: @escaping (Flash?, View<A>) -> View<A>)
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return { conn in
      conn
        |> writeSessionCookieMiddleware(\.flash .~ nil)
        >-> respond(layout(conn.request.session.flash, view))
    }
}

func simplePageLayout<A>(title titleString: String, currentUser: @escaping (A) -> Database.User?)
  -> (Flash?, View<A>)
  -> View<A> {
    return { flash, contentView in
      return View { data in
        document([
          html([
            head([
              title(titleString),
              style(renderedNormalizeCss),
              style(styleguide),
              style(render(config: pretty, css: pricingExtraStyles)),
              meta(viewport: .width(.deviceWidth), .initialScale(1)),
              ]),
            body(
              (flash.map(flashView.view) ?? [])
                <> darkNavView.view((currentUser(data), nil))
                <> [
                  gridRow([
                    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
                      div(
                        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
                        contentView.view(data)
                      )
                      ])
                    ])
                ]
                <> footerView.view(currentUser(data))
            )
            ])
          ])
      }
    }
}

let flashView = View<Flash> { flash in
  gridRow([`class`([flashClass(for: flash.priority)])], [
    gridColumn(sizes: [.mobile: 12], [text(flash.message)])
    ])
}

private func flashClass(for priority: Flash.Priority) -> CssSelector {
  let base = Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 1]])

  switch priority {
  case .notice:
    return base
      | Class.pf.colors.fg.black
      | Class.pf.colors.bg.green
  case .warning:
    return base
      | Class.pf.colors.fg.black
      | Class.pf.colors.bg.yellow
  case .error:
    return base
      | Class.pf.colors.fg.white
      | Class.pf.colors.bg.red
  }
}
