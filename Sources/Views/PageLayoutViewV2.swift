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

public struct PageLayout<Content: HTML>: NodeView {
  let content: Content
  let layoutData: SimplePageLayoutData<Void>
  let metadata: Metadata<Void>
  let cssConfig: Css.Config
  let emergencyMode: Bool

  public init(
    layoutData: SimplePageLayoutData<Void>,
    metadata: Metadata<Void> = Metadata(),
    cssConfig: Css.Config = .compact,
    emergencyMode: Bool = false,
    @HTMLBuilder content: () -> Content
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
        layoutData.extraHead.rawValue
        favicons.rawValue
        if layoutData.usePrismJs {
          prismJsHead.rawValue
        }

        ChildOf.style(markdownBlockStyles, config: cssConfig).rawValue

        Node {
          meta().attribute("charset", "utf8")
          meta()
            .attribute("theme-color")
            .attribute("#121212")
          meta()
            .attribute("name", "viewport")
            .attribute("content", "width=device-width, initial-scale=1")

          title { HTMLText(layoutData.title) }

          tag("style") { HTMLRaw("\(renderedNormalizeCss)") }
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
              height:100%;
              background: #fff;
            }
            @media (prefers-color-scheme: dark) {
              body, html {
                height:100%;
                background: #121212;
              }
            }

            @keyframes Pulse {
              from { opacity: 1; }
              50% { opacity: 0; }
              to { opacity: 1; }
            }

            .markdown *:link, .markdown *:visited { color: inherit; }
            """
          }

          link()
            .href(siteRouter.url(for: .feed(.episodes)))
            .attribute("rel", "alternate")
            .title("Point-Free Episodes")
            .attribute("type", "application/atom+xml")

          link()
            .href(siteRouter.url(for: .blog(.feed)))
            .attribute("rel", "alternate")
            .title("Point-Free Blog")
            .attribute("type", "application/atom+xml")
        }
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
          content
          if !layoutData.style.isMinimal {
            Footer()
          }
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
        Grid {
          GridColumn {
            Link(href: siteRouter.path(for: .home)) {
              SVG(
                base64: pointFreeTextDiamondLogoSvgBase64(fill: fillColor(for: .black)),
                description: "Point-Free"
              )
            }
          }
          .column(count: 2)

          GridColumn {
            CenteredNavItems()
          }
          .column(alignment: .center)
          .column(count: 8, media: .desktop)
          .inlineStyle("display", "none", media: .mobile)

          GridColumn {
            TrailingNavItems()
          }
          .column(alignment: .end)
          .column(count: 2, media: .desktop)
          .inlineStyle("display", "none", media: .mobile)

          GridColumn {
            MobileMenu()
          }
          .column(alignment: .end)
          .column(count: 10)
          .inlineStyle("display", "none", media: .desktop)
        }
        .grid(alignment: .center)
      }
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin-left", "auto")
      .inlineStyle("margin-right", "auto")
    }
    .backgroundColor(.black)
    .padding(topBottom: .small, leftRight: .small)
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

    input()
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
        NavListItem("Episodes", route: .episodes(.list(.all)))
      }
      NavListItem("Collections", route: .collections())
      if subscriberState.isNonSubscriber {
        NavListItem("Pricing", route: .pricingLanding)
      }
      NavListItem("Blog", route: .blog())
      NavListItem("Gifts", route: .gifts(.index))
    }
    .linkColor(.gray650)
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
      Link(title, href: siteRouter.path(for: route))
    }
    .padding(left: .medium)
    .inlineStyle("display", "inline")
  }
}
