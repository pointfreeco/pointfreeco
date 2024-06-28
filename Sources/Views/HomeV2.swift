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
  @Dependency(\.episodeProgresses) var episodeProgresses
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  let currentUser: User
  let creditCount: Int
  let clips: [Clip]

  var body: some HTML {
    PageHeader(title: "Welcome back") {
      HTMLGroup {
        span { "Want to see what’s coming up next? " }
        Link("Follow us on Twitter", href: "http://www.twitter.com/pointfreeco")
          .linkUnderline(true)
      }
      .color(.gray800)
    }

    if creditCount > 0 {
      EpisodeCredits(creditCount: creditCount)
    }

    if !inProgressEpisodes.isEmpty {
      InProgressEpisodes(episodes: Array(inProgressEpisodes))
    }

    if !subscriberState.isActiveSubscriber {
      FreeEpisodes()
      Divider()
    }

    EpisodesModule()

    if !subscriberState.isActive {
      UpgradeModule()
    } else {
      Divider()
    }

    Collections()

    if subscriberState.isActive {
      Gifts()
    } else {
      Divider()
    }

    Clips(clips: clips)
    Divider()
    BlogPosts()

    if subscriberState.isActiveSubscriber {
      ReferAFriend(currentUser: currentUser)
    }
  }

  var inProgressEpisodes: [Episode] {
    Array(
      episodeProgresses.values
        .sorted(by: { ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $0.createdAt) })
        .prefix(while: { $0.percent < 90 })
        .compactMap({ progress in
          episodes().first(where: { $0.sequence == progress.episodeSequence })
        })
        .prefix(3)
    )
  }
}

private struct LoggedOut: HTML {
  let allFreeEpisodeCount: Int
  let clips: [Clip]

  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    MaximalHero(
      title: "Explore the wonderful world of advanced&nbsp;Swift.",
      blurb: """
          Point-Free is a video series exploring advanced topics in the \
          Swift&nbsp;programming&nbsp;language, hosted by industry experts, \
          Brandon&nbsp;and&nbsp;Stephen.
          """,
      ctaTitle: "Start with a free episode →",
      ctaURL: siteRouter.loginPath(redirect: .homeV2)
    )

    Companies()
    WhatToExpect()
    if !subscriberState.isActiveSubscriber {
      FreeEpisodes()
      Divider()
    }
    EpisodesModule()
    Divider()
    Collections()
    if !clips.isEmpty {
      Divider()
      Clips(clips: clips)
    }
    WhatPeopleAreSaying()

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
    HomeModule(theme: .credits) {
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
  }
  var creditsLeft: String {
    "\(creditCount) credit\(creditCount == 1 ? "" : "s")"
  }
}

private struct Companies: HTML {
  var body: some HTML {
    HomeModule(theme: .companies) {
      for team in [nytLogoSvg, spotifyLogoSvg, venmoLogoSvg, atlassianLogoSvg] {
        Company(svg: team)
      }
    } title: {
      Header(6) { "Trusted by teams" }
        .inlineStyle("font-weight", "700")
        .inlineStyle("text-transform", "uppercase")
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
    HomeModule(theme: .informational) {
      for whatToExpect in WhatToExpectItem.all {
        WhatToExpectColumn(item: whatToExpect)
      }
    } title: {
      Header(2) { "What to expect" }
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
          .inlineStyle("text-align", "center", media: .desktop)

        Paragraph {
          HTMLText(item.description)
        }
        .color(.gray300.dark(.gray850))
        .inlineStyle("text-align", "center", media: .desktop)
      }
      .column(count: 6, media: .desktop)
      .inlineStyle("padding", "0rem 1.5rem 4rem 0", media: .desktop, pseudo: .nthChild("even"))
      .inlineStyle("padding", "0rem 0 4rem 1.5rem", media: .desktop, pseudo: .nthChild("odd"))
    }
  }
}

private struct EpisodesModule: HTML {
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .episodes(.list(.all))), theme: .content) {
      Grid {
        let episodes = episodes()
          .suffix(3)
          .reversed()

        for episode in episodes {
          EpisodeCard(episode, emergencyMode: false)  // TODO
        }
      }
      .grid(alignment: .stretch)
    } title: {
      Header(2) { "All episodes" }
    }
  }
}

private struct FreeEpisodes: HTML {
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .episodes(.list(.free))), theme: .content) {
      Grid {
        let episodes = episodes()
          .filter { !$0.isSubscriberOnly(currentDate: now, emergencyMode: false/*TODO*/) }
          .suffix(3)
          .reversed()
        for episode in episodes {
          EpisodeCard(episode, emergencyMode: false)  // TODO
        }
      }
      .grid(alignment: .stretch)
    } title: {
      Header(2) { "Free episodes" }
    }
  }
}

private struct InProgressEpisodes: HTML {
  let episodes: [Episode]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .episodes(.list(.history))), theme: .content) {
      Grid {
        for episode in episodes {
          EpisodeCard(episode, emergencyMode: false)  // TODO
        }
      }
      .grid(alignment: .stretch)
    } title: {
      Header(2) { "Continue watching" }
    }
  }
}

private struct Clips: HTML {
  let clips: [Clip]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .clips(.clips)), theme: .content) {
      Grid {
        for clip in clips.prefix(3) {
          ClipCard(clip)
        }
      }
      .grid(alignment: .stretch)
    } title: {
      Header(2) { "Clips" }
    }
  }
}

private struct BlogPosts: HTML {
  @Dependency(\.blogPosts) var blogPosts
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .blog(.index)), theme: .content) {
      let posts = blogPosts().filter { !$0.hidden.isCurrentlyHidden(date: now) }.suffix(3).reversed()
      ul {
        for post in posts {
          li {
            BlogPost(post: post)
          }
          li {
            Divider()
          }
          .inlineStyle("margin", "2rem 0")
          .inlineStyle("display", "none", pseudo: .lastChild)
        }
      }
      .listStyle(.reset)
    } title: {
      Header(2) { "Newsletter" }
    }
  }

  struct BlogPost: HTML {
    let post: Models.BlogPost
    @Dependency(\.siteRouter) var siteRouter

    var body: some HTML {
      div {
        HTMLText(post.publishedAt.monthDayYear())
      }
      .color(.gray500.dark(.gray650))
      div {
        Header(4) {
          Link(post.title, href: siteRouter.path(for: .blog(.show(.left(post.slug)))))
            .color(.offBlack.dark(.offWhite))
        }
      }
      .inlineStyle("margin-top", "0.5rem")
      div {
        HTMLMarkdown(post.blurb)
      }
      .color(.gray400.dark(.gray650))
    }
  }
}

private struct Collections: HTML {
  @Dependency(\.collections) var collections
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(seeAllURL: siteRouter.path(for: .collections(.index)), theme: .content) {
      Grid {
        for (index, collection) in collections.prefix(3).enumerated() {
          CollectionCard(collection, index: index)
        }
      }
      .grid(alignment: .stretch)
    } title: {
      Header(2) { "Collections" }
    }
  }
}

private struct Gifts: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    HomeModule(theme: .callout) {
      Button(color: .purple, size: .regular, style: .normal) {
        "See gifts options"
      }
      .attribute("href", siteRouter.path(for: .gifts(.index)))
      .inlineStyle("margin", "0 auto")
    } title: {
      GridColumn {
        Header(2) { "Give the gift of Point-Free" }
          .color(.gray150.dark(.gray850))

        Paragraph(.big) {
          "Purchase a gift subscsription of 3, 6 or 12 months for a friend, colleague or loved one."
        }
        .fontStyle(.body(.regular))
        .color(.gray300.dark(.gray800))
        .inlineStyle("margin", "0 6rem", media: .desktop)
      }
      .inlineStyle("text-align", "start", media: .mobile)
    }
  }
}

private struct ReferAFriend: HTML {
  let currentUser: User

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
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
        .inlineStyle("max-width", "60%", media: .desktop)

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
      .inlineStyle("justify-content", "center")
      .inlineStyle("margin", "2rem 4rem")
    }
  }
}

private struct WhatPeopleAreSaying: HTML {
  var body: some HTML {
    HomeModule(theme: .informational) {
      for (offset, group) in Testimonial.all.shuffled().prefix(9).grouped(into: 3).enumerated() {
        GridColumn {
          for testimonial in group {
            TestimonialCard(testimonial: testimonial)
          }
        }
        .inlineStyle("padding-left", "0.5rem", media: .desktop, pseudo: .not(.nthChild("2")))
        .inlineStyle("padding-right", "0.5rem", media: .desktop, pseudo: .not(.lastChild))
        .column(count: 12)
        .column(count: 4, media: .desktop)
        .inlineStyle("display", offset == 0 ? nil : "none")
        .inlineStyle("display", "block", media: .desktop)
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
    } title: {
      Header(2) { "What people are saying" }
    }
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
      .inlineStyle("border", "1px solid #353535", media: .dark)
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("padding", "1.5rem")
      .inlineStyle("margin-bottom", "1rem", pseudo: .not(.lastChild))
    }
  }
}

private struct Divider: HTML {
  var body: some HTML {
    div {}
      .backgroundColor(.gray800.dark(.gray300))
      .inlineStyle("margin", "0 30%")
      .inlineStyle("height", "1px")
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
          .inlineStyle("margin", "0 6rem", media: .desktop)

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

extension PageModuleTheme {
  static let credits = Self(
    backgroundColor: .white.dark(.black),
    color: .black.dark(.offWhite),
    topMargin: 2,
    bottomMargin: 0,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 3
  )

  static let content = Self(
    backgroundColor: .white.dark(.black),
    color: .black.dark(.offWhite),
    topMargin: 4,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 3
  )

  static let callout = Self(
    backgroundColor: .white.dark(.black),
    contentBackgroundColor: .init(rawValue: "#fafafa").dark(.init(rawValue: "#050505")),
    color: .offBlack.dark(.offWhite),
    topMargin: 4,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 3
  )

  static let informational = Self(
    backgroundColor: .offWhite.dark(.offBlack),
    color: .offBlack.dark(.offWhite),
    topMargin: 4,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 3
  )

  static let companies = Self(
    backgroundColor: .black,
    color: .purple,
    topMargin: 4,
    bottomMargin: 4,
    leftRightMargin: 2,
    leftRightMarginDesktop: 3,
    titleMarginBottom: 2
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
