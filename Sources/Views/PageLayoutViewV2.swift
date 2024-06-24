import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide
import StyleguideV2

public func pageLayoutV2(
  view: Node,
  layoutData: SimplePageLayoutData<Void>,
  metadata: Metadata<Void>,
  cssConfig: Css.Config,
  emergencyMode: Bool
) -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  return [
    .doctype,
    .html(
      attributes: [.lang(.en)],
      .head(
        .meta(attributes: [.charset(.utf8)]),
        .title(layoutData.title),
        .style(safe: renderedNormalizeCss),
        .style(styleguide, config: cssConfig),
        .style(markdownBlockStyles, config: cssConfig),
        .style(layoutData.extraStyles, config: cssConfig),
        .style(
          safe: """
            @keyframes Pulse {
              from { opacity: 1; }
              50% { opacity: 0; }
              to { opacity: 1; }
            }
            """),
        .meta(viewport: .width(.deviceWidth), .initialScale(1)),
        .link(
          attributes: [
            .href(siteRouter.url(for: .feed(.episodes))),
            .rel(.alternate),
            .title("Point-Free Episodes"),
            .type(.application(.init(rawValue: "atom+xml"))),
          ]
        ),
        .link(
          attributes: [
            .href(siteRouter.url(for: .blog(.feed))),
            .rel(.alternate),
            .title("Point-Free Blog"),
            // TODO: add .atom to Html
            .type(.application(.init(rawValue: "atom+xml"))),
          ]
        ),
        (layoutData.usePrismJs ? prismJsHead : []),
        favicons,
        layoutData.extraHead
      ),
      .body(
        ghosterBanner(isGhosting: layoutData.isGhosting),
        pastDueBanner,
        (layoutData.flash.map(flashView) ?? []),
        announcementBanner(.wwdc24),
        liveStreamBanner,
        emergencyModeBanner(emergencyMode, layoutData),
        navViewV2(),
        view,
        layoutData.style.isMinimal
          ? []
          : footerView(
            user: currentUser,
            year: Calendar(identifier: .gregorian).component(.year, from: now)
          )
      )
    ),
  ]
}

public func navViewV2() -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.currentRoute) var siteRoute
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    attributes: [.class([newNavBarClass(for: .black)])],
    .div(
      attributes: [
        .style(.concat(maxWidth(.px(1080)), margin(topBottom: nil, leftRight: .auto)))
      ],
      .gridRow(
        attributes: [.class([Class.flex.items.center])],
        .gridColumn(
          sizes: [.mobile: 2],
          .a(
            attributes: [.href(siteRouter.path(for: .home))],
            .img(
              base64: pointFreeTextDiamondLogoSvgBase64(fill: fillColor(for: .black)),
              type: .image(.svg),
              alt: "Point-Free"
            )
          )
        ),
        .gridColumn(
          sizes: [.desktop: 8],
          attributes: [
            .class([
              Class.flex.items.center,
              Class.grid.center(.mobile),
              Class.hide(.mobile),
            ])
          ],
          CenteredNavItems().body
        ),
        .gridColumn(
          sizes: [.desktop: 2],
          attributes: [
            .class([
              Class.flex.items.end,
              Class.hide(.mobile)
            ])
          ],
          TrailingNavItems().body
        ),
        .gridColumn(
          sizes: [.mobile: 10],
          attributes: [
            .class([
              Class.flex.items.end,
              Class.hide(.desktop)
            ])
          ],
          MobileMenu().body
        )
      )
    )
  )
}

struct MobileMenu: NodeView {
  var body: Node {
    div {
      label {
        for index in -1...1 {
          div {}
          .class([
            Class.display.block,
            Class.pf.colors.bg.white,
            Class.position.absolute,
            .class("menu-bar-\(index)")
          ])
          .style("width", "30px")
          .style("height", "4px")
          .style("border-radius", "2px")
          .style("width", "30px")
          .style("content", "")
          .style("margin-top", "\(index * 8)px")
          .style("transition", "transform 400ms cubic-bezier(0.23, 1, 0.32, 1)")
        }
      }
      .attribute("for", "menu-checkbox")
      .style("height", "100%")
      .style("width", "30px")
      .style("justify-content", "center")
      .style("align-items", "center")
      .class([
        .class("menu-checkbox-container"),
        Class.flex.flex,
        Class.flex.column,
        Class.cursor.pointer,
      ])

      input {}
        .attribute("id", "menu-checkbox")
        .attribute("type", "checkbox")
        .class([Class.hide])
    }
    .class([
      Class.grid.end(.mobile),
    ])
  }
}

struct TrailingNavItems: NodeView {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  var body: Node {
    ul {
      Node {
        if currentUser != nil {
          li {
            a { "Account" }
              .attribute("href", siteRouter.path(for: .account(.index)))
              .class([Class.pf.components.button(color: .purple, size: .small)])
          }
        } else {
          li {
            a { "Login" }
              .attribute("href", siteRouter.path(for: .login(redirect: nil /*TODO*/)))
              .class([Class.pf.components.button(color: .purple, size: .small, style: .outline)])
          }
          li {
            a { "Sign up" }
              .attribute("href", siteRouter.path(for: .login(redirect: nil /*TODO*/)))
              .class([Class.pf.components.button(color: .purple, size: .small)])
          }
        }
      }
      .class([
        Class.padding([.mobile: [.left: 2]]),
        Class.display.inline
      ])
    }
    .class([
      Class.type.list.reset,
      Class.grid.end(.mobile),
      Class.pf.type.body.small
    ])
  }
}

struct CenteredNavItems: NodeView {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  var body: Node {
    ul {
      if currentUser != nil {
        NavListItem("Episodes", route: .homeV2)
      }
      NavListItem("Collections", route: .collections())
      if subscriberState.isNonSubscriber {
        NavListItem("Pricing", route: .pricingLanding)
      }
      NavListItem("Blog", route: .blog())
      NavListItem("Gifts", route: .gifts(.index))
    }
    .class([
      Class.type.list.reset,
      Class.grid.middle(.mobile),
      Class.pf.type.body.small,
    ])
  }
}

struct NavListItem: NodeView {
  @Dependency(\.siteRouter) var siteRouter
  let title: String
  let route: SiteRoute
  init(_ title: String, route: SiteRoute) {
    self.title = title
    self.route = route
  }
  var body: Node {
    li {
      a { title }
        .attribute("href", siteRouter.path(for: route))
        .class([Class.pf.colors.link.gray650])
    }
    .class([
      Class.padding([.mobile: [.left: 3]]),
      Class.display.inline
    ])
  }
}
