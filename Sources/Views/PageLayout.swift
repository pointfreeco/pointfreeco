import Css
import Foundation
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Styleguide

public struct SimplePageLayoutData<A> {
  public enum Style {
    case minimal
    case base(NavStyle?)

    public var isMinimal: Bool {
      guard case .minimal = self else { return false }
      return true
    }
  }

  public var currentRoute: SiteRoute?
  public var currentSubscriberState: SubscriberState
  public var currentUser: User?
  public var data: A
  public var description: String?
  public var extraHead: ChildOf<Tag.Head>
  public var extraStyles: Stylesheet
  public var flash: Flash?
  public var image: String?
  public var isGhosting: Bool
  public var openGraphType: OpenGraphType
  public var style: Style
  public var title: String
  public var twitterCard: TwitterCard
  public var usePrismJs: Bool

  public init(
    currentRoute: SiteRoute? = nil,
    currentSubscriberState: SubscriberState = .nonSubscriber,
    currentUser: User?,
    data: A,
    description: String? =
      "Point-Free is a video series exploring functional programming and Swift.",
    extraHead: ChildOf<Tag.Head> = [],
    extraStyles: Stylesheet = .empty,
    image: String? = "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
    isGhosting: Bool = false,
    openGraphType: OpenGraphType = .website,
    style: Style = .base(.some(.minimal(.light))),
    title: String,
    twitterCard: TwitterCard = .summaryLargeImage,
    usePrismJs: Bool = false
  ) {
    self.currentRoute = currentRoute
    self.currentSubscriberState = currentSubscriberState
    self.currentUser = currentUser
    self.data = data
    self.description = description
    self.extraHead = extraHead
    self.extraStyles = extraStyles
    self.flash = nil
    self.image = image
    self.isGhosting = isGhosting
    self.openGraphType = openGraphType
    self.style = style
    self.title = title
    self.twitterCard = twitterCard
    self.usePrismJs = usePrismJs
  }
}

public func simplePageLayout<A>(
  cssConfig: Css.Config = .pretty,
  date: @escaping () -> Date = Date.init,
  emergencyMode: Bool = false,
  _ contentView: @escaping (A) -> Node
) -> (SimplePageLayoutData<A>) -> Node {

  return { layoutData -> Node in
    return [
      .doctype,
      .html(
        attributes: [.lang(.en)],
        .head(
          .meta(attributes: [.charset(.utf8)]),
          .title(layoutData.title),
          .style(safe: renderedNormalizeCss),
          .style(styleguide, config: cssConfig),
          .style(layoutData.extraStyles, config: cssConfig),
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
          ghosterBanner(layoutData),
          pastDueBanner(layoutData),
          (layoutData.flash.map(flashView) ?? []),
          announcementBanner(layoutData, date: date),
          emergencyModeBanner(emergencyMode, layoutData),
          navView(layoutData),
          contentView(layoutData.data),
          layoutData.style.isMinimal
            ? []
            : footerView(
              user: layoutData.currentUser,
              year: Calendar(identifier: .gregorian).component(.year, from: date())
            )
        )
      ),
    ]
  }
}

func announcementBanner<A>(
  _ data: SimplePageLayoutData<A>,
  date: () -> Date
) -> Node {
  guard
    case .nonSubscriber = data.currentSubscriberState,
    (post0076_WWDCSale.publishedAt...post0076_WWDCSale.publishedAt.advanced(by: 5 * 24 * 60 * 60))
      .contains(date())
  else { return [] }

  let announcementClass =
    Class.type.align.center
    | Class.padding([.mobile: [.topBottom: 3]])
    | Class.pf.colors.bg.purple
    | Class.pf.colors.fg.gray850
    | Class.pf.colors.link.white

  return .gridRow(
    attributes: [.class([announcementClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .a(
        attributes: [
          .class([
            Class.pf.colors.link.white
              | Class.pf.type.underlineLink
          ]),
          .href(siteRouter.url(for: .blog(.show(slug: post0076_WWDCSale.slug)))),
        ],
        .strong("WWDC sale")
      ),
      ": save 25% when you subscribe!"
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

func navView<A>(_ data: SimplePageLayoutData<A>) -> Node {
  switch data.style {
  case let .base(.some(.mountains(style))):
    return mountainNavView(
      mountainsStyle: style,
      currentUser: data.currentUser,
      subscriberState: data.currentSubscriberState,
      currentRoute: data.currentRoute
    )

  case let .base(.some(.minimal(minimalStyle))):
    return minimalNavView(
      style: minimalStyle,
      currentUser: data.currentUser,
      subscriberState: data.currentSubscriberState,
      currentRoute: data.currentRoute
    )

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
    ["swift", "clike", "css", "diff", "javascript", "ruby"]
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
    .script(safe: #"""
Prism.languages.swift.keyword = [
  /\bany\b/,
  Prism.languages.swift.keyword
];
Prism.languages.insertBefore('swift', 'other-directive', {
  'placeholder': {
    pattern: /<#.+#>/,
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

func ghosterBanner<A>(_ data: SimplePageLayoutData<A>) -> Node {
  guard data.isGhosting else { return [] }

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
        .form(
          attributes: [
            .method(.post),
            .action(siteRouter.path(for: .endGhosting)),
          ],
          .input(
            attributes: [
              .type(.submit),
              .value("Stop ghosting"),
              .class([Class.pf.components.button(color: .white, size: .small)]),
            ]
          )
        )
      )
    )
  )
}

func pastDueBanner<A>(_ data: SimplePageLayoutData<A>) -> Node {
  switch data.currentSubscriberState {
  case .nonSubscriber:
    return []

  case .owner(hasSeat: _, status: .pastDue, enterpriseAccount: .none, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your subscription is past-due! Please
        [update your payment info](\(siteRouter.path(for: .account(.paymentInfo())))) to ensure access to
        Point-Free!
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
        Your team's subscription is past-due! Please contact the team owner to regain access to Point-Free.
        """
      )
    )

  case .teammate(status: .canceled, enterpriseAccount: _, deactivated: _):
    return flashView(
      .init(
        .warning,
        """
        Your team's subscription is canceled. Please contact the team owner to regain access to Point-Free.
        """
      )
    )

  case .teammate(status: .active, enterpriseAccount: _, deactivated: true),
    .teammate(status: .trialing, enterpriseAccount: _, deactivated: true):
    return flashView(
      .init(
        .warning,
        """
        Your team's subscription is deactivated. Please contact the team owner to regain access to Point-Free.
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
