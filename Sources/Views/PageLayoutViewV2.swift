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
        Node {
          NavView()
        }
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

struct NavView: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.currentRoute) var siteRoute
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      div {
        GridRow(alignment: .center) {
          GridColumn {
            a {
              SVG(
                base64: pointFreeTextDiamondLogoSvgBase64(fill: fillColor(for: .black)),
                description: "Point-Free"
              )
            }
            .attribute("href", siteRouter.path(for: .home))
          }
          .column(count: 2)

          GridColumn {
            CenteredNavItems()
          }
          .column(alignment: .center)
          .column(count: 8, media: .desktop)
          .inlineStyle("display", "none", media: MediaQuery.mobile.rawValue)

          GridColumn {
            TrailingNavItems()
          }
          .column(alignment: .end)
          .column(count: 2, media: .desktop)
          .inlineStyle("display", "none", media: MediaQuery.mobile.rawValue)

          GridColumn {
            MobileMenu()
          }
          .column(alignment: .end)
          .column(count: 10)
          .inlineStyle("display", "none", media: MediaQuery.desktop.rawValue)
        }
      }
      .inlineStyle("max-width", "1080px")
      .inlineStyle("margin-left", "auto")
      .inlineStyle("margin-right", "auto")
      .attribute("id", "nav-2")
    }
    .backgroundColor(.black)
    .padding(topBottom: .small, leftRight: .small)
    .attribute("id", "nav-1")
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
      div {}
        .attribute("class", "menu-bar-\(index)")
        .backgroundColor(.white)
        .inlineStyle("border-radius", "2px")
        .inlineStyle("content", "''")
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
