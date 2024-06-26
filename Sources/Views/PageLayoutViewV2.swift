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

public struct PageLayout<Content: NodeView>: NodeView {
  let content: Content
  let layoutData: SimplePageLayoutData<Void>
  let metadata: Metadata<Void>
  let cssConfig: Css.Config
  let emergencyMode: Bool

  public init(
    layoutData: SimplePageLayoutData<Void>,
    metadata: Metadata<Void>,
    cssConfig: Css.Config,
    emergencyMode: Bool,
    @NodeBuilder content: () -> Content
  ) {
    self.content = content()
    self.layoutData = layoutData
    self.metadata = metadata
    self.cssConfig = cssConfig
    self.emergencyMode = emergencyMode
  }

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  public var body: Node {
    Node.doctype

    html {
      head {
        meta {}
          .attribute("charset", "utf8")

        meta {}
          .attribute("name", "viewport")
          .attribute("content", "width=device-width, initial-scale=1")

        Node("title") { layoutData.title }

        layoutData.extraHead.rawValue
        favicons.rawValue
        if layoutData.usePrismJs {
          prismJsHead.rawValue
        }

        Node {
          tag("style") {
            """
            @media only screen and (min-width: 832px) {
              html {
                font-size: 16px;
              }
            }
            @media only screen and (max-width: 831px) {
              html {
                font-size: 14px;
              }
            }

            html {
              font-family: -apple-system, Helvetica Neue, Helvetica, Arial, sans-serif;
              line-height: 1.5;
              -webkit-box-sizing: border-box;
              -moz-box-sizing: border-box;
              -ms-box-sizing: border-box;
              -o-box-sizing: border-box;
              box-sizing: border-box;
            }

            body {
              -webkit-box-sizing: border-box;
              -moz-box-sizing: border-box;
              -ms-box-sizing: border-box;
              -o-box-sizing: border-box;
              box-sizing:border-box
            }

            *, * ::before, * ::after {
              -webkit-box-sizing: inherit;
              -moz-box-sizing: inherit;
              -ms-box-sizing: inherit;
              -o-box-sizing: inherit;
              box-sizing:inherit
            }

            body, html {
              height:100%
            }
            """
          }
        }

        ChildOf<Tag.Head>(arrayLiteral: .fragment([
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
          )
        ])).rawValue
      }
      body {
        ghosterBanner(isGhosting: layoutData.isGhosting)
        pastDueBanner
        if let flash = layoutData.flash {
          flashView(flash)
        }
        announcementBanner(.wwdc24)
        liveStreamBanner
        emergencyModeBanner(emergencyMode, layoutData)
        NavView()
        content
        if !layoutData.style.isMinimal {
          footerView(
            user: currentUser,
            year: Calendar(identifier: .gregorian).component(.year, from: now)
          )
        }
      }
    }
    .attribute("lang", "en")
  }
}

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
        NavView().body,
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

struct NavView: NodeView {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.currentRoute) var siteRoute
  @Dependency(\.siteRouter) var siteRouter

  var body: Node {
    div {
      div {
        GridRow(alignment: .center) {
          GridColumn {
            a {
              Node.img(
                base64: pointFreeTextDiamondLogoSvgBase64(fill: fillColor(for: .black)),
                type: .image(.svg),
                alt: "Point-Free"
              )
            }
            .attribute("href", siteRouter.path(for: .home))
          }
          .columns(2, breakpoint: .mobile)

          GridColumn {
            Node {
              CenteredNavItems()
            }
            .class([Class.grid.middle(.mobile)])
          }
          .columns(8, breakpoint: .desktop)
          .class([
            Class.flex.items.center,
            Class.grid.center(.mobile),
            Class.hide(.mobile),
          ])
          
          GridColumn {
            Node {
              TrailingNavItems()
            }
            .class([Class.grid.end(.mobile)])
          }
          .columns(2, breakpoint: .desktop)
          .class([
            Class.flex.items.end,
            Class.hide(.mobile)
          ])

          GridColumn {
            Node {
              MobileMenu()
            }
          }
          .columns(10, breakpoint: .mobile)
          .class([
            Class.flex.items.end,
            Class.grid.end(.mobile),
            Class.hide(.desktop)
          ])
        }
      }
      .style("max-width", "1080px")
      .style("margin-left", "auto")
      .style("margin-right", "auto")
    }
    .class([newNavBarClass(for: .black)])
  }
}

struct MobileMenu: HTML {
  var body: some HTML {
    div {
      label {
        for index in -1...1 {
          MenuBar(index: index)
        }
      }
      .attribute("class", "menu-checkbox-container")
      .attribute("for", "menu-checkbox")
      .inlineStyle("align-items", "center")
      .inlineStyle("cursor", "pointer")
      .inlineStyle("display", "flex")
      .inlineStyle("flex-direction", "column")
      .inlineStyle("height", "100%")
      .inlineStyle("width", "30px")
      .inlineStyle("justify-content", "center")
    }

    input
      .hidden()
      .attribute("id", "menu-checkbox")
      .attribute("type", "checkbox")
  }

  private struct MenuBar: HTML {
    let index: Int
    var body: some HTML {
      div
        .attribute("class", "menu-bar-\(index)")
        .backgroundColor(.white)
        .inlineStyle("border-radius", "2px")
        .inlineStyle("content", "")
        .inlineStyle("display", "block")
        .inlineStyle("height", "4px")
        .inlineStyle("margin-top", "\(index * 8)px")
        .inlineStyle("position", "absolute")
        .inlineStyle("transition", "transform 400ms cubic-bezier(0.23, 1, 0.32, 1)")
        .inlineStyle("width", "30px")
    }
  }
}

struct TrailingNavItems: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    ul {
      HTMLGroup {
        if currentUser != nil {
          li {
            Button(color: .purple, size: .small) {
              "Account"
            }
            .attribute("href", siteRouter.path(for: .account(.index)))
          }
        } else {
          li {
            Button(color: .purple, size: .small, style: .outline) {
              "Login"
            }
            .attribute("href", siteRouter.path(for: .login(redirect: nil /*TODO*/)))
          }
          li {
            Button(color: .purple, size: .small) {
              "Sign up"
            }
            .attribute("href", siteRouter.path(for: .login(redirect: nil /*TODO*/)))
          }
        }
      }
      .padding(left: .small)
      .attribute("display", "inline")
    }
    .fontStyle(.body(.small))
    .listStyle(.reset)
  }
}

struct CenteredNavItems: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
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
    .listStyle(.reset)
    .fontStyle(.body(.small))
  }
}

struct NavListItem: HTML {
  @Dependency(\.siteRouter) var siteRouter
  let title: String
  let route: SiteRoute
  init(_ title: String, route: SiteRoute) {
    self.title = title
    self.route = route
  }
  var body: some HTML {
    li {
      a { title }
        .attribute("href", siteRouter.path(for: route))
        .color(.gray650, .link)
        .color(.gray650, .visited)
    }
    .padding(left: .medium)
    .inlineStyle("display", "inline")
  }
}
