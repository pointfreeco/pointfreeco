import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

enum NavStyle {
  case minimal(MinimalStyle)
  case mountains

  enum MinimalStyle {
    case dark
    case light
  }
}

struct SimplePageLayoutData<A> {
  private(set) var currentRoute: Route?
  private(set) var currentSubscriptionStatus: Stripe.Subscription.Status?
  private(set) var currentUser: Database.User?
  private(set) var data: A
  private(set) var description: String?
  private(set) var extraStyles: Stylesheet
  private(set) var flash: Flash?
  private(set) var image: String?
  private(set) var navStyle: NavStyle?
  private(set) var openGraphType: OpenGraphType
  private(set) var title: String
  private(set) var twitterCard: TwitterCard
  private(set) var usePrismJs: Bool

  init(
    currentRoute: Route? = nil,
    currentSubscriptionStatus: Stripe.Subscription.Status? = nil,
    currentUser: Database.User?,
    data: A,
    description: String? = nil,
    extraStyles: Stylesheet = .empty,
    image: String? = nil,
    navStyle: NavStyle? = .some(.minimal(.light)),
    openGraphType: OpenGraphType = .website,
    title: String,
    twitterCard: TwitterCard = .summaryLargeImage,
    usePrismJs: Bool = false
    ) {

    self.currentRoute = currentRoute
    self.currentSubscriptionStatus = currentSubscriptionStatus
    self.currentUser = currentUser
    self.data = data
    self.description = description
    self.extraStyles = extraStyles
    self.flash = nil
    self.image = image
    self.navStyle = navStyle
    self.openGraphType = openGraphType
    self.title = title
    self.twitterCard = twitterCard
    self.usePrismJs = usePrismJs
  }
}

func respond<A, B>(
  view: View<B>,
  layoutData: @escaping (A) -> SimplePageLayoutData<B>
  )
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return { conn in
      let newLayoutData = layoutData(conn.data) |> \.flash .~ conn.request.session.flash
      let pageLayout = metaLayout(simplePageLayout(view))
        .map(addGoogleAnalytics)
        .contramap(
          Metadata.create(
            description: newLayoutData.description,
            image: newLayoutData.image,
            title: newLayoutData.title,
            twitterCard: newLayoutData.twitterCard,
            twitterSite: "@pointfreeco",
            type: newLayoutData.openGraphType,
            url: newLayoutData.currentRoute.map(url(to:))
          )
      )

      return conn
        |> writeSessionCookieMiddleware(\.flash .~ nil)
        >-> respond(
          body: pageLayout.rendered(with: newLayoutData),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(_ contentView: View<A>) -> View<SimplePageLayoutData<A>> {
  return View { layoutData in
    document([
      html([
        head([
          meta([charset(.utf8)]),
          title(layoutData.title),
          style(renderedNormalizeCss),
          style(styleguide),
          style(layoutData.extraStyles),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          link([
            href(url(to: .feed(.atom))),
            rel(.alternate),
            title("Point-Free Episodes"),
            type(.application(.atom)),
            ])
          ]
          <> (layoutData.usePrismJs ? prismJsHead : [])
        ),
        body(
          (layoutData.flash.map(flashView.view) ?? [])
            <> (layoutData.navStyle.map { navView.view(($0, layoutData.currentUser, layoutData.currentSubscriptionStatus, layoutData.currentRoute)) } ?? [])
            <> contentView.view(layoutData.data)
            <> footerView.view(layoutData.currentUser)
        )
        ])
      ])
  }
}

private let navView = View<(NavStyle, Database.User?, Stripe.Subscription.Status?, Route?)> { navStyle, currentUser, currentSubscriptionStatus, currentRoute -> [Node] in

  switch navStyle {
  case .mountains:
    return mountainNavView.view((currentUser, currentSubscriptionStatus, currentRoute))
  case let .minimal(minimalStyle):
    return minimalNavView.view((minimalStyle, currentUser, currentSubscriptionStatus, currentRoute))
  }
}

let flashView = View<Flash> { flash in
  gridRow([`class`([flashClass(for: flash.priority)])], [
    gridColumn(sizes: [.mobile: 12], [text(flash.message)])
    ])
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

private let prismJsHead: [ChildOf<Element.Head>] = [
  script([src("//cdnjs.cloudflare.com/ajax/libs/prism/1.10.0/prism.min.js")]),
  script(
    """
    Prism.languages.swift = Prism.languages.extend("clike", {
      string: {
        pattern: /("|')(\\\\(?:\\((?:[^()]|\\([^)]+\\))+\\)|\\r\\n|[\\s\\S])|(?!\\1)[^\\\\\\r\\n])*\\1/,
        greedy: !0,
        inside: {
          interpolation: {
            pattern: /\\\\\\((?:[^()]|\\([^)]+\\))+\\)/,
            inside: {
              delimiter: {
                pattern: /^\\\\\\(|\\)$/,
                alias: "variable"
              }
            }
          }
        }
      },
      keyword: /\\b(?:as|associativity|break|case|catch|class|continue|convenience|default|defer|deinit|didSet|do|dynamic(?:Type)?|else|enum|extension|fallthrough|final|for|func|get|guard|higherThan|if|import|in|infix|init|inout|internal|is|lazy|left|let|lowerThan|mutating|new|none|nonmutating|operator|optional|override|postfix|precedencegroup|prefix|private|Protocol|public|repeat|required|rethrows|return|right|safe|self|Self|set|static|struct|subscript|super|switch|throws?|try|Type|typealias|unowned|unsafe|var|weak|where|while|willSet|__(?:COLUMN__|FILE__|FUNCTION__|LINE__))\\b|@(?:autoclosure(?:\\(.*\\))?|availability\\(.*\\)|convention|discardableResult|escaping|GKInspectable|nonobjc|NSApplicationMain|NSCopying|NSManaged|objc|objcMembers|testable|UIApplicationMain)\\b/,
      number: /\\b(?:[\\d_]+(?:\\.[\\de_]+)?|0x[a-f0-9_]+(?:\\.[a-f0-9p_]+)?|0b[01_]+|0o[0-7_]+)\\b/i,
      constant: /\\b(?:nil|[A-Z_]{2,}|k[A-Z][A-Za-z_]+)\\b/,atrule:/@\\b(?:IB(?:Outlet|Designable|Action|Inspectable)|class_protocol|exported|noreturn|NS(?:Copying|Managed)|objc|UIApplicationMain|auto_closure)\\b/,
      builtin: /\\b(?:[A-Z]\\S+|abs|advance|alignof(?:Value)?|assert|contains|count(?:Elements)?|debugPrint(?:ln)?|distance|drop(?:First|Last)|dump|enumerate|equal|filter|find|first|getVaList|indices|isEmpty|join|last|lexicographicalCompare|map|max(?:Element)?|min(?:Element)?|numericCast|overlaps|partition|print(?:ln)?|reduce|reflect|reverse|sizeof(?:Value)?|sort(?:ed)?|split|startsWith|stride(?:of(?:Value)?)?|suffix|swap|toDebugString|toString|transcode|underestimateCount|unsafeBitCast|with(?:ExtendedLifetime|Unsafe(?:MutablePointers?|Pointers?)|VaList))\\b/
      }
    ),
    Prism.languages.swift.string.inside.interpolation.inside.rest = Prism.util.clone(Prism.languages.swift);
    """
  )
]
