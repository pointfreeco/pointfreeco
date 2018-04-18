import Css
import CssReset
import Either
import Html
import HtmlCssSupport
import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit
import Optics
import SnapshotTesting
import Styleguide

let invoicesView = View<(Stripe.Subscription, Stripe.ListEnvelope<Stripe.Invoice>, Database.User)> { subscription, invoicesEnvelope, currentUser -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          titleRowView.view(unit)
            <> invoicesRowView.view(invoicesEnvelope)
      )
      ])
    ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Payment history"])
        ])
      ])
    ])
}

private let invoicesRowView = View<Stripe.ListEnvelope<Stripe.Invoice>> { invoicesEnvelope in
  div(
    invoicesEnvelope.data.map { invoice in
      gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
        gridColumn(sizes: [.mobile: 4], [
          div([text("#" + invoice.number.unwrap)])
          ]),
        gridColumn(sizes: [.mobile: 4], [`class`([Class.type.align.end])], [
          div([text(dateFormatter.string(from: invoice.date))])
          ]),
        gridColumn(sizes: [.mobile: 2], [`class`([Class.type.align.end])], [
          div([text(format(cents: invoice.total))])
          ]),
        gridColumn(sizes: [.mobile: 2], [`class`([Class.grid.end(.mobile), Class.grid.end(.desktop)])], [
          div([
            a(
              [
                `class`([Class.pf.components.button(color: .purple, size: .small)]),
                href(path(to: .account(.invoices(.show(invoice.id)))))
              ],
              ["Print"]
            )
            ])
          ]),
        ])
    }
  )
}

// ---

let page = simplePageLayout(invoicesView).view(
  .init(
    currentUser: .mock,
    data: (.mock, .mock([.mock, .mock, .mock]), .mock),
    title: "Invoices"
  )
)

AppEnvironment.push(const(.mock))

let htmlStr = render(page, config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
