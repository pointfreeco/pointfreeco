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
import View

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
  private(set) var extraHead: [ChildOf<Tag.Head>]
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
    description: String? = "Point-Free is a video series exploring functional programming and Swift.",
    extraHead: [ChildOf<Tag.Head>] = [],
    extraStyles: Stylesheet = .empty,
    image: String? = "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
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
          body: Current.renderHtml(pageLayout.view(newLayoutData)),
          contentType: .html
      )
    }
}

func simplePageLayout<A>(_ contentView: View<A>) -> View<SimplePageLayoutData<A>> {
  let cssConfig: Css.Config = Current.envVars.appEnv == .testing ? .pretty : .compact
  return View { layoutData -> [Node] in

    let hasPodcastRssFeature = Current.features.hasAccess(to: .podcastRss, for: layoutData.currentUser)
    let blogAtomFeed = Html.link([
      href(url(to: .blog(.feed))),
      rel(.alternate),
      title("Point-Free Blog"),
      type(.application(.atom)),
      ])

    let episodeAtomFeed = Html.link([
      hasPodcastRssFeature
        ? href(url(to: .feed(.episodes)))
        : href(url(to: .feed(.atom))),
      rel(.alternate),
      title("Point-Free Episodes"),
      type(.application(.atom)),
      ])

    return [
      doctype,
      html([lang(.en)], [
        head([
          meta([charset(.utf8)]),
          title(layoutData.title),
          style(unsafe: renderedNormalizeCss),
          style(styleguide, config: cssConfig),
          style(layoutData.extraStyles, config: cssConfig),
          meta(viewport: .width(.deviceWidth), .initialScale(1)),
          episodeAtomFeed,
          blogAtomFeed,
          ]
          <> (layoutData.usePrismJs ? prismJsHead : [])
          <> favicons
          <> layoutData.extraHead
        ),
        body(
          pastDueBanner(layoutData)
            <> (layoutData.flash.map(flashView.view) ?? [])
            <> navView(layoutData)
            <> contentView.view(layoutData.data)
            <> (layoutData.style.isMinimal ? [] : footerView.view(layoutData.currentUser))
        )
        ])
    ]
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

private let favicons: [ChildOf<Tag.Head>] = [
  link([rel(.init(rawValue: "apple-touch-icon")), .init("sizes", "180x180"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/apple-touch-icon.png")]),
  link([rel(.init(rawValue: "icon")), type(.png), .init("sizes", "32x32"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-32x32.png")]),
  link([rel(.init(rawValue: "icon")), type(.png), .init("sizes", "16x16"), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/favicon-16x16.png")]),
  link([rel(.init(rawValue: "manifest")), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/site.webmanifest")]),
  link([rel(.init(rawValue: "mask-icon")), href("https://d3rccdn33rt8ze.cloudfront.net/favicons/safari-pinned-tab.svg")]),
]

private let prismJsHead: [ChildOf<Tag.Head>] = [
  style(unsafe: """
.language-diff .token.inserted {
  background-color: #f0fff4;
  color: #22863a;
}

.language-diff .token.deleted {
  background-color: #ffeef0;
  color: #b31d28;
}
"""),
  script([src("//cdnjs.cloudflare.com/ajax/libs/prism/1.10.0/prism.min.js")]),
  script(
    """
    Prism.languages.swift=Prism.languages.extend("clike",{string:{pattern:/("|')(\\\\(?:\\((?:[^()]|\\([^)]+\\))+\\)|\\r\\n|[\\s\\S])|(?!\\1)[^\\\\\\r\\n])*\\1/,greedy:!0,inside:{interpolation:{pattern:/\\\\\\((?:[^()]|\\([^)]+\\))+\\)/,inside:{delimiter:{pattern:/^\\\\\\(|\\)$/,alias:"variable"}}}}},keyword:/\\b(?:as|associativity|break|case|catch|class|continue|convenience|default|defer|deinit|didSet|do|dynamic(?:Type)?|else|enum|extension|fallthrough|final|for|func|get|guard|if|import|in|infix|init|inout|internal|is|lazy|left|let|mutating|new|none|nonmutating|operator|optional|override|postfix|precedence|prefix|private|protocol|public|repeat|required|rethrows|return|right|safe|self|Self|set|static|struct|subscript|super|switch|throws?|try|Type|typealias|unowned|unsafe|var|weak|where|while|willSet|__(?:COLUMN__|FILE__|FUNCTION__|LINE__))\\b/,number:/\\b(?:[\\d_]+(?:\\.[\\de_]+)?|0x[a-f0-9_]+(?:\\.[a-f0-9p_]+)?|0b[01_]+|0o[0-7_]+)\\b/i,constant:/\\b(?:nil|[A-Z_]{2,}|k[A-Z][A-Za-z_]+)\\b/,atrule:/@\\b(?:IB(?:Outlet|Designable|Action|Inspectable)|class_protocol|exported|noreturn|NS(?:Copying|Managed)|objc|UIApplicationMain|auto_closure)\\b/,builtin:/\\b(?:[A-Z]\\S+|abs|advance|alignof(?:Value)?|assert|contains|count(?:Elements)?|debugPrint(?:ln)?|distance|drop(?:First|Last)|dump|enumerate|equal|filter|find|first|getVaList|indices|isEmpty|join|last|lexicographicalCompare|map|max(?:Element)?|min(?:Element)?|numericCast|overlaps|partition|print(?:ln)?|reduce|reflect|reverse|sizeof(?:Value)?|sort(?:ed)?|split|startsWith|stride(?:of(?:Value)?)?|suffix|swap|toDebugString|toString|transcode|underestimateCount|unsafeBitCast|with(?:ExtendedLifetime|Unsafe(?:MutablePointers?|Pointers?)|VaList))\\b/}),Prism.languages.swift.string.inside.interpolation.inside.rest=Prism.languages.swift;
    Prism.languages.diff={coord:[/^(?:\\*{3}|-{3}|\\+{3}).*$/m,/^@@.*@@$/m,/^\\d+.*$/m],deleted:/^[-<].*$/m,inserted:/^[+>].*$/m,diff:{pattern:/^!(?!!).+$/m,alias:"important"}};
    Prism.languages.markup={comment:/<!--[\\s\\S]*?-->/,prolog:/<\\?[\\s\\S]+?\\?>/,doctype:/<!DOCTYPE[\\s\\S]+?>/i,cdata:/<!\\[CDATA\\[[\\s\\S]*?]]>/i,tag:{pattern:/<\\/?(?!\\d)[^\\s>\\/=$<%]+(?:\\s+[^\\s>\\/=]+(?:=(?:("|')(?:\\\\[\\s\\S]|(?!\\1)[^\\\\])*\\1|[^\\s'">=]+))?)*\\s*\\/?>/i,greedy:!0,inside:{tag:{pattern:/^<\\/?[^\\s>\\/]+/i,inside:{punctuation:/^<\\/?/,namespace:/^[^\\s>\\/:]+:/}},"attr-value":{pattern:/=(?:("|')(?:\\\\[\\s\\S]|(?!\\1)[^\\\\])*\\1|[^\\s'">=]+)/i,inside:{punctuation:[/^=/,{pattern:/(^|[^\\\\])["']/,lookbehind:!0}]}},punctuation:/\\/?>/,"attr-name":{pattern:/[^\\s>\\/]+/,inside:{namespace:/^[^\\s>\\/:]+:/}}}},entity:/&#?[\\da-z]{1,8};/i},Prism.languages.markup.tag.inside["attr-value"].inside.entity=Prism.languages.markup.entity,Prism.hooks.add("wrap",function(a){"entity"===a.type&&(a.attributes.title=a.content.replace(/&amp;/,"&"))}),Prism.languages.xml=Prism.languages.markup,Prism.languages.html=Prism.languages.markup,Prism.languages.mathml=Prism.languages.markup,Prism.languages.svg=Prism.languages.markup;
    Prism.languages.css={comment:/\\/\\*[\\s\\S]*?\\*\\//,atrule:{pattern:/@[\\w-]+?.*?(?:;|(?=\\s*\\{))/i,inside:{rule:/@[\\w-]+/}},url:/url\\((?:(["'])(?:\\\\(?:\\r\\n|[\\s\\S])|(?!\\1)[^\\\\\\r\\n])*\\1|.*?)\\)/i,selector:/[^{}\\s][^{};]*?(?=\\s*\\{)/,string:{pattern:/("|')(?:\\\\(?:\\r\\n|[\\s\\S])|(?!\\1)[^\\\\\\r\\n])*\\1/,greedy:!0},property:/[-_a-z\\xA0-\\uFFFF][-\\w\\xA0-\\uFFFF]*(?=\\s*:)/i,important:/!important\\b/i,"function":/[-a-z0-9]+(?=\\()/i,punctuation:/[(){};:]/},Prism.languages.css.atrule.inside.rest=Prism.languages.css,Prism.languages.markup&&(Prism.languages.insertBefore("markup","tag",{style:{pattern:/(<style[\\s\\S]*?>)[\\s\\S]*?(?=<\\/style>)/i,lookbehind:!0,inside:Prism.languages.css,alias:"language-css",greedy:!0}}),Prism.languages.insertBefore("inside","attr-value",{"style-attr":{pattern:/\\s*style=("|')(?:\\\\[\\s\\S]|(?!\\1)[^\\\\])*\\1/i,inside:{"attr-name":{pattern:/^\\s*style/i,inside:Prism.languages.markup.tag.inside},punctuation:/^\\s*=\\s*['"]|['"]\\s*$/,"attr-value":{pattern:/.+/i,inside:Prism.languages.css}},alias:"language-css"}},Prism.languages.markup.tag));
    Prism.languages.clike={comment:[{pattern:/(^|[^\\\\])\\/\\*[\\s\\S]*?(?:\\*\\/|$)/,lookbehind:!0},{pattern:/(^|[^\\\\:])\\/\\/.*/,lookbehind:!0,greedy:!0}],string:{pattern:/(["'])(?:\\\\(?:\\r\\n|[\\s\\S])|(?!\\1)[^\\\\\\r\\n])*\\1/,greedy:!0},"class-name":{pattern:/((?:\\b(?:class|interface|extends|implements|trait|instanceof|new)\\s+)|(?:catch\\s+\\())[\\w.\\\\]+/i,lookbehind:!0,inside:{punctuation:/[.\\\\]/}},keyword:/\\b(?:if|else|while|do|for|return|in|instanceof|function|new|try|throw|catch|finally|null|break|continue)\\b/,"boolean":/\\b(?:true|false)\\b/,"function":/\\w+(?=\\()/,number:/\\b0x[\\da-f]+\\b|(?:\\b\\d+\\.?\\d*|\\B\\.\\d+)(?:e[+-]?\\d+)?/i,operator:/--?|\\+\\+?|!=?=?|<=?|>=?|==?=?|&&?|\\|\\|?|\\?|\\*|\\/|~|\\^|%/,punctuation:/[{}[\\];(),.:]/};
    """
  )
]
