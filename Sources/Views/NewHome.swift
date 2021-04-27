import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func newHomeView(
  currentDate: Date,
  currentUser: User?,
  subscriberState: SubscriberState,
  episodes: [Episode],
  date: () -> Date,
  emergencyMode: Bool
) -> Node {

//  let episodes = episodes.sorted(by: their(^\.sequence, >))
//
//  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
//  let firstBatch = episodes[0..<ctaInsertionIndex]
//  let secondBatch = episodes[ctaInsertionIndex...]

  func title(_ text: Node...) -> Node {
    .h1(
      attributes: [
        .class([
          Class.pf.colors.fg.white,
          Class.pf.type.responsiveTitle1,
          Class.type.align.center,
        ]),
        .style(lineHeight(1.2))
      ],
      .fragment(text)
    )
  }

  func subtitle(_ text: Node...) -> Node {
    .div(
      attributes: [
        .class([
          Class.pf.colors.fg.gray700,
          Class.pf.type.body.leading,
          Class.type.align.center,
        ]),
      ],
      .fragment(text)
    )
  }

  let header: Node = .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
      ]),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([
            .mobile: [.leftRight: 3, .topBottom: 4],
          ])
        ]),
        .style(maxWidth(.px(1184)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      .gridColumn(
        sizes: [:],
        attributes: [
          .class([
            Class.padding([.desktop: [.leftRight: 5]]),
          ]),
        ],
        title("Explore the wonderful world of functional Swift."),
        .div(
          attributes: [
            .class([
              Class.padding([
                .mobile: [.top: 1, .leftRight: 0],
                .desktop: [.leftRight: 5]
              ]),
            ]),
          ],
          subtitle(
            """
            Point-Free is a video series about combining functional programming concepts with the \
            Swift programming language.
            """
          )
        ),
        .div(
          attributes: [
            .class([
              Class.type.align.center,
              Class.padding([.mobile: [.top: 4]]),
            ])
          ],
          .a(
            attributes: [
              .class([
                Class.border.rounded.all,
                Class.pf.colors.bg.purple,
                Class.pf.colors.fg.white,
                Class.padding([.mobile: [.leftRight: 3, .topBottom: 2]])
              ])
            ],
            "Start with a free episode →"
          )
        )
      )
    )
  )

  return [
    header,
    whatToExpect
  ]
}

#if DEBUG && os(macOS)
  import SwiftUI
  import WebKit

  struct HomePreviews: PreviewProvider {
    static var previews: some View {
      WebPreview(
        html: render(
          simplePageLayout { _ in
            newHomeView(
              currentDate: Date(),
              currentUser: nil,
              subscriberState: .nonSubscriber,
              episodes: [],
              date: Date.init,
              emergencyMode: false
            )
          }(
            SimplePageLayoutData(
              currentUser: nil,
              data: (),
              style: .base(.some(.minimal(.black))),
              title: "ok"
            )
          )
        )
      )
      .previewLayout(.fixed(width: 1440, height: 1800))

      WebPreview(
        html: render(
          simplePageLayout { _ in
            newHomeView(
              currentDate: Date(),
              currentUser: nil,
              subscriberState: .nonSubscriber,
              episodes: [],
              date: Date.init,
              emergencyMode: false
            )
          }(
            SimplePageLayoutData(
              currentUser: nil,
              data: (),
              style: .base(.some(.minimal(.black))),
              title: "ok"
            )
          )
        )
      )
      .previewLayout(.fixed(width: 414, height: 736))
    }
  }

  struct WebPreview: NSViewRepresentable {
    typealias NSViewType = WKWebView

    let html: String

    func makeNSView(context: Context) -> WKWebView {
      let webView = WKWebView()
      webView.loadHTMLString(self.html, baseURL: nil)
      return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
  }
#endif
