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

struct SimplePageLayoutData<A> {
  private(set) var currentRoute: Route?
  private(set) var currentUser: Database.User?
  private(set) var extraStyles: Stylesheet
  private(set) var data: A
  private(set) var flash: Flash?
  private(set) var showTopNav: Bool
  private(set) var title: String
  private(set) var useHighlightJs: Bool

  init(
    currentRoute: Route? = nil,
    currentUser: Database.User?,
    data: A,
    extraStyles: Stylesheet = .empty,
    showTopNav: Bool = true,
    title: String,
    useHighlightJs: Bool = false
    ) {

    self.currentRoute = currentRoute
    self.currentUser = currentUser
    self.data = data
    self.extraStyles = extraStyles
    self.flash = nil
    self.showTopNav = showTopNav
    self.title = title
    self.useHighlightJs = useHighlightJs
  }
}

func respond<A, B>(
  view: View<B>,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
  )
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return { conn in
      let newLayoutData = layoutData(conn.data) |> \.flash .~ conn.request.session.flash

      return conn
        |> writeSessionCookieMiddleware(\.flash .~ nil)
        >-> respond(
          body: simplePageLayout(view).rendered(with: newLayoutData),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(_ contentView: View<A>) -> View<SimplePageLayoutData<A>> {
  return View { layoutData in
    return document([
      html([
        head([
          title(layoutData.title),
          style(renderedNormalizeCss),
          style(styleguide),
          style(render(config: inline, css: pricingExtraStyles)),
          style(layoutData.extraStyles),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          script(
            """
            (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\
            (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\
            })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');\
            ga('create', 'UA-106218876-1', 'auto');\
            ga('send', 'pageview');
            """
          )
          ]
          <> (layoutData.useHighlightJs ? highlightJsHead : [])
        ),
        body(
          (layoutData.flash.map(flashView.view) ?? [])
            <> (layoutData.showTopNav ? darkNavView.view((layoutData.currentUser, layoutData.currentRoute)) : [])
            <> contentView.view(layoutData.data)
            <> footerView.view(layoutData.currentUser)
        )
        ])
      ])
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

private let highlightJsHead: [ChildOf<Element.Head>] = [
  link(
    [rel(.stylesheet), href("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css")]
  ),
  script([src("//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js")]),
  script("hljs.initHighlightingOnLoad();")
]
