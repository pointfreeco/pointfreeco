import StyleguideV2
import Dependencies
import PointFreeRouter

public struct Home: HTML {
  @Dependency(\.siteRouter) var siteRouter

  public init () {}

  public var body: some HTML {
    Grid {
      GridColumn {
        Header(2) { "Explore the wonderful world of advanced&nbsp;Swift." }
          .color(.white)

        Paragraph(.big) {
            """
            Point-Free is a a video series exploring advanced topics in the Swift&nbsp;\
            programming&nbsp;language.
            """
        }
        .fontStyle(.body(.regular))
        .color(.gray800)
        .inlineStyle("margin", "0 3rem", media: MediaQuery.desktop.rawValue)

        Button(color: .purple, size: .regular, style: .normal) {
          "Start with a free episode →"
        }
        .attribute("href", siteRouter.loginPath(redirect: .homeV2))
        .inlineStyle("margin-top", "3rem")
        .inlineStyle("display", "inline-block")
      }
      .column(count: 12)
      .column(alignment: .start)
      .column(alignment: .center, media: .desktop)
      .inlineStyle("margin", "0 auto")
    }
    .grid(alignment: .center)
    .padding(topBottom: .large, leftRight: .medium)
    .padding(.extraLarge, .desktop)
    .inlineStyle("background", "linear-gradient(#121212, #291a40)")

    Companies()
    Module(theme: .offLight) {
      WhatToExpect()
    } title: {
      Header(2) { "What you can expect" }
    }
    Module(seeAllRoute: .homeV2, theme: .light) {
      Episodes()
    } title: {
      Header(2) { "What you can expect" }
    }
    Module(seeAllRoute: .homeV2, theme: .offLight) {
      Collections()
    } title: {
      Header(2) { "Collections" }
    }
    Module(theme: .light) {
      WhatPeopleAreSaying()
    } title: {
      Header(2) { "What people are saying" }
    }
  }
}

struct Companies: HTML {
  var body: some HTML {
    div {
      Grid {
        GridColumn {
          Header(6) { "Trusted by teams" }
            .inlineStyle("font-weight", "700")
            .inlineStyle("text-transform", "uppercase")
            .color(.purple)
        }
        .column(count: 12)
        .column(alignment: .center)
        .inlineStyle("margin", "0 0 2rem 0")

        for team in [nytLogoSvg, spotifyLogoSvg, venmoLogoSvg, atlassianLogoSvg] {
          Company(svg: team)
        }
      }
      .inlineStyle("max-width", "1080px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "4rem", media: MediaQuery.desktop.rawValue)
    }
    .grid(alignment: .center)
    .backgroundColor(.black)
  }

  struct Company: HTML {
    let svg: String
    var body: some HTML {
      GridColumn {
        SVG(base64: svg, description: "")
      }
      .column(alignment: .center)
      .column(count: 6)
      .column(count: 3, media: .desktop)
      .inlineStyle("padding", "1rem")
    }
  }
}

struct WhatToExpect: HTML {
  var body: some HTML {
    for whatToExpect in WhatToExpectItem.all {
      WhatToExpectColumn(item: whatToExpect)
    }
  }

  struct WhatToExpectColumn: HTML {
    let item: WhatToExpectItem
    var body: some HTML {
      GridColumn {
        Header(4) { item.title }
        .color(.black)
        .color(.white, media: .dark)
        .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)

        Paragraph {
          item.description
        }
        .color(.gray300)
        .color(.gray850, media: .dark)
        .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)
      }
      .column(count: 6, media: .desktop)
      .inlineStyle("padding", "0rem 1rem 4rem 2rem", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(even)")
      .inlineStyle("padding", "0rem 2rem 4rem 1rem", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(odd)")
      .inlineStyle("padding", "0rem 2rem 3rem 2rem")
    }
  }
}

struct Episodes: HTML {
  var body: some HTML {
    "Episodes"
  }
}

struct Collections: HTML {
  var body: some HTML {
    "Collections"
  }
}

struct WhatPeopleAreSaying: HTML {
  var body: some HTML {
    "Testimonials"
  }
}

private struct Module<Title: HTML, Content: HTML>: HTML {
  let title: Title
  var seeAllRoute: SiteRoute?
  var theme: Theme
  let content: Content
  init(
    seeAllRoute: SiteRoute? = nil,
    theme: Theme,
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder title: () -> Title
  ) {
    self.title = title()
    self.seeAllRoute = seeAllRoute
    self.theme = theme
    self.content = content()
  }

  enum Theme {
    case dark
    case light
    case offLight
    var backgroundColor: PointFreeColor {
      switch self {
      case .dark: .black
      case .light: .white
      case .offLight: .offWhite
      }
    }
    var darkModeBackgroundColor: PointFreeColor {
      switch self {
      case .dark: .black
      case .light: .black
      case .offLight: .offBlack
      }
    }
    var color: PointFreeColor {
      switch self {
      case .dark: .purple
      case .light: .black
      case .offLight: .black
      }
    }
    var darkModeColor: PointFreeColor {
      switch self {
      case .dark: .purple
      case .light: .white
      case .offLight: .white
      }
    }
  }

  var body: some HTML {
    div {
      Grid {
        GridColumn {
          title
            .color(theme.color)
            .color(theme.darkModeColor, media: .dark)
        }
        .column(count: 12)
        .column(alignment: .center)
        .inlineStyle("margin", "4rem 0rem")

        content
      }
      .grid(alignment: .start)
      .inlineStyle("max-width", "1080px")
      .inlineStyle("margin", "0 auto")
    }
    .backgroundColor(theme.backgroundColor)
    .backgroundColor(theme.darkModeBackgroundColor, media: .dark)
  }
}
