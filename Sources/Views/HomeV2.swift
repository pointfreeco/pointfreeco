import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct Home: HTML {
  let allFreeEpisodeCount: Int
  let creditCount: Int
  let clips: [Clip]

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  public init(
    allFreeEpisodeCount: Int,
    creditCount: Int,
    clips: [Clip]
  ) {
    self.allFreeEpisodeCount = allFreeEpisodeCount
    self.creditCount = creditCount
    self.clips = clips
  }

  public var body: some HTML {
    if let currentUser {
      LoggedIn(currentUser: currentUser, creditCount: creditCount, clips: clips)
    } else {
      LoggedOut(allFreeEpisodeCount: allFreeEpisodeCount, clips: clips)
    }
  }
}

private struct LoggedIn: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  let currentUser: User
  let creditCount: Int
  let clips: [Clip]

  var body: some HTML {
    MinimalHero(title: "Welcome back") {
      HTMLGroup {
        span { "Want to see what’s coming up next? " }
        Link("Follow us on Twitter", href: "http://www.twitter.com/pointfreeco")
      }
      .linkUnderline(true)
      .color(.gray800)
    }

    if creditCount > 0 {
      HomeModule(theme: .light) {
        EpisodeCredits(creditCount: creditCount)
      }
    }

    HomeModule(seeAllRoute: .homeV2, theme: .light) {
      Episodes()
    } title: {
      Header(2) { "Episodes" }
    }

//    MinimalHero(title: "Upgrade your plan") {
//      "Access all past and future episodes when you upgrade."
//    }
    HomeModule(theme: .callout) {
      Upgrade()
    }

    if !clips.isEmpty {
      HomeModule(seeAllRoute: .homeV2, theme: .light) {
        Clips(clips: clips)
      } title: {
        Header(2) { "Clips" }
      }
    }

    HomeModule(seeAllRoute: .homeV2, theme: .light) {
      Collections()
    } title: {
      Header(2) { "Collections" }
    }

    if subscriberState.isActiveSubscriber {
      MaximalHero(
        title: "Refer a friend",
        blurb: """
        You'll both get one month free ($18 credit) when they sign up from your personal referral \
        link:
        """
      ) {
        let url = siteRouter.url(
          for: .subscribeConfirmation(
            lane: .personal,
            referralCode: currentUser.referralCode
          )
        )

        Grid {
          GridColumn {
            input {}
              .attribute("value", url)
              .attribute("type", "text")
              .attribute("readonly", "true")
              .attribute("onclick", "this.select();")
              .inlineStyle("width", "100%")
              .inlineStyle("border-radius", "0.5rem")
              .color(.gray500)
              .inlineStyle("padding", "1rem")
              .inlineStyle("border", "none")
              .inlineStyle("outline", "none")
          }
          .flexible()
          .inlineStyle("padding-right", "1rem")

          GridColumn {
            Button(tag: input, color: .purple, size: .regular, style: .normal) {}
              .attribute("type", "button")
              .attribute("value", "Copy")
              .attribute("onclick", """
                navigator.clipboard.writeText("\(url)");
                this.value = "Copied!";
                setTimeout(() => { this.value = "Copy"; }, 3000);
                """)
          }
          .inflexible()
        }
        .grid(alignment: .center)
        .inlineStyle("margin", "2rem 4rem")
      }
    }
  }
}

private struct LoggedOut: HTML {
  let allFreeEpisodeCount: Int
  let clips: [Clip]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    MaximalHero(
      title: "Explore the wonderful world of advanced&nbsp;Swift.",
      blurb: """
          Point-Free is a a video series exploring advanced topics in the \
          Swift&nbsp;programming&nbsp;language, hosted by industry experts, \
          Brandon&nbsp;and&nbsp;Stephen.
          """,
      ctaTitle: "Start with a free episode →",
      ctaURL: siteRouter.loginPath(redirect: .homeV2)
    )

    HomeModule(theme: .dark, isSmallTitle: true) {
      Companies()
    } title: {
      Header(6) { "Trusted by teams" }
        .inlineStyle("font-weight", "700")
        .inlineStyle("text-transform", "uppercase")
    }

    HomeModule(theme: .offLight) {
      WhatToExpect()
    } title: {
      Header(2) { "What to expect" }
    }

    HomeModule(seeAllRoute: .homeV2, theme: .light) {
      Episodes()
    } title: {
      Header(2) { "Episodes" }
    }

    if !clips.isEmpty {
      HomeModule(seeAllRoute: .clips(.clips), theme: .light) {
        Clips(clips: clips)
      } title: {
        Header(2) { "Clips" }
      }
    }

    HomeModule(seeAllRoute: .collections(), theme: .light) {
      Collections()
    } title: {
      Header(2) { "Collections" }
    }

    HomeModule(theme: .offLight) {
      WhatPeopleAreSaying()
    } title: {
      Header(2) { "What people are saying" }
    }

    MaximalHero(
      title: "Get started with our free&nbsp;plan",
      blurb: """
        Our free plan includes 1 subscriber-only episode of your choice, access to \
        \(allFreeEpisodeCount) free episodes with transcripts and code samples, and weekly updates \
        from our newsletter.
        """,
      ctaTitle: "Sign up for free →",
      ctaURL: siteRouter.loginPath(redirect: .homeV2),
      secondaryCTATitle: "View plans and pricing",
      secondaryCTAURL: siteRouter.path(for: .pricingLanding)
    )
  }
}

private struct EpisodeCredits: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let creditCount: Int
  var body: some HTML {
    Grid {
      GridColumn {
        SVG.info
      }
      .inlineStyle("line-height", "0")
      .inflexible()

      GridColumn {
        span { "You have \(creditsLeft) to redeem on any subscriber-only episode of your choice." }
      }
      .flexible()
      .inlineStyle("padding", "0 1rem")

      GridColumn {
        Link("Browse episodes", href: siteRouter.path(for: .home))
          .linkStyle(LinkStyle(color: .black, underline: true))
      }
      .column(alignment: .end)
      .inflexible()
    }
    .grid(alignment: .center)
    .inlineStyle("padding", "1rem")
    .inlineStyle("flex-wrap", "initial")
    .inlineStyle("border-radius", "0.5rem")
    .inlineStyle("width", "100%")
    .backgroundColor(.yellow)
  }
  var creditsLeft: String {
    "\(creditCount) credit\(creditCount == 1 ? "" : "s")"
  }
}

extension SVG {
  static let info = Self(
    base64: base64EncodedString("""
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M10 0C4.48 0 0 4.48 0 10C0 15.52 4.48 20 10 20C15.52 20 20 15.52 20 10C20 4.48 15.52 0 10 0ZM11 15H9V9H11V15ZM11 7H9V5H11V7Z" fill="black"/>
    </svg>
    """),
    description: ""
  )
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
          .color(.black.dark(.offWhite))
          .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)

        Paragraph {
          HTMLText(item.description)
        }
        .color(.gray300.dark(.gray850))
        .inlineStyle("text-align", "center", media: MediaQuery.desktop.rawValue)
      }
      .column(count: 6, media: .desktop)
      .inlineStyle("padding", "0rem 1.5rem 4rem 0", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(even)")
      .inlineStyle("padding", "0rem 0 4rem 1.5rem", media: MediaQuery.desktop.rawValue, pseudo: "nth-child(odd)")
    }
  }
}

private struct Episodes: HTML {
  @Dependency(\.episodes) var episodes

  var body: some HTML {
    Grid {
      for episode in episodes().dropLast(5).suffix(3) {
        EpisodeCard(episode, emergencyMode: false)  // TODO
      }
    }
    .grid(alignment: .stretch)
  }
}

private struct Clips: HTML {
  let clips: [Clip]

  var body: some HTML {
    Grid {
      for clip in clips.prefix(3) {
        ClipCard(clip)
      }
    }
    .grid(alignment: .stretch)
  }
}

private struct Collections: HTML {
  @Dependency(\.collections) var collections

  var body: some HTML {
    Grid {
      for collection in collections.prefix(3) {
        CollectionCard(collection)
      }
    }
    .grid(alignment: .stretch)
  }
}

private struct Upgrade: HTML {
  var body: some HTML {
    "Upgrade"
  }
}

private struct WhatPeopleAreSaying: HTML {
  var body: some HTML {
    for (offset, group) in Testimonial.all.shuffled().prefix(9).grouped(into: 3).enumerated() {
      GridColumn {
        for testimonial in group {
          TestimonialCard(testimonial: testimonial)
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

  struct TestimonialCard: HTML {
    let testimonial: Testimonial

    var body: some HTML {
      a {
        Grid {
          GridColumn {
            Image(source: testimonial.avatarURL ?? "", description: "")
              .size(width: .rem(3), height: .rem(3))
              .inlineStyle("border-radius", "1.5rem")
              .backgroundColor(.gray650.dark(.gray300))
          }

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
            .color(.gray400.dark(.gray400))
          }
          .inlineStyle("padding-left", "1rem")
        }
        Paragraph {
          HTMLText(testimonial.quote)
        }
        .inlineStyle("padding-top", "1rem")
      }
      .color(.black.dark(.white))
      .attribute("href", testimonial.tweetUrl)
      .grid(alignment: .center)
      .backgroundColor(.white.dark(.gray150))
      .inlineStyle("text-decoration-line", "none")
      .inlineStyle("display", "block")
      .inlineStyle("border", "1px solid #e8e8e8")
      .inlineStyle("border", "1px solid #353535", media: MediaQuery.dark.rawValue)
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("padding", "1.5rem")
      .inlineStyle("margin-bottom", "1rem", pseudo: "not(:last-child)")
    }
  }
}

private struct MinimalHero<Blurb: HTML>: HTML {
  var title: String
  @HTMLBuilder var blurb: Blurb

  var body: some HTML {
    Grid {
      GridColumn {
        Header(2) { HTMLText(title) }
          .color(.white)

        Paragraph(.big) { blurb }
          .fontStyle(.body(.regular))
          .color(.gray800)
          .inlineStyle("margin", "0 6rem", media: MediaQuery.desktop.rawValue)
      }
      .column(count: 12)
      .column(alignment: .start)
      .column(alignment: .center, media: .desktop)
      .inlineStyle("margin", "0 auto")
    }
    .grid(alignment: .center)
    .padding(topBottom: .large, leftRight: .medium)
    .padding(.extraLarge, .desktop)
    .inlineStyle("background", "linear-gradient(#121212, #242424)")
  }
}

private struct MaximalHero<PrimaryCTA: HTML>: HTML {
  var title: String
  var blurb: String
  let primaryCTA: PrimaryCTA
  var secondaryCTATitle: String?
  var secondaryCTAURL: String?

  init(
    title: String,
    blurb: String,
    secondaryCTATitle: String? = nil,
    secondaryCTAURL: String? = nil,
    @HTMLBuilder primaryCTA: () -> PrimaryCTA
  ) {
    self.title = title
    self.blurb = blurb
    self.primaryCTA = primaryCTA()
    self.secondaryCTATitle = secondaryCTATitle
    self.secondaryCTAURL = secondaryCTAURL
  }

  init(
    title: String,
    blurb: String,
    ctaTitle: String,
    ctaURL: String,
    secondaryCTATitle: String? = nil,
    secondaryCTAURL: String? = nil
  ) where PrimaryCTA == HTMLInlineStyle<_HTMLAttributes<Button<HTMLText>>> {
    self.title = title
    self.blurb = blurb
    self.primaryCTA = Button(color: .purple, size: .regular, style: .normal) {
      HTMLText(ctaTitle)
    }
    .attribute("href", ctaURL)
    .inlineStyle("display", "inline-block")
    self.secondaryCTATitle = secondaryCTATitle
    self.secondaryCTAURL = secondaryCTAURL
  }

  var body: some HTML {
    Grid {
      GridColumn {
        Header(2) { HTMLRaw(title) }
          .color(.white)

        Paragraph(.big) { HTMLRaw(blurb) }
          .fontStyle(.body(.regular))
          .color(.gray800)
          .inlineStyle("margin", "0 6rem", media: MediaQuery.desktop.rawValue)

        primaryCTA
          .inlineStyle("margin-top", "3rem")
      }
      .column(count: 12)
      .column(alignment: .start)
      .column(alignment: .center, media: .desktop)
      .inlineStyle("margin", "0 auto")

      GridColumn {
        if let secondaryCTAURL, let secondaryCTATitle {
          Link(secondaryCTATitle, href: secondaryCTAURL)
        }
      }
      .column(count: 12)
      .column(alignment: .start)
      .column(alignment: .center, media: .desktop)
      .linkColor(.gray400)
      .fontStyle(.body(.small))
      .inlineStyle("margin-top", "1rem")
      .inlineStyle("text-decoration-line", "underline")
    }
    .grid(alignment: .center)
    .padding(topBottom: .large, leftRight: .medium)
    .padding(.extraLarge, .desktop)
    .inlineStyle("background", "linear-gradient(#121212, #291a40)")
  }
}

private struct HomeModule<Title: HTML, Content: HTML>: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let title: Title?
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
  init(
    seeAllRoute: SiteRoute? = nil,
    theme: Theme,
    isSmallTitle: Bool = false,
    @HTMLBuilder content: () -> Content
  ) where Title == Never {
    self.title = nil
    self.seeAllRoute = seeAllRoute
    self.theme = theme
    self.isSmallTitle = isSmallTitle
    self.content = content()
  }

  var body: some HTML {
    div {
      Grid {
        if let title {
          GridColumn {
            title
              .color(theme.color)
          }
          .column(count: seeAllRoute == nil ? 12 : 10)
          .column(alignment: seeAllRoute == nil ? .center : .start)
          .inlineStyle(
            "margin-bottom",
            isSmallTitle ? "2rem"
            : seeAllRoute == nil ? "4rem"
            : "1.5rem"
          )
        }

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
      .inlineStyle("max-width", "1184px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "4rem 2rem")
      .inlineStyle("padding", "4rem 3rem", media: MediaQuery.desktop.rawValue)
      .backgroundColor(theme.contentBackgroundColor)
    }
    .backgroundColor(theme.backgroundColor)
  }
}

struct Theme {
  var backgroundColor: PointFreeColor?
  var contentBackgroundColor: PointFreeColor?
  var color: PointFreeColor
  static let dark = Self(
    backgroundColor: .black,
    color: .purple
  )
  static let light = Self(
    backgroundColor: .white.dark(.black),
    color: .black.dark(.offWhite)
  )
  static let offLight = Self(
    backgroundColor: .offWhite.dark(.offBlack),
    color: .offBlack.dark(.offWhite)
  )
  static let callout = Self(
    backgroundColor: .white.dark(.black),
    contentBackgroundColor: .init(rawValue: "#fafafa").dark(.init(rawValue: "#050505")),
    color: .purple
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
