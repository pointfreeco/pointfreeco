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

  public var currentRoute: Route?
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
    currentRoute: Route? = nil,
    currentSubscriberState: SubscriberState = .nonSubscriber,
    currentUser: User?,
    data: A,
    description: String? = "Point-Free is a video series exploring functional programming and Swift.",
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
              .href(url(to: .feed(.episodes))),
              .rel(.alternate),
              .title("Point-Free Episodes"),
              .type(.application(.init(rawValue: "atom+xml")))
            ]
          ),
          .link(
            attributes: [
              .href(url(to: .blog(.feed))),
              .rel(.alternate),
              .title("Point-Free Blog"),
              // TODO: add .atom to Html
              .type(.application(.init(rawValue: "atom+xml")))
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
          layoutData.style.isMinimal ? [] : footerView(
            user: layoutData.currentUser,
            year: Calendar(identifier: .gregorian).component(.year, from: date())
          )
        )
      )
    ]
  }
}

func announcementBanner<A>(
  _ data: SimplePageLayoutData<A>,
  date: () -> Date
) -> Node {
  guard
    case .nonSubscriber = data.currentSubscriberState,
    (post0067_CyberMondaySale.publishedAt...Date(timeIntervalSince1970: 1638338400))
      .contains(date())
  else { return [] }

  let announcementClass = Class.type.align.center
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
          .href(url(to: .blog(.show(slug: post0067_CyberMondaySale.slug))))
        ],
        .strong("Cyber Monday Sale")
      ),
      ": save 30% when you subscribe!"
    )
  )
}

func emergencyModeBanner<A>(_ emergencyMode: Bool, _ data: SimplePageLayoutData<A>) -> Node {
  guard emergencyMode
  else { return [] }

  let announcementClass = Class.type.align.center
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
          .href("mailto:support@pointfree.co")
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
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/apple-touch-icon.png")
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "icon")),
      .type(.png),
      .init("sizes", "32x32"),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-32x32.png")
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "icon")),
      .type(.png),
      .init("sizes", "16x16"),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-16x16.png")
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "manifest")),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/site.webmanifest")
    ]
  ),
  .link(
    attributes: [
      .rel(.init(rawValue: "mask-icon")),
      .href("https://d3rccdn33rt8ze.cloudfront.net/favicons/safari-pinned-tab.svg")
    ]
  )
])

private let prismJsHead: ChildOf<Tag.Head> = .fragment([
  .style(safe: """
.language-diff .token.inserted {
  background-color: #f0fff4;
  color: #22863a;
}

.language-diff .token.deleted {
  background-color: #ffeef0;
  color: #b31d28;
}
"""),
  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/prism.min.js")]),
//  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-swift.min.js")]),
  .script(safe: #"""
Prism.languages.swift = Prism.languages.extend('clike', {
  'string': {
    pattern: /("|')(?:\\(?:\((?:[^()]|\([^)]+\))+\)|\r\n|[^(])|(?!\1)[^\\\r\n])*\1/,
    greedy: true,
    inside: {
      'interpolation': {
        pattern: /\\\((?:[^()]|\([^)]+\))+\)/,
        inside: {
          delimiter: {
            pattern: /^\\\(|\)$/,
            alias: 'variable'
          }
          // See rest below
        }
      }
    }
  },
  'keyword': /\b(?:actor|as|associativity|async|await|break|case|catch|class|continue|convenience|default|defer|deinit|didSet|do|dynamic(?:Type)?|else|enum|extension|fallthrough|final|for|func|get|guard|if|import|in|infix|init|inout|internal|is|lazy|left|let|mutating|new|none|nonisolated|nonmutating|operator|optional|override|postfix|precedence|prefix|private|protocol|public|repeat|required|rethrows|return|right|safe|self|Self|set|some|static|struct|subscript|super|switch|throws?|try|Type|typealias|unowned|unsafe|var|weak|where|while|willSet|__(?:COLUMN__|FILE__|FUNCTION__|LINE__))\b/,
  'number': /\b(?:[\d_]+(?:\.[\de_]+)?|0x[a-f0-9_]+(?:\.[a-f0-9p_]+)?|0b[01_]+|0o[0-7_]+)\b/i,
  'constant': /\b(?:nil|[A-Z_]{2,}|k[A-Z][A-Za-z_]+)\b/,
  'atrule': /@\b(?:IB(?:Outlet|Designable|Action|Inspectable)|class_protocol|exported|noreturn|NS(?:Copying|Managed)|objc|UIApplicationMain|auto_closure)\b/,
  'builtin': /\b(?:[A-Z]\S+|abs|advance|alignof(?:Value)?|assert|contains|count(?:Elements)?|debugPrint(?:ln)?|distance|drop(?:First|Last)|dump|enumerate|equal|filter|find|first|getVaList|indices|isEmpty|join|last|lexicographicalCompare|map|max(?:Element)?|min(?:Element)?|numericCast|overlaps|partition|print(?:ln)?|reduce|reflect|reverse|sizeof(?:Value)?|sort(?:ed)?|split|startsWith|stride(?:of(?:Value)?)?|suffix|swap|toDebugString|toString|transcode|underestimateCount|unsafeBitCast|with(?:ExtendedLifetime|Unsafe(?:MutablePointers?|Pointers?)|VaList))\b/
});
Prism.languages.swift['string'].inside['interpolation'].inside.rest = Prism.languages.swift;
"""#),
  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-clike.min.js")]),
  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-css.min.js")]),
  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-diff.min.js")]),
  .script(attributes: [.src("//cdnjs.cloudflare.com/ajax/libs/prism/1.24.1/components/prism-markup.min.js")]),
])

func ghosterBanner<A>(_ data: SimplePageLayoutData<A>) -> Node {
  guard data.isGhosting else { return [] }

  return .gridRow(
    attributes: [
      .style(safe: "background: linear-gradient(to bottom, #FFF080, #79F2B0);"),
      .class([Class.padding([.mobile: [.all: 4]])])
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
            .action(pointFreeRouter.path(to: .endGhosting))
          ],
          .input(
            attributes: [
              .type(.submit),
              .value("Stop ghosting"),
              .class([Class.pf.components.button(color: .white, size: .small)])
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
        [update your payment info](\(path(to: .account(.paymentInfo(.show))))) to ensure access to
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
        [resubscribe](\(path(to: .pricingLanding))) anytime!
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
  let base = Class.type.align.center
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

