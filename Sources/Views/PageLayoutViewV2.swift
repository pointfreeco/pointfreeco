import Css
import Dependencies
import EnvVars
import Foundation
import FunctionalCss
import Ghosting
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide
import StyleguideV2

public struct PageLayout<Content: HTML>: HTMLDocument {
  let content: Content
  let layoutData: SimplePageLayoutData<Void>
  let metadata: Metadata<Void>
  let cssConfig: Css.Config

  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.isGhosting) var isGhosting

  public init(
    layoutData: SimplePageLayoutData<Void>,
    metadata: Metadata<Void> = Metadata(),
    cssConfig: Css.Config = .compact,
    @HTMLBuilder content: () -> Content
  ) {
    self.content = content()
    self.layoutData = layoutData
    self.metadata = metadata
    self.cssConfig = cssConfig
  }

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  public var head: some HTML {
    tag("title") { HTMLText(layoutData.title) }
    meta()
      .attribute("charset", "UTF-8")
    meta()
      .attribute("name", "theme-color")
      .attribute("content", "#121212")
    meta()
      .attribute("name", "viewport")
      .attribute("content", "width=device-width, initial-scale=1.0, viewport-fit=cover")
    BaseStyles()
    Favicons()
    link()
      .href(siteRouter.url(for: .feed(.episodes)))
      .attribute("rel", "alternate")
      .attribute("title", "Point-Free Episodes")
      .attribute("type", "application/atom+xml")
    link()
      .href(siteRouter.url(for: .blog(.feed)))
      .attribute("rel", "alternate")
      .attribute("title", "Point-Free Blog")
      .attribute("type", "application/atom+xml")
    if layoutData.usePrismJs {
      PrismJSHead()
    }
    script()
      .attribute("defer")
      .attribute("data-domain", "pointfree.co")
      .src("https://plausible.io/js/script.js")
  }

  public var body: some HTML {
    if let flash = layoutData.flash {
      TopBanner(flash: flash)
    }
    if isGhosting {
      TopBanner(style: .notice) {
        "👻 You’re a ghost! "
        Link("Stop ghosting", href: siteRouter.path(for: .endGhosting))
      }
    }
    PastDueBanner()
    if emergencyMode {
      TopBanner(style: .warning) {
        "Temporary service disruption. We’re operating with reduced features and will be back soon!"
      }
    }
    LiveStreamBanner()
    // TODO: Announcement banner
    NavBar()
    content
    if !layoutData.style.isMinimal {
      Footer()
    }
  }
}


struct NavBar: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      nav {
        Logo()
        CenteredNavItems()
        TrailingNavItems()
        MenuButton()
        MobileNavItems()
      }
      .background(.black)
      .flexContainer(
        direction: "row",
        wrap: "wrap",
        justification: "space-between",
        itemAlignment: "center"
      )
      .inlineStyle("padding", "2rem")
      .inlineStyle("padding", "1.5rem", media: .desktop)
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin", "0 auto")
    }
    .background(.black)
    .inlineStyle("width", "100%")
    .inlineStyle("position", "sticky", media: .mobile)
    .inlineStyle("top", "0", media: .mobile)
  }

  struct Logo: HTML {
    @Dependency(\.siteRouter) var siteRouter

    var body: some HTML {
      Link(href: siteRouter.path(for: .home)) {
        SVG(
          base64: pointFreeTextDiamondLogoSvgBase64(fill: "#fff"),
          description: "Point-Free"
        )
      }
      .inlineStyle("line-height", "0")
    }
  }
}

struct MenuButton: HTML {
  var body: some HTML {
    input()
      .attribute("id", "menu-checkbox")
      .attribute("type", "checkbox")
      .inlineStyle("display", "none")

    Bars()
      .attribute("id", "menu-icon")
      .attribute("for", "menu-checkbox")
      .inlineStyle("cursor", "pointer")
      .inlineStyle("display", "none", media: .desktop)
      .inlineStyle("cursor", "pointer")
      .inlineStyle("user-select", "none")
  }

  struct Bars: HTML {
    var body: some HTML {
      label {
        HTMLForEach(-1...1) { index in
          Bar(index: index)
        }
        .size(width: .px(24), height: .px(3))
        .background(.gray900)
        .inlineStyle("display", "block")
        .inlineStyle("border-radius", "1.5px")
        .inlineStyle("transition", "all .2s ease-out, background .2s ease-out")
        .inlineStyle("position", "relative")
      }
    }
  }

  struct Bar: HTML {
    let index: Int
    var body: some HTML {
      span {}
        .inlineStyle("top", index == 0 ? nil : "\(index * 5)px")
        .inlineStyle("top", index == 0 ? nil : index == 1 ? "-5px" : "0", pre: "input:checked ~ #menu-icon")
        .inlineStyle("transform", "rotate(\(index * 45)deg)", pre: "input:checked ~ #menu-icon")
        .inlineStyle("background", index == 0 ? "transparent" : nil, pre: "input:checked ~ #menu-icon")
    }
  }
}

struct MobileNavItems: HTML {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    ul {
      HTMLGroup {
        if currentUser != nil {
          NavListItem("Episodes", route: .episodes(.list(.all)))
        }
        NavListItem("Collections", route: .collections())
        if subscriberState.isNonSubscriber {
          NavListItem("Pricing", route: .pricingLanding)
        }
        NavListItem("Blog", route: .blog())
        NavListItem("Gifts", route: .gifts(.index))
        HTMLGroup {
          if currentUser != nil {
            li {
              Button(color: .purple, size: .small) { "Account" }
                .inlineStyle("text-align", "center")
                .attribute("href", siteRouter.path(for: .account(.index)))
                .inlineStyle("display", "block")
            }
          } else {
            li {
              Button(color: .purple, size: .small, style: .outline) { "Login" }
                .inlineStyle("text-align", "center")
                .attribute(
                  "href",
                  siteRouter.loginPath(redirect: currentRoute)
                )
                .inlineStyle("display", "block")
            }
            li {
              Button(color: .purple, size: .small) { "Sign up" }
                .inlineStyle("text-align", "center")
                .attribute(
                  "href",
                  siteRouter.signUpPath(redirect: currentRoute)
                )
                .inlineStyle("display", "block")
            }
          }
        }
      }
      .inlineStyle("padding-top", "1.5rem")
    }
    .color(.white)
    .listStyle(.reset)
    .flexItem(
      grow: "1",
      shrink: "1",
      basis: "100%"
    )
    .inlineStyle("margin", "0")
    .inlineStyle("display", "none")
    .inlineStyle("display", "block", media: .mobile, pre: "input:checked ~")
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
          .linkColor(.gray650)
          .inlineStyle("display", "block")
      }
    }
  }
}

struct TrailingNavItems: HTML {
  @Dependency(\.currentRoute) var currentRoute
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
            .attribute("href", siteRouter.loginPath(redirect: currentRoute))
          }
          li {
            Button(color: .purple, size: .small) {
              "Sign up"
            }
            .attribute(
              "href",
              siteRouter.signUpPath(redirect: currentRoute)
            )
          }
        }
      }
      .inlineStyle("display", "inline")
      .inlineStyle("padding-left", "1rem", pseudo: .not(.firstChild))
    }
    .listStyle(.reset)
    .inlineStyle("display", "none", media: .mobile)
  }
}

struct CenteredNavItems: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    ul {
      HTMLGroup {
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
      .inlineStyle("padding-left", "1.5rem", media: .desktop)
    }
    .linkColor(.gray650)
    .listStyle(.reset)
    .inlineStyle("display", "none", media: .mobile)
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
      .inlineStyle("padding-left", "2rem", pseudo: .not(.firstChild))
      .inlineStyle("display", "inline")
    }
  }
}

public struct PastDueBanner: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.subscriptionOwner) var subscriptionOwner

  public var body: some HTML {
    switch subscriberState {
    case .nonSubscriber:
      HTMLEmpty()

    case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .none, deactivated: _):
      TopBanner(style: .warning) {
        "Your subscription is past-due! Please "
        Link("update your payment info", href: siteRouter.path(for: .account(.paymentInfo())))
        " to ensure access to Point-Free!"
      }

    case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .some, deactivated: _):
      TopBanner(style: .warning) {
        "Your subscription is past-due! Please contact us at "
        Link("support@pointfree.co", href: "mailto:support@pointfree.co")
        " to regain access to Point-Free."
      }

    case .owner(hasSeat: _, status: .canceled, enterpriseAccount: .none, deactivated: _):
      TopBanner(style: .warning) {
        "Your subscription is canceled. To regain access to Point-Free, "
        Link("resubscribe", href: siteRouter.path(for: .pricingLanding))
        " anytime!"
      }

    case .owner(hasSeat: _, status: .canceled, enterpriseAccount: .some, deactivated: _):
      TopBanner(style: .warning) {
        "Your subscription is canceled. Please contact us at "
        Link("support@pointfree.co", href: "mailto:support@pointfree.co")
        " to regain access to Point-Free."
      }

    case .owner(hasSeat: _, status: .active, enterpriseAccount: _, deactivated: true),
        .owner(hasSeat: _, status: .trialing, enterpriseAccount: _, deactivated: true):
      TopBanner(style: .warning) {
        "Your subscription has been deactivated. Please contact us at "
        Link("support@pointfree.co", href: "mailto:support@pointfree.co")
        " to regain access to Point-Free."
      }

    case .owner(hasSeat: _, status: _, enterpriseAccount: _, deactivated: _):
      HTMLEmpty()

    case .teammate(status: .pastDue, enterpriseAccount: _, deactivated: _):
      TopBanner(style: .warning) {
        "Your team’s subscription is past-due! Please contact "
        owner
        " to regain access to Point-Free."
      }

    case .teammate(status: .canceled, enterpriseAccount: _, deactivated: _):
      TopBanner(style: .warning) {
        "Your team’s subscription is canceled. Please contact "
        owner
        " to regain access to Point-Free."
      }

    case .teammate(status: .active, enterpriseAccount: _, deactivated: true),
        .teammate(status: .trialing, enterpriseAccount: _, deactivated: true):
      TopBanner(style: .warning) {
        "Your team’s subscription is deactivated. Please have "
        owner
        " contact us at "
        Link("support@pointfree.co", href: "mailto:support@pointfree.co")
        " to regain access to Point-Free."
      }

    case .teammate(status: _, enterpriseAccount: _, deactivated: _):
      HTMLEmpty()
    }
  }

  @HTMLBuilder
  private var owner: some HTML {
    if let subscriptionOwner {
      if let name = subscriptionOwner.name {
        HTMLText(name)
      } else {
        "the team owner"
      }
      " ("
      Link(subscriptionOwner.email.rawValue, href: "mailto:\(subscriptionOwner.email.rawValue)")
      ")"
    } else {
      "the team owner"
    }
  }
}

public struct LiveStreamBanner: HTML {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.livestreams) var livestreams
  @Dependency(\.siteRouter) var siteRouter

  public var body: some HTML {
    if !currentRoute.is(\.live), livestreams.first(where: \.isLive) != nil {
      TopBanner(style: .notice) {
        span {
          "●"
        }
        .color(.red)
        .inlineStyle("animation", "Pulse 3s linear infinite")
        .inlineStyle("margin-right", "0.5rem")

        "We’re live! "
        Link("Watch the stream →", href: siteRouter.path(for: .live(.current)))
          .linkStyle(LinkStyle(color: .white, underline: nil))
      }
    }
  }
}

struct TopBanner<Content: HTML>: HTML {
  enum Style {
    case error
    case notice
    case warning

    var color: PointFreeColor {
      switch self {
      case .error:
        return .white.dark(.red)
      case .notice:
        return .gray800
      case .warning:
        return .black.dark(.yellow)
      }
    }

    var backgroundColor: PointFreeColor {
      switch self {
      case .error:
        return .red.dark(.black)
      case .notice:
        return .offBlack
      case .warning:
        return .yellow.dark(.black)
      }
    }
  }

  let style: Style
  let content: Content

  init(style: Style, @HTMLBuilder content: () -> Content) {
    self.style = style
    self.content = content()
  }

  init(flash: Flash) where Content == HTMLText {
    switch flash.priority {
    case .error:
      self.style = .error
    case .notice:
      self.style = .notice
    case .warning:
      self.style = .warning
    }
    self.content = HTMLText(flash.message)
  }

  var body: some HTML {
    div {
      content
    }
    .backgroundColor(style.backgroundColor)
    .color(style.color)
    .linkStyle(LinkStyle(color: style.color, underline: true))
    .inlineStyle("margin", "0 auto")
    .inlineStyle("max-width", "1280px")
    .inlineStyle("padding", "1rem 3rem 1rem")
    .inlineStyle("text-align", "center")
    .fontStyle(.body(.small))
  }
}

private struct Favicons: HTML {
  var body: some HTML {
    link()
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/apple-touch-icon.png")
      .rel("apple-touch-icon")
      .attribute("sizes", "180x180")
    link()
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-32x32.png")
      .rel("icon")
      .attribute("sizes", "32x32")
      .attribute("type", "image/png")
    link()
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-16x16.png")
      .rel("icon")
      .attribute("sizes", "16x16")
      .attribute("type", "image/png")
    link()
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/site.webmanifest")
      .rel("manifest")
    link()
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/safari-pinned-tab.svg")
      .rel("mask-icon")
  }
}

private struct BaseStyles: HTML {
  var body: some HTML {
    style { "\(renderedNormalizeCss)" }
    style {
      """
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
        background: #fff;
      }
      .markdown *:link, .markdown *:visited { color: inherit; }
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
      @media (prefers-color-scheme: dark) {
        body, html {
          background: #121212;
        }
      }
      @keyframes Pulse {
        from { opacity: 1; }
        50% { opacity: 0; }
        to { opacity: 1; }
      }
      """
    }
  }
}

public struct PrismJSHead: HTML {
  public var body: some HTML {
    style {
      """
      .language-diff .token.inserted {
        background-color: #f0fff4;
        color: #22863a;
      }

      .language-diff .token.deleted {
        background-color: #ffeef0;
        color: #b31d28;
      }
      """
    }
    script().src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/prism.min.js")
    HTMLForEach(["swift", "clike", "css", "diff", "javascript", "ruby"]) { lang in
      script().src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/components/prism-\(lang).min.js")
    }
    script {
      #"""
      Prism.languages.swift.keyword = [
        /\b(any|macro)\b/,
        Prism.languages.swift.keyword
      ];
      Prism.languages.insertBefore('swift', 'operator', {
        'code-fold': {
          pattern: /…/
        },
      });
      Prism.languages.insertBefore('swift', 'string-literal', {
        'placeholder': {
          pattern: /<#.+?#>/,
          inside: {
            'placeholder-open': {
              pattern: /<#/
            },
            'placeholder-close': {
              pattern: /#>/
            },
          }
        },
      });
      """#
    }
  }
}
