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

  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.shouldShowLiveBanner) var shouldShowLiveBanner
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

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
    if let title = metadata.title {
      meta()
        .attribute("name", "title")
        .attribute("content", title)
      meta()
        .attribute("property", "og:title")
        .attribute("content", title)
      meta()
        .attribute("name", "twitter:title")
        .attribute("content", title)
    }
    if let description = metadata.description {
      meta()
        .attribute("name", "description")
        .attribute("content", description)
      meta()
        .attribute("property", "og:description")
        .attribute("content", description)
      meta()
        .attribute("name", "twitter:description")
        .attribute("content", description)
    }
    if let image = metadata.image {
      meta()
        .attribute("property", "og:image")
        .attribute("content", image)
      meta()
        .attribute("name", "twitter:image")
        .attribute("content", image)
    }
    if let type = metadata.type {
      meta()
        .attribute("property", "og:type")
        .attribute("content", type.rawValue)
    }
    if let twitterCard = metadata.twitterCard {
      meta()
        .attribute("name", "twitter:card")
        .attribute("content", twitterCard.rawValue)
    }
    if let twitterSite = metadata.twitterSite {
      meta()
        .attribute("name", "twitter:site")
        .attribute("content", twitterSite)
    }
    if let url = metadata.url {
      meta()
        .attribute("property", "og:url")
        .attribute("content", url)
      meta()
        .attribute("name", "twitter:url")
        .attribute("content", url)
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
        Link("Stop ghosting", destination: .endGhosting)
      }
    }
    PastDueBanner()
    if emergencyMode {
      TopBanner(style: .warning) {
        "Temporary service disruption. We’re operating with reduced features and will be back soon!"
      }
    }
    if shouldShowLiveBanner {
      LiveStreamBanner()
    }
    //    if !subscriberState.isActive && !currentRoute.is(\.subscribeConfirmation) {
    //      if currentRoute.is(\.home) || currentRoute.is(\.blog.index) {
    //        WWDCBanner()
    //      } else {
    //        MinimalWWDCBanner()
    //      }
    //    }
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
    nav {
      div {
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
    .inlineStyle("z-index", "9999")
  }

  struct Logo: HTML {
    @Dependency(\.siteRouter) var siteRouter

    var body: some HTML {
      Link(destination: .home) {
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
        .inlineStyle(
          "top",
          index == 0 ? nil : index == 1 ? "-5px" : "0",
          pre: "input:checked ~ #menu-icon"
        )
        .inlineStyle("transform", "rotate(\(index * 45)deg)", pre: "input:checked ~ #menu-icon")
        .inlineStyle(
          "background",
          index == 0 ? "transparent" : nil,
          pre: "input:checked ~ #menu-icon"
        )
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
        Link(title, destination: route)
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
    let title: String
    let route: SiteRoute
    init(_ title: String, route: SiteRoute) {
      self.title = title
      self.route = route
    }
    var body: some HTML {
      li {
        Link(title, destination: route)
      }
      .inlineStyle("padding-left", "2rem", pseudo: .not(.firstChild))
      .inlineStyle("display", "inline")
    }
  }
}

public struct PastDueBanner: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.subscriptionOwner) var subscriptionOwner

  public var body: some HTML {
    switch subscriberState {
    case .nonSubscriber:
      HTMLEmpty()

    case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .none, deactivated: _):
      TopBanner(style: .warning) {
        "Your subscription is past-due! Please "
        Link("update your payment info", destination: .account(.paymentInfo()))
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
        Link("resubscribe", destination: .pricingLanding)
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
  public var body: some HTML {
    TopBanner(style: .live) {
      span {
        "●"
      }
      .color(.red)
      .inlineStyle("animation", "Pulse 3s linear infinite")
      .inlineStyle("margin-right", "0.5rem")

      "We’re live! "
      Link("Watch the stream →", destination: .live(.current))
        .linkStyle(LinkStyle(color: .white, underline: nil))
    }
  }
}

struct TopBanner<Content: HTML>: HTML {
  enum Style {
    case error
    case live
    case notice
    case warning

    var color: PointFreeColor {
      switch self {
      case .error:
        return .white.dark(.red)
      case .live:
        return .gray800
      case .notice:
        return .black.dark(.green)
      case .warning:
        return .black.dark(.yellow)
      }
    }

    var backgroundColor: PointFreeColor {
      switch self {
      case .error:
        return .red.dark(.offBlack)
      case .live:
        return .offBlack
      case .notice:
        return .green.dark(.offBlack)
      case .warning:
        return .yellow.dark(.offBlack)
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
      div {
        content
      }
      .color(style.color)
      .linkStyle(LinkStyle(color: style.color, underline: true))
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .inlineStyle("padding", "2rem 3rem")
      .inlineStyle("text-align", "center")
      .fontStyle(.body(.small))
    }
    .backgroundColor(style.backgroundColor)
  }
}

struct MinimalWWDCBanner: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      HStack(alignment: .lastTextBaseline, spacing: 2) {
        Spacer()
        VStack(alignment: .leading, spacing: -0.2) {
          div {
            "WWDC WEEK"
          }
          .inlineStyle("font-weight", "1000")
          .inlineStyle("font-size", "2.3rem")
          .inlineStyle("margin-bottom", "-1.5rem")
          div {
            "SALE"
          }
          .inlineStyle("font-weight", "1000")
          .inlineStyle("font-size", "6rem")
        }
        .inlineStyle("margin-top", "0.75rem")

        VStack(alignment: .center, spacing: 0) {
          HStack(alignment: .center, spacing: 0) {
            div { "30" }
              .inlineStyle("font-weight", "1000")
              .inlineStyle("font-size", "4rem")
            VStack(alignment: .leading, spacing: 0) {
              div { "%" }
                .inlineStyle("margin-bottom", "-0.5rem")
                .inlineStyle("font-weight", "700")
                .inlineStyle("font-size", "2rem")
              div { "off" }
                .inlineStyle("font-weight", "700")
                .inlineStyle("font-size", "1rem")
                .inlineStyle("position", "relative")
                .inlineStyle("top", "-0.125rem")
            }
          }
          HStack {
            Spacer()
            Button(color: .purple) {
              span {
                "Subscribe now"
              }
              .padding(leftRight: .small)
            }
            .attribute(
              "href",
              siteRouter.path(for: .discounts(code: "dubdub25", .yearly))
            )
            Spacer()
          }
        }
        Spacer()
      }
      .color(.offBlack)
      .linkStyle(LinkStyle(color: .offWhite, underline: true))
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .inlineStyle("padding", "2rem 2rem")
      .inlineStyle("text-align", "center")
      .inlineStyle("font-size", "1.2rem")
    }
    .inlineStyle(
      "background",
      "linear-gradient(135deg, #fff080 0%, #4cccff 20%, #79f2b0 80%, #974dff 100%)"
    )
  }
}

struct WWDCBanner: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        VStack(alignment: .center, spacing: 0) {
          div {
            "WWDC WEEK"
          }
          .inlineStyle("font-weight", "1000")
          .inlineStyle("font-size", "3.5rem")
          .inlineStyle("margin-bottom", "-3.5rem")
          div {
            "SALE"
          }
          .inlineStyle("font-weight", "1000")
          .inlineStyle("font-size", "10rem")

          HStack(spacing: 1) {
            HTMLForEach(
              [
                "CloudKit",
                "SwiftUI",
                "Architecture",
              ]
                + [
                  "Persistence",
                  "Navigation",
                  "SQLite",
                  "Concurrency",
                ].shuffled()
                + [
                  "Macros",
                  "Dependencies",
                  "Livestreams",
                  "Testing",
                  "Cross-Platform",
                ].shuffled()
            ) { topic in
              span { HTMLText(topic) }
            }
          }
          .inlineStyle("font-size", "1rem")
          .inlineStyle("font-weight", "300")
          .inlineStyle("justify-content", "center")
          .inlineStyle("flex-wrap", "wrap")
          .inlineStyle("row-gap", "0.5rem")
        }
        .inlineStyle("margin-top", "1.5rem")

        VStack {
          VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
              div { "30" }
                .inlineStyle("font-weight", "1000")
                .inlineStyle("font-size", "10rem")
              VStack(alignment: .leading, spacing: 0) {
                div { "%" }
                  .inlineStyle("margin-bottom", "-2rem")
                  .inlineStyle("font-weight", "700")
                  .inlineStyle("font-size", "5rem")
                div { "off" }
                  .inlineStyle("font-weight", "700")
                  .inlineStyle("font-size", "3rem")
              }
            }
            .inlineStyle("margin-bottom", "-2rem")
            div {
              HTMLText("Point-Free for 1 year")
            }
            .inlineStyle("font-weight", "700")
            .inlineStyle("font-size", "1.5rem")
          }
          HStack {
            Spacer()
            Button(color: .purple, size: .large) {
              span {
                "Subscribe now"
              }
              .padding(leftRight: .medium)
            }
            .attribute(
              "href",
              siteRouter.path(for: .discounts(code: "dubdub25", .yearly))
            )
            Spacer()
          }
          div {
            HTMLText("Limited time only")
          }
          .inlineStyle("font-size", "1rem")
          .inlineStyle("font-weight", "300")
        }
      }
      .color(.offBlack)
      .linkStyle(LinkStyle(color: .offWhite, underline: true))
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .inlineStyle("padding", "5rem")
      .inlineStyle("text-align", "center")
      .inlineStyle("font-size", "1.2rem")
    }
    .inlineStyle(
      "background",
      "linear-gradient(135deg, #fff080 0%, #4cccff 20%, #79f2b0 80%, #974dff 100%)"
    )
  }
}

struct AnnouncementBanner<Content: HTML>: HTML {
  let content: Content

  init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some HTML {
    div {
      div {
        content
      }
      .color(.offWhite)
      .linkStyle(LinkStyle(color: .offWhite, underline: true))
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .inlineStyle("padding", "3rem")
      .inlineStyle("text-align", "center")
      .inlineStyle("font-size", "1.2rem")
    }
    .backgroundColor(.purple)
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

public struct PrismJSHead: HTML {
  public var body: some HTML {
    style {
      """
      pre {
        position: relative;
      }

      .line-highlight {
        background-color: rgba(0, 121, 255, 0.1);
        margin-top: 1rem;
        margin-left: -1.5rem;
        position: absolute;
      }

      .highlight-pass .line-highlight {
        background-color: rgba(0, 255, 50, 0.15);
      }

      .highlight-fail .line-highlight {
        background-color: rgba(255, 68, 68, 0.15);
      }

      .highlight-warn .line-highlight {
        background-color: rgba(254, 223, 43, 0.15);
      }

      .language-diff {
        color: #808080;
      }

      .language-diff .token.inserted {
        background-color: #f0fff4;
        color: #22863a;
        margin: -4px;
        padding: 4px;
      }

      .language-diff .token.deleted {
        background-color: #ffeef0;
        color: #b31d28;
        margin: -3px;
        padding: 3px;
      }

      .token.atrule, \
      .token.boolean, \
      .token.constant, \
      .token.directive, \
      .token.directive-name, \
      .token.keyword, \
      .token.other-directive {
        color: #AD3DA4;
      }

      .token.class-name, \
      .token.function {
        color: #4B21B0;
      }

      .token.comment {
        color: #707F8C;
      }
      .token.todo {
        font-weight: 700;
      }

      .token.number, \
      .token.string {
        color: #D22E1B;
      }

      .token.placeholder, .token.code-fold {
        background-color: #bbb;
        border-radius: 6px;
        color: #fff;
        margin: -2px;
        padding: 2px;
      }

      .token.placeholder-open, \
      .token.placeholder-close {
        display: none;
      }

      @media (prefers-color-scheme: dark) {
        .line-highlight {
          background-color: rgba(255, 255, 255, 0.1);
        }

        .language-diff .token.inserted {
          background-color: #071c06;
          color: #6fd574;
        }

        .language-diff .token.deleted {
          background-color: #280c0f;
          color: #f95258;
        }

        .token.atrule, \
        .token.boolean, \
        .token.constant, \
        .token.directive, \
        .token.directive-name, \
        .token.keyword, \
        .token.other-directive {
          color: #FF79B2;
        }

        .token.class-name, \
        .token.function {
          color: #DABAFF;
        }

        .token.comment {
          color: #7E8C98;
        }

        .token.number, \
        .token.string {
          color: #FF8170;
        }

        .token.placeholder, .token.code-fold {
          background-color: #87878A;
        }
      }
      """
    }
    script().src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/prism.min.js")
    script().src(
      "//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/plugins/line-highlight/prism-line-highlight.min.js"
    )
    HTMLForEach(["swift", "clike", "css", "diff", "javascript", "ruby", "sh", "sql"]) { lang in
      script().src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/components/prism-\(lang).min.js")
    }
    script {
      #"""
      Prism.languages.swift['class-name'] = [
        /\b(_[A-Z]\w*)\b/,
        Prism.languages.swift['class-name']
      ];
      Prism.languages.swift.keyword = [
        /\b(any|macro|sending)\b/,
        /\b((iOS|macOS|tvOS|watchOS|visionOS)(|ApplicationExtension)|swift)\b/,
        Prism.languages.swift.keyword
      ];
      Prism.languages.swift.comment.inside = {
        todo: {
          pattern: /(TODO:)/
        }
      };
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

extension DependencyValues {
  var shouldShowLiveBanner: Bool {
    !currentRoute.is(\.live) && livestreams.first(where: \.isLive) != nil
  }
}
