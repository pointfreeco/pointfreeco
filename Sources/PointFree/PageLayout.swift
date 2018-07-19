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
  case mountains(MountainsStyle)

  enum MinimalStyle {
    case dark
    case light
  }

  enum MountainsStyle {
    case blog
    case main

    var heroTagline: String {
      switch self {
      case .blog:   return "A blog exploring functional programming and Swift."
      case .main:   return "A new Swift video series exploring functional programming and more."
      }
    }

    var heroLogoSvgBase64: String {
      switch self {
      case .blog:   return pointFreePointersLogoSvgBase64
      case .main:   return pointFreeHeroSvgBase64
      }
    }
  }
}

struct SimplePageLayoutData<A> {
  enum Style {
    case minimal
    case base(NavStyle?)

    var isMinimal: Bool {
      guard case .minimal = self else { return false }
      return true
    }
  }

  private(set) var currentRoute: Route?
  private(set) var currentSubscriberState: SubscriberState
  private(set) var currentUser: Database.User?
  private(set) var data: A
  private(set) var description: String?
  private(set) var extraStyles: Stylesheet
  private(set) var flash: Flash?
  private(set) var image: String?
  private(set) var openGraphType: OpenGraphType
  private(set) var style: Style
  private(set) var title: String
  private(set) var twitterCard: TwitterCard
  private(set) var usePrismJs: Bool

  init(
    currentRoute: Route? = nil,
    currentSubscriberState: SubscriberState = .nonSubscriber,
    currentUser: Database.User?,
    data: A,
    description: String? = nil,
    extraStyles: Stylesheet = .empty,
    image: String? = nil,
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
    self.extraStyles = extraStyles
    self.flash = nil
    self.image = image
    self.openGraphType = openGraphType
    self.style = style
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
        >=> respond(
          body: pageLayout.rendered(
            with: newLayoutData,
            config: Current.envVars.appEnv == .production ? .compact : .pretty
          ),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(_ contentView: View<A>) -> View<SimplePageLayoutData<A>> {
  let cssConfig: Css.Config = Current.envVars.appEnv == .production ? .compact : .pretty
  return View { layoutData in
    document([
      html([
        head([
          meta([charset(.utf8)]),
          title(layoutData.title),
          style(renderedNormalizeCss),
          style(styleguide, config: cssConfig),
          style(layoutData.extraStyles, config: cssConfig),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          link([
            href(url(to: .feed(.atom))),
            rel(.alternate),
            title("Point-Free Episodes"),
            type(.application(.atom)),
            ]),
          link([
            href(url(to: .blog(.feed(.atom)))),
            rel(.alternate),
            title("Point-Free Blog"),
            type(.application(.atom)),
            ])
          ]
          <> (layoutData.usePrismJs ? prismJsHead : [])
          <> favicons
        ),
        body(
          pastDueBanner(layoutData)
            <> (layoutData.flash.map(flashView.view) ?? [])
            <> navView(layoutData)
            <> contentView.view(layoutData.data)
            <> (layoutData.style.isMinimal ? [] : footerView.view(layoutData.currentUser))
        )
        ])
      ])
  }
}

func pastDueBanner<A>(_ data: SimplePageLayoutData<A>) -> [Node] {
  guard data.currentSubscriberState.isPastDue else { return [] }

  // TODO: custom messages for owner vs teammate

  return flashView.view(
    .init(
      priority: .warning,
      message: """
      Your subscription is past-due! Please
      [update your payment info](\(path(to: .account(.paymentInfo(.show(expand: nil)))))) to ensure access to
      Point-Free!
      """
    )
  )
}

private func navView<A>(_ data: SimplePageLayoutData<A>) -> [Node] {

  switch data.style {
  case let .base(.some(.mountains(style))):
    return mountainNavView.view((style, data.currentUser, data.currentSubscriberState, data.currentRoute))

  case let .base(.some(.minimal(minimalStyle))):
    return minimalNavView.view((minimalStyle, data.currentUser, data.currentSubscriberState, data.currentRoute))

  case .base(.none), .minimal:
    return []
  }
}

let flashView = View<Flash> { flash in
  gridRow([`class`([flashClass(for: flash.priority)])], [
    gridColumn(sizes: [.mobile: 12], [markdownBlock(flash.message)])
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

private let favicons: [ChildOf<Element.Head>] = [
  link([rel(.value("apple-touch-icon")), sizes("180x180"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/apple-touch-icon.png")]),
  link([rel(.value("icon")), type(.png), sizes("32x32"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-32x32.png")]),
  link([rel(.value("icon")), type(.png), sizes("16x16"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-16x16.png")]),
  link([rel(.value("manifest")), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/site.webmanifest")]),
  link([rel(.value("mask-icon")), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/safari-pinned-tab.svg")]),
]

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
