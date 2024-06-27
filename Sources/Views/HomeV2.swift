import Dependencies
import PointFreeRouter
import StyleguideV2

public struct Home: HTML {
  @Dependency(\.siteRouter) var siteRouter

  public init() {}

  public var body: some HTML {
    Hero()

    Module(theme: .dark, isSmallTitle: true) {
      Companies()
    } title: {
      Header(6) { "Trusted by teams" }
        .inlineStyle("font-weight", "700")
        .inlineStyle("text-transform", "uppercase")
    }

    Module(theme: .offLight) {
      WhatToExpect()
    } title: {
      Header(2) { "What to expect" }
    }
    
    Module(seeAllRoute: .homeV2, theme: .light) {
      Episodes()
    } title: {
      Header(2) { "What you can expect" }
    }
    
    Module(seeAllRoute: .homeV2, theme: .light) {
      Collections()
    } title: {
      Header(2) { "Collections" }
    }

    Module(theme: .offLight) {
      WhatPeopleAreSaying()
    } title: {
      Header(2) { "What people are saying" }
    }
  }
}

private struct Hero: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
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
  }
}

private struct Companies: HTML {
  var body: some HTML {
    for team in [nytLogoSvg, spotifyLogoSvg, venmoLogoSvg, atlassianLogoSvg] {
      Company(svg: team)
    }
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

private struct WhatToExpect: HTML {
  var body: some HTML {
    for whatToExpect in WhatToExpectItem.all {
      WhatToExpectColumn(item: whatToExpect)
    }
  }

  struct WhatToExpectColumn: HTML {
    let item: WhatToExpectItem
    var body: some HTML {
      GridColumn {
        Image(source: item.imageSrc, description: "")
          .inlineStyle("max-width", "100%")

        Header(4) { HTMLText(item.title) }
        .color(.black)
        .color(.white, media: .dark)
        .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)

        Paragraph {
          HTMLText(item.description)
        }
        .color(.gray300)
        .color(.gray850, media: .dark)
        .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)
      }
      .column(count: 6, media: .desktop)
      .inlineStyle("padding", "0rem 1.5rem 4rem 0", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(even)")
      .inlineStyle("padding", "0rem 0 4rem 1.5rem", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(odd)")
    }
  }
}

private struct Episodes: HTML {
  var body: some HTML {
    "Episodes"
  }
}

private struct Collections: HTML {
  var body: some HTML {
    "Collections"
  }
}

private struct WhatPeopleAreSaying: HTML {
  var body: some HTML {
    for (offset, group) in Testimonial.all.shuffled().prefix(9).grouped(into: 3).enumerated() {
      GridColumn {
        for testimonial in group {
          TestimonialComponent(testimonial: testimonial)
        }
      }
      .inlineStyle("padding-left", "0.5rem", media: MediaQuery.desktop.rawValue, pseudo: "not(:nth-child(2))")
      .inlineStyle("padding-right", "0.5rem", media: MediaQuery.desktop.rawValue, pseudo: "not(:last-child)")
      .column(count: 12)
      .column(count: 4, media: .desktop)
      .inlineStyle("display", offset == 0 ? nil : "none")
      .inlineStyle("display", "block", media: MediaQuery.desktop.rawValue)
    }

    GridColumn {
      Button(color: .purple, size: .regular, style: .normal) {
        "Read more testimonials →"
      }
      .attribute("href", "TODO")
    }
    .column(count: 12)
    .column(alignment: .center)
    .inlineStyle("margin-top", "3rem")
  }

  struct TestimonialComponent: HTML {
    let testimonial: Testimonial

    var body: some HTML {
      a {
        Grid {
          GridColumn {
            Image(source: testimonial.avatarURL ?? "", description: "")
              .size(width: .rem(3), height: .rem(3))
              .inlineStyle("border-radius", "1.5rem")
              .backgroundColor(.gray650)
              .backgroundColor(.gray300, media: .dark)
          }
//          .column(count: 1)
//          .column(count: 2, media: .desktop)
          GridColumn {
            Header(5) {
              HTMLText(testimonial.subscriber ?? "")
            }
            .inlineStyle("margin-bottom", "0")
            Header(6) {
              HTMLText("@" + testimonial.twitterHandle)
            }
            .inlineStyle("font-weight", "normal")
            .inlineStyle("margin-top", "0")
            .color(.gray400)
            .color(.gray650, media: .dark)
          }
//          .column(count: 11)
//          .column(count: 10, media: .desktop)
          .inlineStyle("padding-left", "1rem")
        }
        Paragraph {
          HTMLText(testimonial.quote)
        }
        .inlineStyle("padding-top", "1rem")
      }
      .color(.black)
      .color(.white, media: .dark)
      .attribute("href", testimonial.tweetUrl)
      .grid(alignment: .center)
      .backgroundColor(.offWhite)
      .backgroundColor(.gray150, media: .dark)
      .inlineStyle("text-decoration-line", "none")
      .inlineStyle("display", "block")
      .inlineStyle("border", "1px solid #e8e8e8")
      .inlineStyle("border", "1px solid \(PointFreeColor.gray300.rawValue)", media: MediaQuery.dark.rawValue)
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("padding", "1.5rem")
      .inlineStyle("margin-bottom", "1rem", pseudo: "not(:last-child)")
    }
  }
}

private struct Module<Title: HTML, Content: HTML>: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let title: Title
  var seeAllRoute: SiteRoute?
  var theme: Theme
  var isSmallTitle: Bool
  let content: Content
  init(
    seeAllRoute: SiteRoute? = nil,
    theme: Theme,
    isSmallTitle: Bool = false,
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder title: () -> Title
  ) {
    self.title = title()
    self.seeAllRoute = seeAllRoute
    self.theme = theme
    self.isSmallTitle = isSmallTitle
    self.content = content()
  }

  var body: some HTML {
    div {
      Grid {
        GridColumn {
          title
            .color(theme.color)
            .color(theme.darkModeColor, media: .dark)
        }
        .column(count: seeAllRoute == nil ? 12 : 10)
        .column(alignment: seeAllRoute == nil ? .center : .start)
        .inlineStyle(
          "margin-bottom",
          isSmallTitle ? "2rem"
            : seeAllRoute == nil ? "4rem"
            : "1.5rem"
        )

        if let seeAllRoute {
          GridColumn {
            Link("See all →", href: siteRouter.path(for: seeAllRoute))
              .linkColor(.purple)
          }
          .column(count: 2)
          .column(alignment: .end )
        }

        content
      }
      .grid(alignment: .baseline)
      .inlineStyle("max-width", "1080px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "4rem 2rem")
      .inlineStyle("padding", "4rem 3rem", media: MediaQuery.desktop.rawValue)
    }
    .backgroundColor(theme.backgroundColor)
    .backgroundColor(theme.darkModeBackgroundColor, media: .dark)
  }
}

struct Theme {
  var backgroundColor: PointFreeColor?
  var darkModeBackgroundColor: PointFreeColor?
  var color: PointFreeColor
  var darkModeColor: PointFreeColor
  static let dark = Self(
    backgroundColor: .black,
    darkModeBackgroundColor: .black,
    color: .purple,
    darkModeColor: .purple
  )
  static let light = Self(
    backgroundColor: .white,
    darkModeBackgroundColor: .black,
    color: .black,
    darkModeColor: .white
  )
  static let offLight = Self(
    backgroundColor: .offWhite,
    darkModeBackgroundColor: .offBlack,
    color: .offBlack,
    darkModeColor: .offWhite
  )
}

extension Collection {
  fileprivate func grouped(into numberOfGroups: Int) -> [[Element]] {
    var groups: [[Element]] = []
    for (offset, element) in self.enumerated() {
      let index = offset.quotientAndRemainder(dividingBy: numberOfGroups).remainder
      if index >= groups.count { groups.append([]) }
      groups[index].append(element)
    }
    return groups
  }
}
