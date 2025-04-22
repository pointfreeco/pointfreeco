import CasePaths
import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import Models
import PointFreeDependencies
import PointFreeRouter
import Styleguide
import StyleguideV2
import Transcripts

// TODO: should all of this be in @Dependency?
public struct SimplePageLayoutData<A> {
  public enum Style {
    case minimal
    case base(NavStyle?)

    public var isMinimal: Bool {
      guard case .minimal = self else { return false }
      return true
    }
  }

  public var data: A
  public var description: String?
  public var extraHead: ChildOf<Tag.Head>
  public var extraStyles: Stylesheet
  public var flash: Flash?
  public var image: String?
  public var openGraphType: OpenGraphType
  public var style: Style
  public var title: String
  public var twitterCard: TwitterCard
  public var usePrismJs: Bool

  public init(
    data: A = (),
    description: String? =
      "Point-Free is a video series exploring advanced programming topics in Swift.",
    extraHead: ChildOf<Tag.Head> = [],
    extraStyles: Stylesheet = .empty,
    image: String? = nil,
    openGraphType: OpenGraphType = .website,
    style: Style = .base(.some(.minimal(.light))),
    title: String,
    twitterCard: TwitterCard = .summaryLargeImage,
    usePrismJs: Bool = false
  ) {
    self.data = data
    self.description = description
    self.extraHead = extraHead
    self.extraStyles = extraStyles
    self.flash = nil
    self.image = image
      ?? "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png"
    self.openGraphType = openGraphType
    self.style = style
    self.title = title
    self.twitterCard = twitterCard
    self.usePrismJs = usePrismJs
  }
}

public func simplePageLayout<A>(
  cssConfig: Css.Config = .pretty,
  emergencyMode: Bool = false,  // TODO: move to @Dependency
  _ contentView: @escaping (A) -> Node
) -> (SimplePageLayoutData<A>) -> Node {
  @Dependency(\.date.now) var now

  return { layoutData -> Node in
    @Dependency(\.currentUser) var currentUser
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
          ghosterBanner(),
          pastDueBanner,
          (layoutData.flash.map(flashView) ?? []),
          liveStreamBanner,
          emergencyModeBanner(emergencyMode, layoutData),
          navView(style: layoutData.style),
          contentView(layoutData.data),
          layoutData.style.isMinimal
            ? []
            : Node { Footer() }
        )
      ),
    ]
  }
}

private var liveStreamBanner: Node {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.livestreams) var livestreams

  guard
    !currentRoute.is(\.live),
    livestreams.first(where: \.isLive) != nil
  else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  let announcementClass =
    Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 4]])
    | Class.pf.colors.bg.gray150
    | Class.pf.colors.fg.gray850
    | Class.pf.colors.link.white
    | Class.pf.type.body.leading

  return .gridRow(
    attributes: [.class([announcementClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .span(
        attributes: [
          .style(safe: "animation: Pulse 3s linear infinite;")
        ],
        "🔴 "
      ),
      .a(
        attributes: [
          .class([
            Class.pf.colors.link.white
              | Class.pf.type.underlineLink
          ]),
          .href(siteRouter.path(for: .live(.current))),
        ],
        .strong("Point-Free Live")
      ),
      ": we are live right now!"
    )
  )
}

struct Banner {
  let endAt: Date
  let markdownContent: String
  let shouldShow: (SiteRoute) -> Bool
  let startAt: Date

  static var allBanners: [Self] {
    @Dependency(\.currentRoute) var currentRoute
    @Dependency(\.date.now) var now
    @Dependency(\.subscriberState) var subscriberState
    @Dependency(\.envVars.appEnv) var appEnv

    let banners: [Self] = []
    return banners.filter { banner in
      return
        appEnv == .development
        || !subscriberState.isActive
          && banner.shouldShow(currentRoute)
          && (banner.startAt...banner.endAt).contains(now)
    }
  }

  static let eoy2024 = Self(
    endAt: yearMonthDayFormatter.date(from: "2025-01-05")!,
    markdownContent: ###"""
      **🎉 End-of-year Sale!** Save 25% when you [subscribe today](/discounts/eoy-2024).
      """###,
    shouldShow: { route in
      if case .subscribeConfirmation = route {
        return false
      } else if case .blog(.show(.left("161-cyber-monday-last-chance-to-save"))) = route {
        return false
      } else if case .blog(.show(.right(161))) = route {
        return false
      } else if case .blog(.show(.left("162-cyber-monday-last-chance-to-save"))) = route {
        return false
      } else if case .blog(.show(.right(162))) = route {
        return false
      } else if case .teamInviteCode = route {
        return false
      } else {
        return true
      }
    },
    startAt: yearMonthDayFormatter.date(from: "2024-12-18")!
  )
}

private func announcementBanner(_ banner: Banner? = nil) -> Node {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  guard let banner = banner
  else { return [] }
  guard
    !subscriberState.isActive,
    banner.shouldShow(currentRoute)
  else { return [] }
  guard (banner.startAt...banner.endAt).contains(now)
  else { return [] }

  let announcementClass =
    Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 3]])
    | Class.pf.colors.bg.gray150
    | Class.pf.colors.fg.white
    | Class.pf.colors.link.white
    | Class.pf.type.body.leading

  return .gridRow(
    attributes: [.class([announcementClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .markdownBlock(banner.markdownContent, darkBackground: true)
    )
  )
}

func emergencyModeBanner<A>(_ emergencyMode: Bool, _ data: SimplePageLayoutData<A>) -> Node {
  guard emergencyMode
  else { return [] }

  let announcementClass =
    Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 3]])
    | Class.pf.colors.bg.yellow
    | Class.pf.colors.fg.black
    | Class.pf.colors.link.white

  return .gridRow(
    attributes: [.class([announcementClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .a(
        attributes: [
          .class([
            Class.pf.colors.link.black
              | Class.pf.type.underlineLink
          ]),
          .href("mailto:support@pointfree.co"),
        ],
        .strong("Temporary service disruption")
      ),
      ": We’re operating with reduced features and will be back soon!"
    )
  )
}

private func navView<A>(style: SimplePageLayoutData<A>.Style) -> Node {
  switch style {
  case let .base(.some(.mountains(style))):
    return mountainNavView(mountainsStyle: style)

  case let .base(.some(.minimal(minimalStyle))):
    return minimalNavView(style: minimalStyle)

  case .base(.none), .minimal:
    return []
  }
}

private let favicons: ChildOf<Tag.Head> = .fragment([
  .link(
    attributes: [
      .rel(.init(rawValue: "apple-touch-icon")),
      .init("sizes", "180x180"),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/apple-touch-icon.png"),
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "icon")),
      .type(.png),
      .init("sizes", "32x32"),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-32x32.png"),
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "icon")),
      .type(.png),
      .init("sizes", "16x16"),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-16x16.png"),
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "manifest")),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/site.webmanifest"),
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "mask-icon")),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/safari-pinned-tab.svg"),
    ]
  ),
])

private var prismJsHead: ChildOf<Tag.Head> {
  let plugins: ChildOf<Tag.Head> = .fragment(
    ["swift", "clike", "css", "diff", "javascript", "ruby", "sh", "sql"]
      .map {
        .script(
          attributes: [
            .src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/components/prism-\($0).min.js")
          ]
        )
      }
  )
  return .fragment([
    .style(
      safe: """
        .language-diff .token.inserted {
          background-color: #f0fff4;
          color: #22863a;
        }

        .language-diff .token.deleted {
          background-color: #ffeef0;
          color: #b31d28;
        }
        """),
    .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.28.0/prism.min.js")]),
    plugins,
    .script(
      safe: #"""
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
        """#),
  ])
}

func ghosterBanner() -> Node {
  @Dependency(\.isGhosting) var isGhosting

  guard isGhosting else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  return .gridRow(
    attributes: [
      .style(safe: "background: linear-gradient(to bottom, #FFF080, #79F2B0);"),
      .class([Class.padding([.mobile: [.all: 4]])]),
    ],
    .gridColumn(
      sizes: [:],
      .div(
        .h3(
          attributes: [.class([Class.pf.type.responsiveTitle3])],
          "You are ghosting 👻"
        ),
        .a(
          attributes: [
            .href(siteRouter.path(for: .endGhosting))
          ],
          "Stop ghosting"
        )
      )
    )
  )
}

var pastDueBanner: Node {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.subscriptionOwner) var subscriptionOwner

  let ownerMessage: String
  if let subscriptionOwner = subscriptionOwner {
    ownerMessage = "\(subscriptionOwner.name ?? "the team owner") (<\(subscriptionOwner.email)>)"
  } else {
    ownerMessage = "the team owner"
  }

  switch subscriberState {
  case .nonSubscriber:
    return []

  case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .none, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your subscription is past-due! Please
        [update your payment info](\(siteRouter.path(for: .account(.paymentInfo())))) to ensure 
        access to Point-Free!
        """
      )
    )

  case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .some, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your subscription is past-due! Please
        contact us at <support@pointfree.co> to regain access to Point-Free.
        """
      )
    )

  case .owner(hasSeat: _, status: .canceled, enterpriseAccount: .none, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your subscription is canceled. To regain access to Point-Free,
        [resubscribe](\(siteRouter.path(for: .pricingLanding))) anytime!
        """
      )
    )

  case .owner(hasSeat: _, status: .canceled, enterpriseAccount: .some, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your subscription is canceled. Please
        contact us at <support@pointfree.co> to regain access to Point-Free.
        """
      )
    )

  case .owner(hasSeat: _, status: .active, enterpriseAccount: _, deactivated: true),
    .owner(hasSeat: _, status: .trialing, enterpriseAccount: _, deactivated: true):
    return flashView(
      .init(
        .warning,
        """
        Your subscription has been deactivated. Please
        contact us at <support@pointfree.co> to regain access to Point-Free.
        """
      )
    )

  case .owner(hasSeat: _, status: _, enterpriseAccount: _, deactivated: _):
    return []

  case .teammate(status: .pastDue, enterpriseAccount: _, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your team's subscription is past-due! Please contact \(ownerMessage) to regain access to
        Point-Free.
        """
      )
    )

  case .teammate(status: .canceled, enterpriseAccount: _, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your team's subscription is canceled. Please contact \(ownerMessage) to regain access to
        Point-Free.
        """
      )
    )

  case .teammate(status: .active, enterpriseAccount: _, deactivated: true),
    .teammate(status: .trialing, enterpriseAccount: _, deactivated: true):
    return flashView(
      .init(
        .warning,
        """
        Your team's subscription is deactivated. Please contact \(ownerMessage) to regain access to
        Point-Free.
        """
      )
    )

  case .teammate(status: _, enterpriseAccount: _, deactivated: _):
    return []
  }
}

public func flashView(_ flash: Flash) -> Node {
  return .gridRow(
    attributes: [.class([flashClass(for: flash.priority)])],
    .gridColumn(
      sizes: [.mobile: 12],
      .markdownBlock(flash.message)
    )
  )
}

private func flashClass(for priority: Flash.Priority) -> CssSelector {
  let base =
    Class.type.align.center
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

private let yearMonthDayFormatter = { () -> DateFormatter in
  let df = DateFormatter()
  df.dateFormat = "yyyy-MM-dd"
  df.timeZone = TimeZone(abbreviation: "GMT")
  return df
}()
