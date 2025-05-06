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
      Divider()
    }
    if !subscriberState.isActiveSubscriber {
      FreeEpisodes()
      Divider()
    }
    EpisodesModule()
    if subscriberState.isActiveSubscriber {
      GiveAGiftModule()
    } else {
      UpgradeModule()
    }
    CollectionsModule()
    Divider()
    Clips(clips: clips)
    Divider()
    BlogPosts()
    ReferAFriend(currentUser: currentUser)
  }

  var inProgressEpisodes: [Episode] {
    Array(
      episodeProgresses.values
        .sorted(by: { ($0.updatedAt ?? $0.createdAt) > ($1.updatedAt ?? $1.createdAt) })
        .lazy
        .filter({ !$0.isFinished })
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

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CallToActionHeader(
      title: "Explore the wonderful world of advanced Swift.",
      blurb: """
        Point-Free is a video series exploring advanced topics in the Swift programming language, \
        hosted by industry experts, Brandon and Stephen.
        """,
      ctaTitle: "Start with a free episode →",
      ctaURL: siteRouter.path(for: .auth(.signUp(redirect: nil))),
      style: .gradient
    )
    Companies()
    FreeEpisodes()
    Divider()
    EpisodesModule()
    WhatToExpect()
    CollectionsModule()
    if !clips.isEmpty {
      Divider()
      Clips(clips: clips)
    }
    WhatPeopleAreSaying()
    GetStartedModule(style: .gradient)
  }
}

private struct EpisodeCredits: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let creditCount: Int
  var body: some HTML {
    PageModule(theme: .credits) {
      HStack(alignment: .center, spacing: 0) {
        VStack {
          SVG.info
        }
        .inlineStyle("line-height", "0")

        span {
          "You have \(creditsLeft) to redeem on any subscriber-only episode of your choice."
        }
        .grow()
        .inlineStyle("padding", "0 1rem")

        VStack(alignment: .trailing) {
          Link("Browse episodes", href: siteRouter.path(for: .home))
            .linkStyle(LinkStyle(color: .black, underline: true))
        }
      }
      .inlineStyle("padding", "1rem")
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("width", "100%")
      .backgroundColor(.yellow)
    }
  }
  var creditsLeft: String {
    "\(creditCount) credit\(creditCount == 1 ? "" : "s")"
  }
}

struct Companies: HTML {
  var body: some HTML {
    PageModule(theme: .companies) {
      div {
        for team in shuffledTeams.prefix(7) {
          Company(svg: team)
            .inlineStyle("display", "none", media: .mobile, pseudo: .lastChild)
        }
      }
      .flexContainer(wrap: "wrap", justification: "center", itemAlignment: "center")
    } title: {
      Header(6) { "Trusted by teams" }
        .inlineStyle("font-weight", "700")
        .inlineStyle("text-transform", "uppercase")
    }
  }

  private var shuffledTeams: [String] {
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

    return withRandomNumberGenerator {
      [
        bookingLogoSVG,
        jpMorganLogoSVG,
        insuletLogoSVG,
        noomLogoSVG,
        shutterflyLogoSVG,
        targetLogoSVG,
        nytLogoSVG,
        spotifyLogoSVG,
        venmoLogoSVG,
        atlassianLogoSVG,
        hyundaiLogoSVG,
        twitchLogoSVG,
        appleLogoSVG,
        fordLogoSVG,
        squarespaceLogoSVG,
        doximityLogoSVG,
        foxLogoSVG,
      ]
      .shuffled(using: &$0)
    }
  }

  struct Company: HTML {
    let svg: String
    var body: some HTML {
      VStack(alignment: .center) {
        SVG(base64: svg, description: "")
          .inlineStyle("width", "100px")
          .inlineStyle("height", "60px")
          .inlineStyle("width", "140px", media: .desktop)
          .inlineStyle("height", "60px", media: .desktop)
          .inlineStyle("object-fit", "contain")
      }
      .flexItem(basis: "50%")
      .flexItem(basis: "25%", media: .desktop)
      .inlineStyle("padding", "1rem")
    }
  }
}

struct WhatToExpect: HTML {
  var body: some HTML {
    PageModule(title: "What to expect", theme: .informational) {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        for whatToExpect in WhatToExpectItem.all {
          WhatToExpectColumn(item: whatToExpect)
        }
      }
    }
  }

  struct WhatToExpectColumn: HTML {
    let item: WhatToExpectItem
    var body: some HTML {
      VStack(alignment: .center) {
        Image(source: item.imageSrc, description: "")
          .attribute("loading", "lazy")
          .inlineStyle("padding", "2.5%")
          .inlineStyle("padding", "7.5%", media: .desktop)
          .inlineStyle("max-width", "100%")

        div {
          Header(4) { HTMLText(item.title) }
            .color(.black.dark(.offWhite))
            .inlineStyle("text-align", "center", media: .desktop)
        }

        Paragraph {
          HTMLText(item.description)
        }
        .color(.gray300.dark(.gray850))
        .inlineStyle("text-align", "center", media: .desktop)
      }
      .inlineStyle("padding", "0rem 1.5rem 4rem 0", media: .desktop, pseudo: .nthChild("even"))
      .inlineStyle("padding", "0rem 0 4rem 1.5rem", media: .desktop, pseudo: .nthChild("odd"))
    }
  }
}

private struct EpisodesModule: HTML {
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(
      title: "All episodes",
      seeAllURL: siteRouter.path(for: .episodes(.list(.all))),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        let episodes = episodes()
          .suffix(3)
          .reversed()

        for episode in episodes {
          EpisodeCard(episode)
        }
      }
    }
  }
}

private struct FreeEpisodes: HTML {
  @Dependency(\.episodes) var episodes
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(
      title: "Free episodes",
      seeAllURL: siteRouter.path(for: .episodes(.list(.free))),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        let episodes = episodes()
          .filter { !$0.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) }
          .suffix(3)
          .reversed()

        for episode in episodes {
          EpisodeCard(episode)
        }
      }
    }
  }
}

private struct InProgressEpisodes: HTML {
  let episodes: [Episode]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(
      title: "Continue watching",
      seeAllURL: siteRouter.path(for: .episodes(.list(.history))),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        for episode in episodes {
          EpisodeCard(episode)
        }
      }
    }
  }
}

private struct Clips: HTML {
  let clips: [Clip]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(
      title: "Clips",
      seeAllURL: siteRouter.path(for: .clips(.clips)),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        for clip in clips.prefix(3) {
          ClipCard(clip)
        }
      }
    }
  }
}

private struct CollectionsModule: HTML {
  @Dependency(\.siteRouter) var siteRouter
  let collections: [Episode.Collection]

  init() {
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
    collections = Array(
      withRandomNumberGenerator {
        [
          .swiftUI,
          .backToBasics,
          .composableArchitecture,
          .sqlite,
          .concurrency,
          .uiKit,
          .macros,
          .modernPersistence,
        ]
        .shuffled(using: &$0)
        .prefix(3)
      }
    )
  }

  var body: some HTML {
    PageModule(
      title: "Collections",
      seeAllURL: siteRouter.path(for: .collections(.index)),
      theme: .content
    ) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        for (index, collection) in collections.enumerated() {
          CollectionCard(collection, index: index)
        }
      }
    }
  }
}

private struct ReferAFriend: HTML {
  let currentUser: User

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    if currentUserCanReferOthers {
      CallToActionHeader(
        title: "Refer a friend",
        blurb: """
          You'll both get one month free ($18 credit) when they sign up from your personal referral \
          link:
          """,
        style: .gradient
      ) {
        let url = siteRouter.url(
          for: .subscribeConfirmation(
            lane: .personal,
            referralCode: currentUser.referralCode
          )
        )
        .dropHTTPWWW

        HStack(alignment: .center) {
          input()
            .color(.gray500)
            .grow()
            .attribute("onclick", "this.select();")
            .attribute("readonly")
            .attribute("type", "text")
            .attribute("value", url)
            .inlineStyle("border", "none")
            .inlineStyle("border-radius", "0.5rem")
            .inlineStyle("outline", "none")
            .inlineStyle("padding", "1rem")
            .inlineStyle("max-width", "60%", media: .desktop)
            .inlineStyle("width", "100%")

          Button(tag: input, color: .purple, size: .regular, style: .normal)
            .attribute("type", "button")
            .attribute("value", "Copy")
            .attribute(
              "onclick",
              """
              navigator.clipboard.writeText("\(url)");
              this.value = "Copied!";
              setTimeout(() => { this.value = "Copy"; }, 3000);
              """
            )
        }
        .inlineStyle("justify-content", "center")
        .inlineStyle("margin", "2rem 0 0 0")
      }
    }
  }
}

extension String {
  var dropHTTPWWW: String {
    var copy = self
    if copy.hasPrefix("https://") {
      copy.removeFirst(8)
    } else if copy.hasPrefix("http://") {
      copy.removeFirst(7)
    }
    if copy.hasPrefix("www.") {
      copy.removeFirst(4)
    }
    return copy
  }
}

struct WhatPeopleAreSaying: HTML {
  var body: some HTML {
    PageModule(
      title: "What people are saying",
      theme: .informational
    ) {
      VStack(alignment: .center, spacing: 3) {
        LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
          for (offset, group) in shuffledTestimonials.prefix(9).grouped(into: 3).enumerated() {
            VStack {
              for testimonial in group {
                TestimonialCard(testimonial: testimonial)
              }
            }
            .inlineStyle("display", offset == 0 ? nil : "none")
            .inlineStyle("display", "block", media: .desktop)
          }
        }

        // Button(color: .purple, size: .regular, style: .normal) {
        //   "Read more testimonials →"
        // }
        // .attribute("href", "TODO")
      }
    }
  }

  private var shuffledTestimonials: [Testimonial] {
    @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator

    return withRandomNumberGenerator {
      Testimonial.all.shuffled(using: &$0)
    }
  }

  struct TestimonialCard: HTML {
    let testimonial: Testimonial

    var body: some HTML {
      a {
        VStack {
          HStack(alignment: .center) {
            Image(source: testimonial.avatarURL ?? "", description: "")
              .attribute("loading", "lazy")
              .size(width: .rem(3), height: .rem(3))
              .inlineStyle("border-radius", "1.5rem")
              .backgroundColor(.gray650.dark(.gray300))

            VStack(spacing: 0) {
              div {
                Header(5) {
                  HTMLText(testimonial.subscriber ?? "")
                }
              }

              div {
                Header(6) {
                  HTMLText("@" + testimonial.twitterHandle)
                }
              }
              .inlineStyle("font-weight", "normal")
              .inlineStyle("margin-top", "0")
              .color(.gray400.dark(.gray400))
            }
          }

          Paragraph {
            HTMLText(testimonial.quote)
          }
        }
      }
      .color(.black.dark(.white))
      .attribute("href", testimonial.tweetUrl)
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
    titleMarginBottom: 2,
    gridJustification: "space-evenly"
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
    base64: base64EncodedString(
      """
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M10 0C4.48 0 0 4.48 0 10C0 15.52 4.48 20 10 20C15.52 20 20 15.52 20 10C20 4.48 15.52 0 10 0ZM11 15H9V9H11V15ZM11 7H9V5H11V7Z" fill="black"/>
      </svg>
      """
    ),
    description: ""
  )
}

let venmoLogoSVG = base64EncodedString(
  """
  <svg height="33" viewBox="0 0 173 33" width="173" xmlns="http://www.w3.org/2000/svg"><g fill="#808080" fill-rule="evenodd"><path d="m28.3126977 1c1.1629875 1.92106909 1.6873023 3.89977322 1.6873023 6.39928328 0 7.97215302-6.804447 18.32854602-12.3270697 25.60071672h-12.61400958l-5.05892072-30.25452374 11.0449469-1.04877889 2.6747219 21.52803823c2.4991539-4.0720811 5.5832354-10.4713644 5.5832354-14.83430847 0-2.38812212-.4090611-4.01474472-1.0483309-5.35408794z"/><path d="m43.0581419 13.4006445c2.0342342 0 7.1555318-.9435324 7.1555318-3.89472232 0-1.41711656-.9882785-2.12400835-2.1528755-2.12400835-2.0375215 0-4.711283 2.47730275-5.0026563 6.01873067zm-.2330988 5.8448105c0 3.6035422 1.9762585 5.0173259 4.5962279 5.0173259 2.8530682 0 5.5848054-.7068918 9.1353766-2.5363871l-1.337329 9.2074701c-2.5016271 1.2392574-6.4003519 2.0661361-10.1846195 2.0661361-9.599183 0-13.0346991-5.9023799-13.0346991-13.2812638 0-9.5637946 5.5883916-19.7187362 17.1097424-19.7187362 6.3432725 0 9.8902576 3.6032393 9.8902576 8.62056519.0005977 8.08850261-10.2384114 10.56641141-16.1749569 10.62488981z" fill-rule="nonzero"/><path d="m91 8.0093098c0 1.16766881-.1761804 2.8613281-.3514665 3.9681558l-3.3089721 21.0222347h-10.737465l3.0183191-19.2707314c.0572362-.5226937.2331185-1.5749743.2331185-2.1588087 0-1.4017421-.8710646-1.75150322-1.9183095-1.75150322-1.3909606 0-2.7852004.64167842-3.7137993 1.11012452l-3.4234446 22.0712185h-10.7979806l4.9330512-31.47400946h9.3456103l.1183479 2.51216632c2.2047889-1.45958601 5.1080392-3.03815676 9.2272621-3.03815676 5.4574191-.00059942 7.3757285 2.80318439 7.3757285 7.0093097z"/><path d="m122.395871 4.4453654c3.10881-2.21659033 6.044338-3.4453654 10.091877-3.4453654 5.573616 0 7.512252 2.80370505 7.512252 7.00971219 0 1.16763601-.1775 2.86124771-.354698 3.96804431l-3.341156 21.0216441h-10.857628l3.109412-19.677484c.057258-.5259757.1775-1.167636.1775-1.5746303 0-1.5782267-.880869-1.92827776-1.939239-1.92827776-1.348275 0-2.695948.58381806-3.696457 1.11009336l-3.460192 22.0705984h-10.854915l3.109411-19.677484c.057258-.5259757.173884-1.167636.173884-1.5746303 0-1.5782267-.881171-1.92827775-1.935924-1.92827775-1.40915 0-2.815587.64166035-3.754318 1.11009335l-3.463507 22.0705984h-10.912173l4.9862694-31.47312523h9.3321526l.293222 2.62748073c2.170983-1.57463029 5.103497-3.15315669 9.034712-3.15315669 3.403839-.00119881 5.632381 1.45864591 6.749515 3.44416659z"/><path d="m161.821332 12.7064507c0-2.5882057-.647689-4.35282282-2.587129-4.35282282-4.294259 0-5.17607 7.58709872-5.17607 11.46835062 0 2.94445.824413 4.7667305 2.763249 4.7667305 4.058928 0 4.99995-8.0013083 4.99995-11.8822583zm-18.821332 6.6469759c0-9.99808795 5.292678-19.3534266 17.470068-19.3534266 9.175788 0 12.529932 5.41280065 12.529932 12.883969 0 9.8821576-5.235583 20.116031-17.706607 20.116031-9.234998 0-12.293393-6.0591726-12.293393-13.6465734z" fill-rule="nonzero"/></g></svg>
  """
)
let spotifyLogoSVG = base64EncodedString(
  """
  <svg height="72" viewBox="0 0 241 72" width="241" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m57.5692523 31.9187142c-11.6378426-6.8704285-30.8342039-7.5021428-41.943916-4.1502857-1.7840036.5382859-3.6706154-.4632856-4.2112486-2.2367142-.5406333-1.7742857.4656171-3.6484286 2.2509141-4.1875714 12.7531681-3.8481429 33.9534079-3.105 47.351111 4.8008571 1.6050857.9471428 2.1314919 3.0072857 1.1799946 4.5998571-.9519285 1.595143-3.0260805 2.1210001-4.6268551 1.1738571zm-.3811164 10.1760002c-.8161234 1.3169998-2.5483917 1.7297141-3.8715206.9214285-9.7025133-5.9288573-24.4974989-7.6461429-35.9762557-4.1824286-1.4886816.4469999-3.0610018-.3874287-3.5128229-1.8642857-.4488033-1.4798572.3910322-3.0398573 1.8766958-3.4898573 13.1131593-3.9552855 29.4140717-2.0395712 40.5578425 4.7682859 1.3231289.81 1.7395976 2.5328572.9260609 3.8468572zm-4.4177585 9.7727143c-.6484149 1.0572855-2.0340571 1.3889998-3.0937673.7444285-8.478544-5.1510001-19.1497996-6.3145715-31.7171521-3.4607144-1.2110358.2760001-2.4177603-.4787141-2.6941127-1.6821427-.2776458-1.2038572.4785509-2.4034287 1.6921735-2.6781429 13.7529516-3.1255714 25.5503113-1.7802859 35.0665777 4.0002856 1.0610036.6441428 1.395127 2.0220001.7462809 3.0762859zm-16.5574329-51.76585727c-19.9396243 0-36.10430049 16.06799997-36.10430049 35.88942857 0 19.8227142 16.16467619 35.8902856 36.10430049 35.8902856 19.9400555 0 36.1038695-16.0675714 36.1038695-35.8902856 0-19.8214286-16.163814-35.88942857-36.1038695-35.88942857z" fill-rule="nonzero"/><path d="m98.3353293 33.2339999c-6.2336656-1.4777141-7.3438176-2.5148571-7.3438176-4.6937142 0-2.0592856 1.9504184-3.4444286 4.8501789-3.4444286 2.8109481 0 5.5977534 1.052143 8.5203634 3.2181429.088381.0655714.19918.0917144.308255.0745714.109076-.0162856.205217-.0754285.269455-.1654285l3.043757-4.2651429c.125026-.1757143.090967-.4174286-.077603-.552-3.477902-2.7741429-7.39426-4.1228571-11.9719664-4.1228571-6.7307548 0-11.4321949 4.0152857-11.4321949 9.7602858 0 6.1607142 4.0556117 8.3421426 11.0640125 10.026 5.9650738 1.3658569 6.9717548 2.5097142 6.9717548 4.5557141 0 2.2667143-2.035781 3.6758571-5.3119158 3.6758571-3.6382808 0-6.6065903-1.2184285-9.9266995-4.0765713-.0823451-.0702857-.1953005-.1028572-.2996333-.0968573-.1095062.009-.2099587.0595716-.2798012.143143l-3.4128016 4.0375715c-.1431343.1675713-.1250269.4178571.0400949.5627142 3.863329 3.4281429 8.6139177 5.2392857 13.7408801 5.2392857 7.2528494 0 11.9396314-3.9398572 11.9396314-10.0371428 0-5.1531428-3.097216-8.003143-10.6919497-9.839143"/><path d="m130.701327 40.1404287c0 4.3512855-2.696268 7.3877142-6.55701 7.3877142-3.816768 0-6.695834-3.1744285-6.695834-7.3877142 0-4.2128574 2.879066-7.3877143 6.695834-7.3877143 3.79866 0 6.55701 3.1062857 6.55701 7.3877143zm-5.264923-13.0178572c-3.143778 0-5.722349 1.230857-7.848667 3.753v-2.8388571c0-.224143-.182798-.4067144-.408277-.4067144h-5.581371c-.225479 0-.407846.1825714-.407846.4067144v31.5437143c0 .2241426.182367.4067141.407846.4067141h5.581371c.225479 0 .408277-.1825715.408277-.4067141v-9.9565715c2.12675 2.3725713 4.705751 3.5314285 7.848667 3.5314285 5.84134 0 11.754678-4.4699999 11.754678-13.014857 0-8.5465716-5.913338-13.0178572-11.754678-13.0178572z" fill-rule="nonzero"/><path d="m152.348646 47.5735713c-4.00129 0-7.017886-3.195857-7.017886-7.4331426 0-4.2548573 2.912263-7.343143 6.925625-7.343143 4.027157 0 7.064016 3.1958571 7.064016 7.4361428 0 4.2544286-2.932095 7.3401428-6.971755 7.3401428zm0-20.4509998c-7.522735 0-13.416242 5.7582856-13.416242 13.110857 0 7.2724286 5.852981 12.9702857 13.323981 12.9702857 7.549465 0 13.461078-5.7389999 13.461078-13.0632855 0-7.2998574-5.871087-13.0178572-13.368817-13.0178572z" fill-rule="nonzero"/><path d="m181.782118 27.63h-6.142266v-6.2425714c0-.2241429-.181936-.4062858-.407416-.4062858h-5.580939c-.22591 0-.40957.1821429-.40957.4062858v6.2425714h-2.683766c-.225048 0-.406553.1825714-.406553.4067144v4.7687143c0 .2237142.181505.4062857.406553.4062857h2.683766v12.3394284c0 4.9864286 2.496656 7.5145716 7.420558 7.5145716 2.002154 0 3.663286-.4110002 5.228708-1.2934286.127183-.0707143.20651-.207.20651-.3518573v-4.5411429c0-.1401428-.073723-.2721427-.194007-.3458571-.121578-.0758572-.272903-.0797143-.397499-.0184284-1.075231.537857-2.114678.7859998-3.276565.7859998-1.790471 0-2.58978-.807857-2.58978-2.6194284v-11.4698571h6.142266c.22548 0 .406984-.1825715.406984-.4062857v-4.7687143c0-.224143-.181504-.4067144-.406984-.4067144"/><path d="m203.18197 27.6544286v-.7667144c0-2.2555713.870014-3.2614285 2.821295-3.2614285 1.163612 0 2.098295.2297143 3.145071.5768571.128907.0402858.263419.0201429.368183-.0565714.107781-.0767143.16857-.1997142.16857-.33v-4.6757142c0-.1782858-.115542-.3368572-.288423-.3895715-1.105841-.3265714-2.5208-.6625714-4.639358-.6625714-5.155848 0-7.880571 2.886-7.880571 8.343v1.1742858h-2.68161c-.225048 0-.409571.1825714-.409571.4062857v4.7931429c0 .2237142.184523.4062857.409571.4062857h2.68161v19.0328569c0 .224143.181936.4062858.406984.4062858h5.58137c.22548 0 .40914-.1821428.40914-.4062858v-19.0328569h5.211463l7.983179 19.0277141c-.906229 1.9992857-1.797369 2.3970001-3.014009 2.3970001-.983401 0-2.018968-.2918572-3.077816-.8678572-.09959-.0544286-.217288-.0634286-.325069-.0304285-.106489.0377142-.196163.1161427-.241432.2194285l-1.891785 4.1258572c-.090105.1949999-.013365.423857.175469.5250001 1.974992 1.0632857 3.758134 1.5171428 5.961193 1.5171428 4.121574 0 6.399649-1.9088573 8.40827-7.0431428l9.683544-24.8742859c.048286-.1251427.034059-.2661429-.043113-.3775714-.07674-.1097143-.200474-.1761428-.335848-.1761428h-5.81073c-.173744 0-.329812.1097143-.38672.2725714l-5.952571 16.9015713-6.519934-16.9127141c-.059495-.1577144-.211683-.2614286-.381116-.2614286z"/><path d="m190.775859 27.63h-5.581802c-.225479 0-.408708.1825714-.408708.4067144v24.2078569c0 .224143.183229.4062858.408708.4062858h5.581802c.225048 0 .408708-.1821428.408708-.4062858v-24.2078569c0-.224143-.18366-.4067144-.408708-.4067144"/><path d="m188.013197 16.6075714c-2.21082 0-4.005601 1.7798572-4.005601 3.978 0 2.199 1.794781 3.9805715 4.005601 3.9805715 2.210388 0 4.003014-1.7815715 4.003014-3.9805715 0-2.1981428-1.792626-3.978-4.003014-3.978"/><path d="m237.140982 30.0381429h-1.022633v1.2964286h1.022633c.510454 0 .815261-.2481428.815261-.6488573 0-.4217143-.304807-.6475713-.815261-.6475713zm.663073 1.8492858 1.111015 1.5462856h-.936839l-1.000215-1.4181429h-.859667v1.4181429h-.78422v-4.0984285h1.838757c.957533 0 1.58784.4868571 1.58784 1.3071428 0 .6719999-.390601 1.0825714-.956671 1.2450001zm-.870876-3.9162858c-2.01207 0-3.534811 1.59-3.534811 3.537 0 1.9457142 1.511963 3.5147142 3.514117 3.5147142 2.011638 0 3.535672-1.5891428 3.535672-3.537 0-1.9461427-1.512824-3.5147142-3.514978-3.5147142zm-.020694 7.4421427c-2.209095 0-3.927998-1.7635713-3.927998-3.9051427 0-2.142 1.741322-3.9252857 3.948692-3.9252857 2.208664 0 3.927998 1.7631427 3.927998 3.9029999 0 2.1415714-1.740029 3.9274285-3.948692 3.9274285z" fill-rule="nonzero"/></g></svg>
  """
)
let nytLogoSVG = base64EncodedString(
  """
  <svg height="48" viewBox="0 0 354 48" width="354" xmlns="http://www.w3.org/2000/svg"><path d="m26.5352985 5.568c0-3.84-3.6534106-4.8-6.5376822-4.8v.576c1.730563 0 3.0765564.576 3.0765564 1.92 0 .768-.5768543 1.92-2.3074173 1.92-1.3459934 0-4.230265-.768-6.3453974-1.536-2.4997021-.96-4.80711938-1.728-6.72996709-1.728-3.84569547 0-6.53768227 2.88-6.53768227 6.144 0 2.88 2.1151325 3.84 2.88427159 4.224l.19228475-.384c-.38456954-.384-.96142384-.768-.96142384-1.92 0-.768.76913909-2.112 2.69198682-2.112 1.73056295 0 4.03798023.768 7.11453654 1.728 2.6919869.768 5.5762584 1.344 7.1145366 1.536v5.952l-2.8842716 2.496v.192l2.8842716 2.496v8.256c-1.5382782.96-3.2688411 1.152-4.8071193 1.152-2.8842716 0-5.38397361-.768-7.49910613-3.072l7.88367573-3.84v-13.248l-9.61423868 4.224c.76913908-2.496 2.8842716-4.224 4.99940408-5.376l-.1922848-.576c-5.76854315 1.536-10.960232 6.912-10.960232 13.44 0 7.68 6.3453975 13.44 13.4599341 13.44 7.6913909 0 12.690795-6.144 12.690795-12.48h-.3845697c-1.1537085 2.496-2.8842715 4.8-4.999404 5.952v-7.872l3.0765564-2.496v-.192l-3.0765564-2.496v-5.952c2.8842716 0 5.7685431-1.92 5.7685431-5.568zm-16.7287751 21.12-2.30741727 1.152c-1.34599341-1.728-2.1151325-4.032-2.1151325-7.296 0-1.344 0-2.88.38456955-4.032l4.03798022-1.728zm20.3821859 4.416-2.499702 1.92.3845694.384 1.1537087-.96 4.2302651 3.84 5.768543-3.84-.1922846-.384-1.5382781.96-1.9228479-1.92v-13.056l1.5382782-1.152 3.2688412 2.688v11.712c0 7.296-1.5382782 8.448-4.8071194 9.6v.576c5.3839736.192 10.3833778-1.536 10.3833778-10.944v-12.672l1.730563-1.344-.3845697-.384-1.5382782 1.152-4.8071193-4.032-5.3839736 4.032v-15.744h-.3845696l-6.729967 4.608v.384c.7691391.384 1.9228479.768 1.9228479 2.88zm35.1881133-2.112-4.8071193 3.648-4.8071194-3.84v-2.304l9.0373845-6.144v-.192l-4.6148345-6.912-9.9988081 5.376v12.672l-1.9228479 1.536.3845694.384 1.730563-1.344 6.5376824 4.8 8.6528147-6.912zm-9.6142387-3.264v-9.408l.3845697-.192 4.2302651 6.72zm46.3406301-21.888c0-.576-.192285-1.152-.384569-1.728h-.38457c-.576854 1.536-1.3459931 2.304-3.268841 2.304-1.730563 0-2.8842715-.96-3.6534106-1.728l-5.5762584 6.336.3845694.384 1.9228479-1.728c1.1537085.96 2.1151324 1.728 4.8071193 1.92v15.936l-11.3448017-19.392c-.9614239-1.536-2.3074172-3.648-4.9994041-3.648-3.0765564 0-5.768543 2.688-5.3839736 6.912h.5768542c.1922849-1.152.7691391-2.496 2.1151327-2.496.9614237 0 1.9228476.96 2.4997021 1.92v6.336c-3.461126 0-5.7685433 1.536-5.7685433 4.416 0 1.536.7691391 3.84 3.0765564 4.416v-.384c-.3845697-.384-.5768543-.768-.5768543-1.344 0-.96.7691391-1.728 2.1151324-1.728h.961424v8.064c-4.0379803 0-7.3068215 2.304-7.3068215 6.144 0 3.648 3.0765564 5.376 6.5376824 5.184v-.384c-2.1151327-.192-3.0765564-1.152-3.0765564-2.496 0-1.728 1.1537085-2.496 2.6919867-2.496s2.8842718.96 3.8456954 2.112l5.5762584-6.144-.3845694-.384-1.3459933 1.536c-2.1151327-1.92-3.2688412-2.496-5.7685433-2.88v-19.2l15.3827817 26.88h1.1537088v-26.88c2.8842715-.192 5.5762581-2.496 5.5762581-5.76zm14.036789 25.152-4.80712 3.648-4.807119-3.84v-2.304l9.037384-6.144v-.192l-4.614834-6.912-9.998808 5.376v12.672l-1.9228481 1.536.3845695.384 1.7305626-1.344 6.537683 4.8 8.652814-6.912zm-9.614239-3.264v-9.408l.38457-.192 4.230264 6.72zm40.956656-10.368-1.345993.96-3.65341-3.072-4.230266 3.84 1.730563 1.728v14.4l-4.614834-2.88v-11.904l1.538278-.96-4.42255-4.224-4.230265 3.84 1.730563 1.728v13.824l-.576854.384-4.03798-2.88v-11.52c0-2.688-1.345994-3.456-2.884272-4.416-1.345993-.96-2.115132-1.536-2.115132-2.88 0-1.152 1.153708-1.728 1.730563-2.112v-.384c-1.538279 0-5.576259 1.536-5.576259 5.184 0 1.92.961424 2.688 1.922848 3.648s1.922848 1.728 1.922848 3.456v11.136l-2.115133 1.536.38457.384 1.922847-1.536 4.42255 3.84 4.80712-3.264 5.383973 3.264 10.191093-5.952v-12.864l2.499702-1.92zm35.764968-10.56-1.922847 1.728-4.230265-3.84-6.345398 4.608v-4.224h-.576854l.192284 31.104c-.576854 0-2.307417-.384-3.65341-.768l-.38457-25.92c0-1.92-1.345993-4.608-4.807119-4.608s-5.768543 2.688-5.768543 5.376h.576854c.192285-1.152.769139-2.112 1.922848-2.112 1.153708 0 2.115132.768 2.115132 3.264v7.488c-3.461125.192-5.576258 2.112-5.576258 4.608 0 1.536.769139 3.84 3.076556 3.84v-.384c-.769139-.384-.961423-.96-.961423-1.344 0-1.152.961423-1.536 2.499701-1.536h.769139v11.904c-2.884271.96-4.03798 3.072-4.03798 5.376 0 3.264 2.499702 5.568 6.345398 5.568 2.691987 0 4.999404-.384 7.306821-.96 1.922848-.384 4.42255-.96 5.576259-.96 1.538278 0 2.115132.768 2.115132 1.728 0 1.344-.576854 1.92-1.345993 2.112v.384c3.076556-.576 4.999404-2.496 4.999404-5.376s-2.884272-4.608-5.960828-4.608c-1.538278 0-4.80712.576-7.114537.96-2.691987.576-5.383973.96-6.153113.96-1.345993 0-2.884271-.576-2.884271-2.496 0-1.536 1.345993-2.88 4.614834-2.88 1.730563 0 3.845696.192 5.960828.768 2.307418.576 4.42255 1.152 6.345398 1.152 2.884272 0 5.383974-.96 5.383974-4.992v-23.616l2.307417-1.92zm-7.883675 11.712c-.576855.576-1.345994 1.152-2.307418 1.152s-1.922847-.576-2.307417-1.152v-8.448l1.922848-1.344 2.691987 2.496zm0 5.76c-.38457-.384-1.345994-.96-2.307418-.96s-1.922847.576-2.307417.96v-4.992c.38457.384 1.345993.96 2.307417.96s1.922848-.576 2.307418-.96zm0 9.024c0 1.536-.961424 3.072-3.076557 3.072h-1.538278v-11.328c.38457-.384 1.345993-.96 2.307417-.96s1.730563.576 2.307418.96zm26.343013-13.632-6.153112-4.416-9.421954 5.376v12.48l-1.922848 1.536.192285.384 1.538278-1.152 6.153113 4.608 9.614238-5.76zm-10.383377 12.096v-13.824l4.807119 3.456v13.632zm28.650431-16.128h-.38457c-.576854.384-1.153708.768-1.730563.768-.769139 0-1.730563-.384-2.115132-.96h-.38457l-3.268841 3.648-3.268841-3.648-5.768543 3.84.192285.384 1.538278-.96 1.922848 2.112v12.096l-2.499702 1.92.384569.384 1.153709-.96 4.614834 3.84 5.960828-4.032-.192285-.384-1.730563.96-2.307417-1.92v-13.44c.961424.96 2.115133 1.92 3.461126 1.92 2.691987.192 4.230265-2.496 4.42255-5.568zm23.074173 18.432-6.537683 4.416-8.845099-13.44 6.345397-9.792h.38457c.769139.768 1.922847 1.536 3.268841 1.536 1.345993 0 2.307417-.768 2.884272-1.536h.384569c-.192285 3.84-2.884272 6.144-4.807119 6.144-1.922848 0-2.884272-.96-4.037981-1.536l-.576854.96 9.614239 14.208 1.922848-1.152zm-21.151326-.96-2.499702 1.92.38457.384 1.153709-.96 4.230265 3.84 5.768543-3.84-.38457-.384-1.538278.96-1.922848-1.92v-29.568h-.192284l-6.922252 4.608v.384c.769139.384 1.922847.576 1.922847 2.88zm53.070597-25.536c0-3.84-3.653411-4.8-6.537682-4.8v.576c1.730563 0 3.076557.576 3.076557 1.92 0 .768-.576855 1.92-2.307417 1.92-1.345994 0-4.230266-.768-6.345397-1.536-2.499703-.768-4.80712-1.536-6.729968-1.536-3.845695 0-6.537682 2.88-6.537682 6.144 0 2.88 2.115132 3.84 2.884271 4.224l.192285-.384c-.576854-.384-1.153708-.768-1.153708-1.92 0-.768.769139-2.112 2.691986-2.112 1.730562 0 4.037979.768 7.114536 1.728 2.691989.768 5.57626 1.344 7.114537 1.536v5.952l-2.884271 2.496v.192l2.884271 2.496v8.256c-1.538277.96-3.26884 1.152-4.80712 1.152-2.884271 0-5.383974-.768-7.499105-3.072l7.883677-3.84v-13.44l-9.61424 4.224c.961423-2.496 3.076557-4.224 4.999403-5.568l-.192283-.384c-5.768544 1.536-10.960233 6.72-10.960233 13.248 0 7.68 6.345399 13.44 13.459936 13.44 7.69139 0 12.690793-6.144 12.690793-12.48h-.384569c-1.153708 2.496-2.884271 4.8-4.999405 5.952v-7.872l3.076557-2.496v-.192l-2.884271-2.496v-5.76c2.884271 0 5.768542-1.92 5.768542-5.568zm-16.728776 21.12-2.307417 1.152c-1.345991-1.728-2.115131-4.032-2.115131-7.296 0-1.344.192285-2.88.576854-4.032l4.03798-1.728zm23.458744-23.04h-.192285l-3.845695 3.264v.192l3.26884 3.648h.384572l3.845694-3.264v-.192zm5.768543 28.416-1.538277.96-1.922849-1.92v-13.248l1.922849-1.344-.384572-.384-1.345991 1.152-3.461128-4.032-5.576257 3.84.384568.576 1.345995-.96 1.730562 2.112v12.48l-2.499702 1.92.192285.384 1.345994-.96 4.230266 3.84 5.768542-3.84zm32.111557-.192-1.345994.96-2.115131-1.92v-13.056l1.922848-1.536-.384571-.384-1.538277 1.344-4.422551-4.032-5.768543 4.032-4.422551-4.032-5.383971 4.032-3.461128-4.032-5.576257 3.84.192283.576 1.345994-.96 1.922849 2.112v12.48l-1.538278 1.536 4.422549 3.648 4.230265-3.84-1.730563-1.728v-13.056l1.730563-1.152 2.884271 2.688v11.52l-1.538277 1.536 4.422549 3.648 4.230265-3.84-1.730563-1.728v-12.672l1.538277-.96 3.076557 2.688v11.52l-1.345994 1.344 4.422551 4.032 5.960828-4.032zm16.728776-2.88-4.80712 3.648-4.807119-3.84v-2.304l9.037385-6.144v-.192l-4.614834-6.912-9.998811 5.376v13.056l6.729968 4.8 8.652814-6.912zm-9.614239-3.264v-9.408l.384568-.192 4.230266 6.72zm27.112152-1.728-3.653411-2.88c2.499702-2.112 3.461128-4.992 3.461128-6.912v-1.152h-.384571c-.384569.96-1.153709 1.92-2.691986 1.92-1.53828 0-2.499703-.768-3.461125-1.92l-8.652817 4.8v6.912l3.268843 2.496c-3.268843 2.88-3.845697 4.8-3.845697 6.336 0 1.92.961425 3.264 2.499703 3.84l.192285-.384c-.384571-.384-.76914-.576-.76914-1.536 0-.576.76914-1.536 2.307417-1.536 1.922849 0 3.076557 1.344 3.653411 1.92l8.268246-4.992v-6.912zm-2.115131-5.76c-1.345995 2.304-4.230266 4.608-5.960829 5.76l-2.115134-1.728v-6.72c.76914 1.92 2.884274 3.456 4.999406 3.456 1.345994 0 2.115131-.192 3.076557-.768zm-3.268843 15.36c-.961423-2.112-3.26884-3.648-5.576257-3.648-.576854 0-2.115134 0-3.653411.96.961423-1.536 3.461126-4.224 6.729968-6.144l2.307417 1.92z" fill="#7d7d7d"/></svg>
  """
)
let atlassianLogoSVG = base64EncodedString(
  """
  <svg height="42" viewBox="0 0 334 42" width="334" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m12.1122989 19.4929412c-.2464555-.3233506-.6438942-.4939584-1.0476646-.4497294-.4037704.0442291-.7549888.296845-.925826.6659058l-10.00929797 20.042647c-.18638497.3720372-.16663498.8142927.05216792 1.1681802.21880289.3538878.60530703.5687001 1.02091762.567408h13.93777773c.4568476.0121044.8777343-.2471076 1.0730856-.6608823 2.9972389-6.2382351 1.1779272-15.6882352-4.1011603-21.3335293z"/><path d="m19.4573845 1.23529412c-5.0931346 7.81998229-5.6908714 17.75035378-1.5726254 26.12647058l6.7530384 13.4647058c.2035571.4063248.6191737.6622911 1.0730855.6608823h13.9377777c.4123145-.0050895.7929541-.2224596 1.0073122-.575241.2143582-.3527811.2322212-.7912491.047272-1.1603472l-19.2106982-38.51647048c-.1877659-.39203981-.5834289-.64145466-1.0175811-.64145466s-.8298152.24941485-1.0175811.64145466z"/><path d="m182.942584 17.3311765c0 4.9411764 2.30035 8.9064705 11.292067 10.6420588 5.365428 1.1241176 6.487851 1.995 6.487851 3.7861765 0 1.7911764-1.122423 2.8658823-4.933727 2.8658823-4.568282-.0826455-9.045121-1.2963792-13.031206-3.5329413v8.0911767c2.707383 1.327941 6.284335 2.8164705 12.951033 2.8164705 9.404916 0 13.136047-4.1938236 13.136047-10.4382354m0 0c0-5.8861764-3.114415-8.6470587-11.908783-10.5432352-4.853553-1.0747059-6.03148-2.1494118-6.03148-3.7058824 0-1.9455882 1.739138-2.7608823 4.933726-2.7608823 3.88531 0 7.715115 1.1797059 11.347571 2.8164706v-7.71441176c-3.482335-1.58776323-7.275311-2.37493905-11.100885-2.30382354-8.689526 0-13.185384 3.7861765-13.185384 9.9811765" fill-rule="nonzero"/><path d="m303.74488 7.86264705v33.62470575h7.153904v-25.6385293l3.01574 6.8064706 10.120308 18.8320587h8.991717v-33.62470575h-7.153904v21.70411765l-2.707381-6.3-8.128316-15.40411765z"/><path d="m250.42363 7.862647h7.819957v33.624706h-7.819957z"/><path d="m241.401078 31.5617646c0-5.8861764-3.114415-8.6470587-11.908783-10.5432352-4.853554-1.0747059-6.031481-2.1494118-6.031481-3.7058824 0-1.9455882 1.739139-2.7608823 4.933727-2.7608823 3.885309 0 7.715115 1.1797059 11.347571 2.8164706v-7.71441176c-3.482335-1.58776323-7.275311-2.37493905-11.100885-2.30382354-8.689526 0-13.185384 3.7861765-13.185384 9.9811765 0 4.9411764 2.30035 8.9064705 11.292067 10.6420588 5.365427 1.1241176 6.48785 1.995 6.48785 3.7861765 0 1.7911764-1.122423 2.8658823-4.933727 2.8658823-4.568281-.0826455-9.045121-1.2963792-13.031205-3.5329413v8.0911767c2.707382 1.327941 6.284334 2.8164705 12.951032 2.8164705 9.404917 0 13.136048-4.1938236 13.136048-10.4382354"/><path d="m122.208409 7.86264705v33.62470575h16.071615l2.528535-7.2635292h-10.730856v-26.36117655z"/><path d="m90.4537108 7.86264705v7.26970585h8.6895261v26.3549999h7.8692941v-26.3549999h9.300075v-7.26970585z"/><g fill-rule="nonzero"><path d="m79.044468 7.86264705h-10.3114885l-11.717601 33.62470575h8.9732154l1.6404641-5.6638233c4.0944044 1.2076047 8.4495957 1.2076047 12.5440001 0l1.6589655 5.6638233h8.9423796zm-5.1557442 21.90176475c-1.4610981.0020264-2.9149234-.2059765-4.317011-.6176471l4.317011-14.6814706 4.3170106 14.6814706c-1.4020872.4116706-2.8559129.6196735-4.3170106.6176471z"/><path d="m165.982899 7.86264705h-10.311489l-11.717601 33.62470575h8.94238l1.6713-5.6638233c4.086708 1.2027594 8.432623 1.2027594 12.519331 0l1.658966 5.6638233h8.942379zm-5.155745 21.90176475c-1.461097.0020264-2.914923-.2059765-4.31701-.6176471l4.31701-14.6814706 4.317011 14.6814706c-1.402087.4116706-2.855913.6196735-4.317011.6176471z"/><path d="m286.415166 7.86264705h-10.311489l-11.7176 33.62470575h8.942379l1.6713-5.6638233c4.086708 1.2027594 8.432624 1.2027594 12.519331 0l1.658966 5.6638233h8.94238zm-5.155744 21.90176475c-1.461098.0020264-2.914924-.2059765-4.317011-.6176471l4.317011-14.6814706 4.317011 14.6814706c-1.402088.4116706-2.855913.6196735-4.317011.6176471z"/></g></g></svg>
  """
)
let bookingLogoSVG = base64EncodedString(
  """
  <svg height="45" viewBox="0 0 269 45" width="269" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m106 4.00048306c0-2.21164678 1.789666-4.00048306 3.992756-4.00048306 2.210614 0 4.007244 1.78883628 4.007244 4.00048306 0 2.20879042-1.79663 3.99951694-4.007244 3.99951694-2.20309 0-3.992756-1.79072652-3.992756-3.99951694"/><path d="m170 31.0018896c0-2.2117731 1.789265-4.0018896 3.992894-4.0018896 2.210316 0 4.007106 1.7901165 4.007106 4.0018896 0 2.2061096-1.79679 3.9981104-4.007106 3.9981104-2.203629 0-3.992894-1.7920008-3.992894-3.9981104"/><g transform="translate(26 1)"><path d="m13.1976567 28.7108715c-3.50070693 0-5.93339554-2.7988638-5.93339554-6.7983623 0-3.9984969 2.43268861-6.7954277 5.93339554-6.7954277 3.5208026 0 5.9803852 2.7969308 5.9803852 6.7954277 0 4.0626708-2.4083461 6.7983623-5.9803852 6.7983623zm0-19.56869919c-7.40620054 0-12.78110263 5.37216079-12.78110263 12.77033689 0 7.3981762 5.37490209 12.7693677 12.78110263 12.7693677 7.4339424 0 12.831208-5.3711915 12.831208-12.7693677 0-7.3981761-5.3972656-12.77033689-12.831208-12.77033689z" fill-rule="nonzero"/><path d="m72.0359626 22.5512215c-.2878798-.5453861-.6179352-1.0071653-.9695089-1.3736584l-.2239077-.2391685.2355147-.2274838c.3399667-.3606777.6875716-.7884316 1.0227244-1.2842093l6.5357656-9.78094381h-7.9341228l-4.9106712 7.65091381c-.2779683.4102593-.8392967.6173408-1.6794439.6173408h-1.1192495v-14.4648323c0-2.89315923-1.790411-3.28689308-3.7246147-3.28689308h-3.3113314l.0056698 34.14338308h7.030287v-10.2417538h.6586986c.8013681 0 1.3471207.0933207 1.5973553.531763l3.8783188 7.3690023c1.0833054 1.9997439 2.1629254 2.3409885 4.1939431 2.3409885h5.3876376l-4.0124944-6.6816992-2.6605597-5.0727493"/><path d="m106.165802 9.08771769c-3.576003 0-5.857817 1.59920381-7.1364404 2.95149081l-.4268639.4345707-.1505912-.5910692c-.3756328-1.4485477-1.6417988-2.24572923-3.5471349-2.24572923h-3.1508288l.0197907 24.65993923h6.982447v-11.3655877c0-1.11118.1435146-2.0755485.4353579-2.9553677.777309-2.6627677 2.9453266-4.3183646 5.6551436-4.3183646 2.179625 0 3.031379 1.1578538 3.031379 4.1501815v10.7404662c0 2.5538854 1.173315 3.7486723 3.712157 3.7486723h3.322938l-.011339-15.6839254c0-6.2315723-3.018921-9.52527691-8.734074-9.52527691"/><path d="m84.0581588 9.64769615h-3.3096358l.0226256 19.06705235h-.0021395v5.5879869h3.532693c.0444488 0 .0801095.0048461.1245477.0048461l1.6454788-.0048461h1.63783v-.0096923h.0113395l.0141745-20.9015208c0-2.5217931-1.1976582-3.74379922-3.6745068-3.74379922"/><path d="m40.6244347 28.7108715c-3.5004235 0-5.9379261-2.7988638-5.9379261-6.7983623 0-3.9984969 2.4375026-6.7954277 5.9379261-6.7954277 3.5134425 0 5.9798181 2.7969308 5.9798181 6.7954277 0 4.0626708-2.4074956 6.7983623-5.9798181 6.7983623zm0-19.56869919c-7.4135633 0-12.789594 5.37216079-12.789594 12.77033689 0 7.3981762 5.3760307 12.7693677 12.789594 12.7693677 7.4262988 0 12.8323365-5.3711915 12.8323365-12.7693677 0-7.3981761-5.4060377-12.77033689-12.8323365-12.77033689z" fill-rule="nonzero"/></g><g fill-rule="nonzero"><path d="m216.97759 28.9213808c-3.550911 0-6.026298-2.8493071-6.026298-6.9208875 0-4.0705607 2.475387-6.9178999 6.026298-6.9178999 3.566136 0 6.070249 2.8473392 6.070249 6.9178999 0 4.1358913-2.444359 6.9208875-6.070249 6.9208875zm0-19.9213808c-7.521811 0-12.97759 5.4689818-12.97759 13.0004933 0 7.5315116 5.455779 12.9995067 12.97759 12.9995067 7.537324 0 13.02241-5.4679951 13.02241-12.9995067 0-7.5315115-5.485086-13.0004933-13.02241-13.0004933z"/><path d="m156.310615 28.6719821c-3.821933 0-5.182253-3.3671152-5.182253-6.5224041 0-1.3901836.348018-5.9210346 4.814968-5.9210346 2.219873 0 5.178284.6423785 5.178284 6.1543712 0 5.1985845-2.618046 6.2890675-4.810999 6.2890675zm8.440507-18.1204032c-1.326599 0-2.347405.5340104-2.85894 1.5093121l-.193282.3787664-.323925-.2840734c-1.128497-.9860352-3.151693-2.155584-6.437147-2.155584-6.536906 0-10.937828 4.9574668-10.937828 12.3350652 0 7.3688494 4.553671 12.5186166 11.069323 12.5186166 2.225539 0 3.984321-.5242556 5.378367-1.5903246l.539591-.4090419v.6882488c0 3.3075914-2.118415 5.1322259-5.958485 5.1322259-1.86619 0-3.564888-.4588379-4.700754-.8747472-1.483316-.4519923-2.352503-.0780925-2.953881 1.4243794l-.554896 1.3862903-.785021 2.0247756.486318.2616385c2.457645 1.3169792 5.656945 2.1028734 8.548761 2.1028734 5.953666 0 12.905187-3.0771748 12.905187-11.7366428l.02549-22.7117783h-3.247764z"/><path d="m12.4865555 29.2462329-5.82415895-.0057063v-6.8394013c0-1.4617742.57690486-2.2218333 1.85224516-2.3967574h3.97191379c2.8349266 0 4.6665779 1.7562662 4.6686085 4.5971707-.0020278 2.9157697-1.7881448 4.6428909-4.6686085 4.6448288zm-5.82415895-18.4500145v-1.79999999c0-1.57547438.67871196-2.32482074 2.16810667-2.42105753h2.98024068c2.555901 0 4.0867727 1.50260099 4.0867727 4.01599242 0 1.9166286-1.0479425 4.1530237-3.992797 4.1530237h-5.24232305zm13.26243295 6.8258139-1.052873-.5812106.919161-.7717085c1.0688262-.9029043 2.8607413-2.9322694 2.8607413-6.43896104 0-5.36503554-4.2370178-8.82799885-10.7947069-8.82799885h-7.48352224v-.00215331h-.85216028c-1.9441897.06999871-3.49971586 1.62311097-3.52146938 3.54461143v30.45323527h3.43445529c.00870339.0021533.01160269 0 .01450199.0021533l8.55611812-.0021533c7.2897701 0 11.9949246-3.8974205 11.9949246-9.9340302 0-3.2500925-1.5207203-6.0288309-4.0766213-7.4419996z"/></g><path d="m260.840016 10c-2.907981 0-5.719078 1.3590518-7.523822 3.6380111l-.508005.6422979-.398339-.7187095c-1.297865-2.3621537-3.532199-3.5615995-6.63878-3.5615995-3.257738 0-5.442631 1.8136746-6.457515 2.8922237l-.663989.7177451-.255708-.9440921c-.370496-1.3590518-1.582843-2.1077644-3.419686-2.1077644h-2.945771l-.028401 24.4418877h6.693047v-10.7893166c0-.9450618.117339-1.880453.354584-2.8584005.63984-2.6068777 2.395427-5.4110904 5.346879-5.1305877 1.820367.1741201 2.709096 1.5776891 2.709096 4.2890474v14.4892574h6.740502v-10.7893166c0-1.1810795.11052-2.0652082.377309-2.9522247.542672-2.4888688 2.375542-5.040621 5.223291-5.040621 2.06073 0 2.822747 1.1646314 2.822747 4.2929049v10.9160317c0 2.4695275 1.103807 3.5732257 3.576518 3.5732257h3.150336l.005691-15.6035906c0-6.2333215-2.750011-9.3964094-8.161391-9.3964094"/><path d="m199.672181 26.8026193c-.020118.0245311-2.937058 3.1081561-6.777358 3.1081561-3.49874 0-7.033742-2.1524881-7.033742-6.95742 0-4.1484621 2.740816-7.0479727 6.663697-7.0479727 1.274151 0 2.72297.4576695 2.949716 1.2273151l.033385.1299333c.522262 1.7450203 2.104022 1.8385167 2.415078 1.8385167l3.713693.0038159v-3.2547924c0-4.2931413-5.446517-5.8501713-9.111867-5.8501713-7.83771 0-13.524783 5.471236-13.524783 13.0054105 0 7.5312308 5.625208 12.9945895 13.381484 12.9945895 6.729302 0 10.388894-4.4348496 10.423138-4.4791637l.195378-.2401381-2.941082-4.8915378-.386732.4133553"/></g></svg>
  """
)
let insuletLogoSVG = base64EncodedString(
  """
  <svg height="37" viewBox="0 0 128 37" width="128" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m0 .10928613c.11999657-.01610533.23699323-.02952643.35098997-.04026331.11999657-.01073689.23999315-.02147377.35998972-.03221065.11399674-.01073688.2309934-.01878955.35098997-.02415799s.23999314-.00805266.35998971-.00805266c.23999315-.01073688.47698637-.00268422.71097969.02415799.23999314.03221064.47398646.08321084.70197994.15300057.22199366.06978974.43798749.16105324.64798149.27379051.20399417.11273726.39598868.24157985.57598354.38652776.16199537.1556848.30299134.32747492.42298792.51537036.1259964.182527.2309934.37579089.314991.57979166.07799777.19863232.13499614.40531731.17099511.62005496.02999914.21473765.03899889.4294753.02699923.64421295v32.79849172h-4.99485729z"/><path d="m9 12.4534281c.07306889-.0052818.14894813-.0105637.22763771-.0158456.07306889-.0052818.14894813-.0105637.2276377-.0158456.0730689-.0052818.14613779-.0079228.21920668-.0079228.07868958-.0052819.15456882-.0079228.22763771-.0079228.2079653-.0105637.4159306-.0026409.6238959.0237684.2023447.0211275.4046893.0607415.6070339.1188421.196724.0528187.3878272.121483.5733098.2059929.1854826.0897917.3625341.1901473.5311547.3010665.1573791.1162011.2978962.2456069.4215513.3882174.123655.1373286.2332584.2878618.32881.4515998.0899309.1637379.1601895.3353986.2107756.5149822.0562069.1743017.0927413.3538852.1096034.5387506.2529308-.2376841.5227236-.4621635.8093785-.6734383.2810342-.2112747.5761201-.4093448.8852577-.5942102.303517-.1795836.6182753-.3459624.944275-.4991366.320379-.1478924.6519993-.28258.9948611-.404063.3709651-.1267649.7475509-.2403251 1.1297575-.3406806.3822065-.1003555.7672233-.1822245 1.1550506-.2456069.3934478-.0633824.7868957-.1109192 1.1803436-.1426104.3934479-.0316913.7897061-.0448959 1.1887747-.0396141.4608961-.0211274.9217922-.0079228 1.3826883.0396141.4665168.0475368.9217922.1294057 1.3658262.2456069.4496548.1109192.8880681.2561706 1.3152401.4357542.4215513.1795835.8290509.3855764 1.2224988.6179786.3428618.2324023.6604304.4938548.952706.7843576.2978962.2852209.5620684.5942102.7925164.926968.2360688.3327577.4356031.6813611.5986029 1.04581.1686205.3697309.2978963.7473845.3878272 1.1329609.0786896.3802946.1433274.7605892.1939136 1.1408837.0562068.3802946.098362.7632301.1264654 1.1488065.0337241.3802946.0533965.7632301.0590172 1.1488065.0112413.3855765.008431.7711529-.008431 1.1567293v14.1659726h-4.5105991v-14.0154393c.0112414-.2905028.0140518-.5783647.0084311-.8635856-.0112414-.2905028-.0281034-.5783646-.0505862-.8635856-.0281034-.2905028-.0646378-.5783646-.1096033-.8635855-.0449655-.285221-.1011723-.567801-.1686205-.84774-.0562069-.2165566-.1348965-.4251905-.2360688-.6259015-.1011723-.1954291-.222017-.3802945-.3625341-.5545962-.1461378-.1795836-.3063273-.3406806-.4805685-.483291-.1742412-.1478924-.3625341-.2772982-.5648788-.3882174-.2585514-.1162011-.5255339-.2191976-.8009474-.3089893-.2697929-.0845099-.5480167-.1558152-.8346716-.2139157-.2810342-.0528187-.5648788-.0897918-.8515337-.1109193s-.5733098-.0264093-.8599646-.0158456c-.2922756 0-.5845512.0079228-.8768268.0237684-.2866549.0211275-.5733097.0528187-.8599646.0950737-.2866549.0422549-.5733098.0950736-.8599647.158456-.2810342.0633825-.5592581.1373286-.8346716.2218385-.2192067.0686643-.435603.1478924-.649189.2376841-.213586.0845099-.418741.1822245-.6154649.2931438-.196724.1109192-.3878272.2324022-.5733098.3644489s-.3625341.2746572-.5311547.4278314c-.123655.1109193-.238879.2324022-.345672.364449-.1011723.1320467-.1882929.2720162-.2613618.4199086-.0730689.1478923-.1292758.3010665-.1686206.4595226-.0393447.1531742-.0646378.3116302-.0758792.4753682v16.6141188h-4.510599z"/><path d="m48.738706 18.1217491c-.1755557-.2084112-.3644112-.4034628-.5665664-.5851546-.2021551-.1870357-.4122901-.3607118-.6304048-.5210281-.2181148-.1603163-.4468693-.3046011-.6862635-.4328541-.2393943-.133597-.4841084-.2538342-.7341424-.3607118-.2606737-.1175653-.5293273-.2217709-.8059606-.3126168-.2766334-.090846-.5559267-.1656603-.8378799-.2244429-.2819533-.0641266-.5665664-.1122215-.8538395-.1442847-.292593-.0320633-.582526-.0480949-.8697991-.0480949-.2819533-.0160317-.5665664-.0106878-.8538395.0160316-.2819533.0267194-.5612465.0748143-.8378799.1442847-.2766334.0641265-.5452869.1496286-.8059606.2565062-.2659937.1015336-.5240075.2244428-.7740415.3687275-.2872731.1923796-.5426269.4328541-.7341423.7214236-.1994952.2885694-.335152.6172179-.4149501.9538822-.0718182.3446801-.0718182.697376-.0079798 1.0420562.0638385.3446801.1915154.6733286.3830308.961898.0904379.1229092.1888555.2404745.2952529.352696.1063975.1068775.2207747.2057393.3431318.2965852.1223571.0961898.250034.1816918.3830308.2565061.1276769.0801582.2633337.1496286.4069702.2084113.250034.1068775.502728.2057393.7580818.2965852.2553539.0961898.5133677.1843638.7740414.2645219.2606738.0855021.5240074.1629883.7900011.2324587.2606737.0694705.5240074.130925.790001.1843638.3989904.0855021.7926609.1843638 1.1810116.2965853.3883507.1122214.7740414.2378025 1.1570722.3767434.377711.1389408.752762.2912413 1.125153.4569015.3670712.1656602.7314824.3446801 1.0932338.5370598.250034.1389408.4894282.2965852.7181827.4729332.2287545.171004.4468693.3580398.6543443.5611071.2021551.2030674.3910106.4194945.5665664.6492812.1755558.2244429.332492.4622455.4708087.7134077.1329968.26185.250034.5317159.3511115.8095975.1010776.2778817.1861956.5611072.2553539.8496766.0638385.2832256.1117173.571795.1436366.8657083.0265993.2939132.0372391.5878265.0319192.8817398.0159596.5210281-.0319192 1.0420562-.1356567 1.5550685-.1117174.5049965-.2713135 1.0019771-.4947482 1.4668945-.2234346.4729332-.5027279.9138031-.8299 1.3226098-.3191924.4007908-.6942434.7695184-1.1091934 1.0821353-.4708087.3526959-.9735366.6653128-1.500204.9378506-.5266673.2645219-1.0772741.4889648-1.6438405.657297-.5585866.1763479-1.1411126.304601-1.7236386.3767434-.5905058.0721423-1.1810116.0961898-1.7715174.0721423-.4681488.0160316-.9389575.0080158-1.4124261-.0240474-.4681488-.0320633-.9336376-.088174-1.3964665-.1683322-.4681487-.0801582-.9283177-.1843638-1.3805068-.3126169-.4521892-.128253-.8990584-.2778816-1.3406078-.4488857-1.5055239-.6092021-2.2582858-1.3172659-2.2582858-2.1241915 0-.0961898.0053199-.1923796.0159596-.2885694.0159596-.0961898.0345792-.1923796.0558587-.2885694s.0452189-.1897077.0718183-.2805536c.0319192-.0961898.0664984-.1897077.1037375-.2805536.0744782-.1603163.1489564-.3179607.2234346-.4729332.0797981-.1549725.1622561-.3099449.2473741-.4649174.079798-.1549724.164916-.307273.2553538-.4569016.0904378-.1496285.1835356-.2965852.2792933-.4408699.2340744.1977235.4761286.3874312.7261626.569123.2553538.1816919.5160276.352696.7820212.5130123.2606737.1549725.5319872.3019291.8139404.4408699.2766334.133597.5585866.2565062.8458597.3687276.2819533.1068776.5665664.2030674.8538395.2885694.2872731.0855021.5798661.1576444.8777789.2164271.2979129.0534388.5958257.0961898.8937386.1282531.2979128.0267193.5984856.042751.9017183.0480949.3085526.0160316.6197651.0106877.9336376-.0160317.3138725-.0320632.6224251-.088174.9256578-.1683321.3032327-.0801582.5984856-.1816919.8857587-.3046011.2872731-.1282531.5612465-.2778816.8219203-.4488857.207475-.1523005.3910106-.3366643.5585865-.5370598.1595962-.2003954.3032328-.4168224.4069703-.657297.1117173-.2324586.1915154-.480949.2393942-.7294393.0478789-.2565061.0638385-.5210281.0558587-.7775342.0053199-.2351307-.0132997-.4702613-.0558587-.7053919-.042559-.2297868-.1117173-.4542297-.207475-.6733287-.0957577-.2137551-.2154548-.4168224-.3590914-.609202-.1436365-.1870358-.3058926-.3580399-.4867683-.5130123-.7394622-.6198899-2.1146492-1.1489338-4.1255609-1.5871318-2.6492964-.5717949-4.5511507-1.4214715-5.705563-2.5490298-.2872731-.2885694-.5506068-.6092021-.7740414-.9538822s-.41495-.7134077-.5585866-1.0981669c-.1516163-.3767434-.2633336-.7775342-.3271721-1.1863409-.0638385-.4007909-.0957577-.8176133-.0718183-1.22642-.0159596-.4729332.0239394-.9538822.1276769-1.4187996.1037376-.4649174.2553539-.9138031.4708087-1.3386414.2074751-.4328541.4708087-.833645.7740414-1.1943568.3032328-.3607117.6543443-.6893602 1.0373751-.9699138.4388895-.3206327.9096982-.6011863 1.3964665-.8416608s.997476-.4328541 1.5161636-.5931704c.5266673-.1603164 1.0533347-.2725378 1.5959617-.3366643.5426269-.0721424 1.0852539-.088174 1.6278809-.0721424.2872731 0 .5745462.0080158.8618193.0240475.2872731.0160316.5745462.040079.8618193.0721423.2819532.0267194.5665664.0641265.8538395.1122214.2819532.0480949.5612465.1042057.8378798.1683322.2287545.0480949.457509.1068776.6862636.176348.2234346.0641265.4442093.1362689.662324.216427.2181148.0855021.4335696.176348.6463645.2725378.2127949.1015337.4202699.2084112.6224251.3206327 1.1384526.6412653 1.707679 1.2985623 1.707679 1.971891-.0212795.2458183-.0558587.4862928-.1037375.7214235-.0531988.2404745-.1196972.4756051-.1994953.7053919-.079798.2297867-.1755557.4542296-.2872731.6733286-.1063974.2137551-.2260945.4221663-.3590913.6252337z"/><path d="m55.0169492 12.0485092c.079096-.00539.158192-.0107799.2372881-.0161698.079096-.0053899.1610169-.0107798.2457627-.0161697.079096-.0053899.1581921-.0080848.2372881-.0080848.0790961-.0053899.1581921-.0080849.2372882-.0080849 2.3841808 0 3.579096 1.1534398 3.5847457 3.4603195v11.8685726c-.0112994.2748851-.0141243.5524653-.0084745.8327404.0112994.2748852.0282485.5497704.0508474.8246556.0282486.2802751.0649718.5578552.1101695.8327404s.0988701.5470755.161017.8165707c.0451977.1616972.1045197.3206994.1779661.4770067.0734463.1509174.1610169.2964448.2627118.4365824.0960452.1401375.2062147.2694953.3305085.3880732s.259887.226376.4067797.3233943c.1242937.0862385.2514124.1643922.3813559.2344609.1299435.0754587.2627119.1428325.3983051.2021215.1355932.0646789.2740113.1212729.4152542.169782.1412429.0485092.2853107.0916284.4322034.1293578.1864407.0431192.3728814.0808486.559322.113188.1864407.0323394.3757063.056594.5677966.0727637.1920904.0215597.381356.0350344.5677967.0404243.1920904.0053899.3841807.0080849.5762711.0080849.2768362 0 .5508475-.0107798.8220339-.0323394.2768362-.0215597.5508475-.0565941.8220339-.1051032.2711865-.0538991.5395481-.115883.8050848-.1859518.2655367-.0754586.5254237-.1643921.779661-.2668003.220339-.0808486.4350283-.172477.6440678-.2748852.2146893-.1024082.420904-.2155962.6186441-.3395641.1977401-.1185779.3898305-.2479356.5762712-.3880732.1864406-.1401375.3644067-.2883599.5338983-.4446672.1299435-.1024082.2457627-.2155962.3474576-.3395641.1073446-.1185779.200565-.2479356.279661-.3880732.079096-.1401375.1412429-.285665.1864407-.4365824.0508474-.1563072.0819209-.3126145.0932203-.4689218v-17.5118038c.0847458-.00539.1666667-.0107799.2457627-.0161698.0790961-.0053899.1581921-.0107798.2372882-.0161697.079096-.0053899.1581921-.0080848.2372881-.0080848.0847458-.0053899.1666667-.0080849.2457627-.0080849 2.3841808 0 3.5762712 1.1534398 3.5762712 3.4603195v20.770002h-4.5423729v-2.2395059c-1.8135593 2.005045-4.4661017 3.0075674-7.9576271 3.0075674-.3163842.0053899-.6327684-.0026949-.9491525-.0242545-.3163842-.0161698-.6327684-.0458142-.9491526-.0889335-.3163842-.0431192-.6299435-.0970183-.940678-.1616972-.3107344-.0700687-.618644-.1482224-.9237288-.2344609-.2542373-.0754586-.5-.1643921-.7372881-.2668003-.2429379-.1024082-.4774011-.2182912-.7033898-.3476489-.220339-.1347477-.4350283-.2802751-.6440678-.4365824-.2033899-.1563073-.3983051-.3233943-.5847458-.5012612-.180791-.1940366-.3502825-.3961581-.5084746-.6063644-.1581921-.2102064-.3050847-.4284975-.4406779-.6548736-.1299435-.226376-.2457627-.4608369-.3474577-.7033827-.0960452-.2425458-.1807909-.4877865-.2542372-.7357221-.0960452-.404243-.180791-.8084859-.2542373-1.2127288-.0677966-.4096329-.1242938-.8192657-.1694916-1.2288986-.039548-.4096328-.0677966-.8219606-.0847457-1.2369833-.0112995-.4096329-.0112995-.8219607 0-1.2369834z"/><path d="m80.0150036 2.04823455c.0777963-.00535939.1555926-.01339848.2333889-.02411727.0777963-.0053594.1555926-.01071879.2333889-.01607819.0833532 0 .1639279-.0026797.2417242-.00803909h.2333889c2.3450028 0 3.5175042 1.14691047 3.5175042 3.4407314v25.4919609c-.0055569.1661412-.0083354.3296028-.0083354.4903846.0055569.1607819.0166707.3215637.0333413.4823455.0222275.1607819.0472335.3215637.0750179.4823456.0333413.1554224.0722394.3135246.1166944.4743064.0333413.0803909.0750179.1581021.1250298.2331337.044455.0696721.1000238.1366645.1667064.2009773.0611256.0643127.1305866.1205864.2083829.1688209.0722394.0482346.1500357.0911097.2333889.1286255.1278082.0428751.2556164.0803909.3834246.1125473.1278082.0321563.2583949.0562736.39176.0723518.1333651.0214376.2667302.0348361.4000952.0401955.1333651.0053594.2667302.0053594.4000953 0v1.8248739c-.2333889.0643127-.4695562.1205863-.708502.1688209-.2389458.0482345-.4778916.0857503-.7168374.1125473-.2445026.0321563-.4890053.0535939-.7335079.0643127-.2445027.0107188-.4862269.0133985-.7251727.0080391-.2000476.0053594-.4000953 0-.6001429-.0160782-.1944907-.0107188-.3889815-.0375157-.5834723-.0803909-.1944907-.0375158-.386203-.0857503-.5751369-.1447037-.1889339-.0589533-.3750893-.1313051-.5584663-.2170554-.1500357-.0750316-.2917361-.1634616-.4251012-.2652901s-.2583949-.2143758-.3750893-.3376418c-.1111376-.1232661-.2139398-.257251-.3084068-.4019547-.08891-.1393442-.1639279-.2840479-.2250536-.4341109-.0944669-.2679698-.1722632-.5386192-.2333889-.8119483-.0666825-.2733291-.1166944-.549338-.1500357-.8280265-.0388981-.2786885-.0639041-.5573771-.0750178-.8360656-.0111138-.2786885-.0083354-.5600567.0083353-.8441046z"/><path d="m93.7639574 25.2032813c.1085915 2.6197146.8372976 4.6365213 2.1861183 6.0504202 1.354536 1.4085634 3.292037 2.1128451 5.8125023 2.1128451.668696.0320128 1.337391-.0160064 1.997513-.1280512s1.303098-.2961184 1.920354-.5442177c.617257-.2480992 1.200222-.5602241 1.740322-.9283713.5401-.3681473 1.028762-.792317 1.474558-1.272509.102876.1227157.202895.2454315.300056.3681472.097161.1227158.188606.2480993.274336.3761505.091446.1280512.180033.2587702.265764.3921568.080014.1333867.160029.2667734.240044.4001601.057153.0960384.111449.1947446.162887.2961185.045723.0960384.08573.1974123.120022.3041216.040008.1013739.071442.2054155.094304.3121249.022861.1067093.040007.2160864.051438.3281312-.022862.1760704-.065727.3468054-.128596.5122049-.062868.1653995-.145741.3227958-.248617.4721889s-.222898.2854475-.360067.4081632c-.137168.1227158-.288624.2294251-.454369.3201281-1.943216 1.3445378-4.572274 2.0168067-7.887172 2.0168067-3.9607322 0-7.0041518-1.0911031-9.130259-3.2733093-2.1203919-2.1875417-3.1834455-5.3648126-3.1891608-9.5318127-.0171461-.5602241.0028576-1.1204482.0600111-1.6806723.051438-.5655596.1400258-1.1231159.2657634-1.6726691.1257375-.5495531.2857671-1.0937708.4800887-1.632653.1943216-.5335468.4229353-1.0537549.685841-1.5606243.2286137-.4321729.4886618-.8483393.7801442-1.2484994.2914824-.3948246.6143993-.7709751.9687505-1.1284514.3543512-.3521408.7315638-.6802721 1.1316377-.9843937.4057893-.3041217.8315823-.5788983 1.2773789-.8243298.451512-.240096.9173124-.4535147 1.3974011-.6402561.4800888-.1867413.9744659-.3414699 1.4831313-.4641856.5029501-.1227158 1.0116155-.2134187 1.5259963-.2721089.5200961-.0586901 1.0401926-.0853675 1.5602886-.080032.485804-.0160064.974466 0 1.465985.0480192.485804.0480192.965893.1253835 1.440266.2320928.474374.1120449.937316.250767 1.388828.4161665.457228.1653995.897309.3601441 1.320244.5842337.388644.2134187.754425.4535147 1.097346.7202881.348636.2614379.671553.5468854.96875.8563426.302914.3094571.57725.6402561.82301.9923969.245759.3468054.462942.7096172.651549 1.0884354.211467.4215019.394358.8563425.548672 1.3045218.16003.4428438.288625.8936908.385786 1.352541.102876.4535148.177176.9150327.222898 1.3845538.051438.4641857.071442.9310391.060011 1.4005603.005716.2347605.005716.4695211 0 .7042817 0 .2347605-.008573.4695211-.025719.7042817-.01143.2347606-.028576.4695211-.051438.7042817-.022861.2347606-.051438.4695211-.08573.7042817zm12.6451946-3.2252901c0-4.2950514-2.00037-6.442577-6.00111-6.442577-.4286502-.0160064-.8573009.0080032-1.2859515.080032-.4200776.0640256-.8401553.1760704-1.2345139.320128-.4029316.1520609-.7801442.3441377-1.1402107.5682273-.3514935.2240897-.685841.4801921-.9858965.7683073-.3086285.3201281-.5829649.6642657-.8315823 1.032413-.2400443.3681473-.4543696.7523009-.6172569 1.152461-.1714603.4001601-.3086285.8163265-.3943586 1.2404962-.0943031.4241697-.1457412.8563425-.1543142 1.2805122z" fill-rule="nonzero"/><path d="m114.015247 5.04839929c.079058-.0053777.158115-.01344424.237173-.02419964.079058-.0053777.158116-.00806655.237173-.00806655.079058-.0053777.160939-.0107554.245644-.0161331h.237173c2.383027 0 3.574541 1.15082766 3.574541 3.45248298v3.91227632h7.953775v3.6541467h-7.953775v13.1081421c0 2.7748929 1.157631 4.1623393 3.472894 4.1623393.152469 0 .304937-.0080665.457406-.0241996.152468-.0161331.304937-.0376439.457405-.0645324.146822-.0322662.293643-.0699101.440465-.1129317s.29082-.0941097.431994-.1532644c.146822-.0591547.29082-.1236871.431994-.1935972.141175-.0645324.279526-.1344425.415054-.2097303.135527-.0806655.268231-.1613309.398112-.2419964.129881-.0860432.256938-.1747753.381171-.2661962.095999-.06991.189174-.1398201.279526-.2097302s.17788-.1425091.262585-.2177968c.084704-.0752878.166586-.1559533.245643-.2419965.079058-.0806655.155292-.1640199.228703-.250063 1.033398 1.2207377 1.550097 2.1699016 1.550097 2.8474918-.022588.1505755-.062117.2957734-.118587.4355936-.056469.1451979-.127057.2823292-.211761.411394-.090352.1236871-.191998.2393076-.304938.3468616-.118586.107554-.245643.1989749-.381171.2742627-.18635.1344425-.378348.2608184-.575992.3791278-.197645.1183094-.398112.2258634-.601404.322662-.208938.0967985-.423524.1855306-.643756.2661961-.214585.0752878-.434818.142509-.660697.2016637-.259761.0699101-.519522.1317536-.779284.1855306-.265408.0483993-.530816.0914209-.796224.1290648-.265408.0322662-.530817.0564659-.796225.072599s-.53364.0241996-.804695.0241996c-3.557599 0-5.816392-1.2718259-6.776379-3.8154777-.107293-.3549281-.197645-.7125452-.271055-1.072851-.073411-.3603059-.132705-.7233006-.17788-1.0889841-.045176-.3656836-.076235-.7313671-.093176-1.0970507-.011294-.3710613-.00847-.7394337.008471-1.1051172z"/></g></svg>
  """
)
let jpMorganLogoSVG = base64EncodedString(
  """
  <svg height="49" viewBox="0 0 234 49" width="234" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m23.84176 34.6223242h-13.90447774v-1.1868953h4.43008644v-23.0732435c0-6.92553368-1.919803-8.87797635-6.20449482-8.87797635-2.70018667 0-3.13933791 2.04442705-3.13933791 3.11263277 0 2.51621791-.14539467 4.06511619-2.44500419 4.06511619-2.30554401 0-2.57852991-2.33224914-2.57852991-3.053288 0-3.17494477 2.45687314-5.60808001 8.77412306-5.60808001 7.51601407 0 10.49512117 2.54292305 10.49512117 10.9817482v22.4649597l4.5725139-.011869z" transform="matrix(1 -0 -0 -1 0 34.622914)"/><path d="m24.77762 34.6617833c-.7685147 0-1.4124053-.249248-1.9287048-.7833508-.5400373-.5281684-.8070887-1.1601901-.8070887-1.9376065 0-.7625802.2670514-1.382733.8070887-1.8930979.5400374-.5400373 1.183928-.7863181 1.9287048-.7863181.7685147 0 1.4094381.2462808 1.9613444.7863181.5252011.5103649.7892853 1.1305177.7892853 1.8930979 0 .7774164-.2640842 1.4124053-.7892853 1.9376065-.5400374.5341028-1.1690918.7833508-1.9613444.7833508" transform="matrix(1 -0 -0 -1 0 63.923194)"/><path d="m54.57463 34.6617833c-.7655474 0-1.4094381-.249248-1.9346392-.7833508-.5341029-.5281684-.7892854-1.1601901-.7892854-1.9376065 0-.7625802.2551825-1.382733.7892854-1.8930979.5548735-.5400373 1.1809607-.7863181 1.9346392-.7863181.7655474 0 1.4183398.2462808 1.9643116.7863181.5400374.5103649.7952198 1.1305177.7952198 1.8930979 0 .7774164-.2551824 1.4124053-.7952198 1.9376065-.5400373.5341028-1.1928297.7833508-1.9643116.7833508" transform="matrix(1 -0 -0 -1 0 63.923194)"/><path d="m45.93372 33.7618251h-13.6166556v-1.1868952h3.9968697v-26.31940199c0-2.06519771-.1186895-2.15421486-.3471669-2.76249867-.2551825-.67059581-.810056-1.19579695-1.6408826-1.53702933-.6142183-.26111695-1.5459311-.40057715-2.7892039-.43915124v-1.51625867h14.6522218v1.51625867c-1.2432728.03857409-2.1898217.17803429-2.8129417.3976099-.872368.3501341-1.4391105.8486301-1.7120964 1.54296382-.2433136.5845459-.3768393 1.10974705-.3768393 2.15124762v8.56938359l3.6318995.0207707c10.5277607 0 13.4860971 4.1481989 13.4860971 9.8156236 0 5.7327041-1.8100152 9.7473772-12.4713017 9.7473772m-1.8574911-18.2781867h-2.7892038v16.9429296l2.5251197.0326396c8.1183634 0 9.8987063-3.3381429 9.8987063-8.7563197 0-5.4419146-3.1986827-8.2192495-9.6346222-8.2192495" fill-rule="nonzero" transform="matrix(1 -0 -0 -1 0 33.762416)"/><path d="m100.29443 3.5784932c-.189903.61125104-.284855 1.35009333-.284855 2.29960952v26.69327398h3.525079v1.1898624h-8.5901543c-.1216568-.31156-10.3675299-25.80013523-10.3675299-25.80013523-.0474758-.09495162-.1394602-.15132914-.2314446-.15132914-.1157223 0-.2017722.05637752-.249248.15132914 0 0-10.8956983 25.48857523-11.0232895 25.80013523h-9.5515395v-1.1928297h3.9582957v-25.65177334s-.0919844-2.38565943-.0919844-2.38862667c-.062312-.62905448-.261117-1.18689524-.5667425-1.63791543-.3263962-.48365981-.8456629-.85456458-1.5310949-1.0978781-.4569546-.13946019-1.1305177-.24628076-1.9702461-.25814972v-1.53406209h9.7117703v1.51625867c-.810056.02967238-1.1512883.11572228-1.6319809.27595314-.697301.22847733-1.2225021.57564419-1.5667017 1.08304191-.31156.44211847-.510365 1.00886095-.5786115 1.65275162 0 0-.1097878 2.37675772-.1097878 2.38862667v22.12076004h.560808s12.3051364-28.72286481 12.4327277-29.03739205h1.0325988l11.6404751 28.71396305h.3026583v-22.83586438c0-.99995924-.1097878-1.76253943-.3026583-2.35895429-.2314446-.69730095-.7299406-1.22546933-1.4480122-1.58747238-.5341029-.23441181-1.3500933-.37683924-2.4212663-.41541333v-1.51625867h13.2813575v1.51625867c-1.059304.05637752-1.884196.19880495-2.439069.44805295-.771482.38277371-1.275913.91390933-1.489554 1.61417753" transform="matrix(1 -0 -0 -1 0 33.761244)"/><path d="m118.16164 34.7614788c-7.094666 0-11.539589-4.7001051-11.539589-12.9163874 0-12.00247816 9.367571-12.8155014 11.376391-12.8155014 3.999837 0 11.58113 2.5013817 11.58113 13.0499132 0 8.213315-4.851434 12.6819756-11.417932 12.6819756m-.091984-24.2364008c-5.332127 0-6.154052 2.6616126-6.154052 11.1924221 0 6.5932031.409479 11.5455235 6.154052 11.5455235 6.201527 0 6.222298-5.1184858 6.222298-11.1330774 0-8.6287284-1.47175-11.6048682-6.222298-11.6048682" fill-rule="nonzero" transform="matrix(1 -0 -0 -1 0 43.791068)"/><path d="m148.118 33.7615148c-4.24315 0-5.703032-2.5013817-6.866189-5.0561737 0 0-.308593.0326396-.332331.0118689-.035606-.0118689-.851597 4.8425326-.851597 4.8425326h-8.044182v-1.2759124h4.427119v-5.1333219-11.4950804c0-1.6408827-.080116-2.9375657-.510365-3.6229977-.492562-.8011543-1.50439-1.1156815-3.192748-1.1156815h-.724006v-1.5162587h13.759083v1.5162587h-.747744c-1.801114 0-2.729859.3976099-3.210552 1.1750263-.436184.6943337-.626087 1.8634255-.626087 3.5636529v8.610925c0 2.9197623 2.335216 6.2430689 4.973091 6.2430689 2.756564 0 2.845581-3.9582956 5.806885-2.5340213 2.109706 1.0118282 1.640882 5.7861143-3.860377 5.7861143" transform="matrix(1 -0 -0 -1 0 43.162004)"/><path d="m202.88728 12.1894094c-1.465816 0-1.940574.8189577-2.038493 2.192789l-.091984 3.0740586v10.1271837c0 2.1779527-.359036 3.6408011-1.637915 4.9315497-1.261077 1.2818468-3.71795 1.9465082-7.254898 1.9465082-3.412323 0-5.94041-.6320217-7.542719-1.8663928-1.57857-1.1898625-2.174985-2.2996095-2.174985-3.8752129 0-.7358751.186936-1.258109.596415-1.6023086.424315-.3649703.905007-.5341029 1.504389-.5341029 1.36493 0 2.121575.6883993 2.40643 2.4835783.219576 1.3441589.507398 2.1008046 1.177994 2.7951383.688399.7329078 1.786277 1.1008453 3.269896 1.1008453 1.726933 0 2.949435-.4599219 3.625965-1.3916346.637956-.872368.958418-2.056296.958418-3.5221117v-4.0473127c-4.400414-.4005772-14.803551-1.2314038-14.340662-9.159864.186936-3.0977966 2.910861-5.81281948 6.438907-5.81281948 3.907853 0 6.37066 2.21652688 8.056052 3.98796798.267051-1.670555 1.827818-3.69421141 4.676367-3.69421141 3.207584 0 5.121453 1.56670171 5.335094 5.49235771h-.82786c-.210673-1.7002274-1.258109-2.6260057-2.136411-2.6260057zm-7.201487 2.5577592c0-.0890171-.008902-.1424274-.08605-.1988049l-.089017-.0890172c-2.361921-2.1334441-4.166002-2.8989916-5.477521-2.8989916-3.379685 0-3.878181 2.815909-3.878181 4.2075436 0 4.5072347 6.159987 6.7445322 9.530769 6.7445322z" fill-rule="nonzero" transform="matrix(1 -0 -0 -1 0 43.4908)"/><path d="m230.99208 11.9288916c.584546-.747744 1.445045-.9940248 2.898992-1.0949109v-1.51625864h-11.450572v1.50438974c.836761.0682465 1.489553.2462807 1.907934.5341028.560808.3827737.726973.9702869.869401 1.6972602.097919.6379562.13946 1.569669.13946 2.8930572v7.8958206c0 1.9168358-.133526 4.3292003-.789285 5.6288506-.56971 1.1572229-1.548899 1.7239654-3.35298 1.7239654-2.014754 0-3.809933-.9554507-4.798024-2.6942522-.893138-1.5904396-.887204-4.1600678-.887204-6.8305821v-6.3795619c0-1.6408827.210674-2.765466.676531-3.4182583.421347-.6112511 1.231403-.9376473 2.433135-1.0236972v-1.53109484h-11.886756v1.51625864c.922811.0415414 1.614177.1483619 2.065198.3471669.718071.299691 1.192829.8041215 1.388667 1.5429638.183969.6142183.293757 1.545931.293757 2.8337124v16.649173l-3.747622.0089017v1.2492072l7.495243.011869.84863-4.3826107.37684.0089017c.95545 1.8782617 3.053288 4.6585638 7.880984 4.6585638 1.347126 0 2.572596-.2611169 3.628932-.798187 1.050403-.5370701 1.890131-1.3530606 2.498415-2.4390697.593447-1.1067799.783351-2.4628077.783351-4.0384111v-10.9491086c0-1.234371.133525-2.8485486.726973-3.6081615" transform="matrix(1 -0 -0 -1 0 43.079552)"/><path d="m177.28032 47.9254025c-.712137-.2255101-1.175026-.8634662-1.442078-1.9227702-.1721-.9821559-.554873-1.5518656-1.044468-1.7091292-.495528-.1453947-1.341191-.1572636-1.709129.124624-1.237338 1.1423867-3.599259 2.5340213-7.759327 2.5340213-6.697057 0-9.649459-4.7742861-9.649459-9.1183226 0-5.0947479 1.961345-7.5694244 6.266807-8.4773993.267052-.0445086.267052-.3441996.03264-.3976099-3.664539-.7329078-6.925534-1.8100152-6.925534-5.3024545 0-2.1008046 1.207666-3.2491257 2.753597-3.8841147 1.715064-.6973009 4.091821-1.0563367 7.118404-1.1186487 2.628973-.0237379 4.489432-.1157223 5.717868-.2551825 1.305585-.1513291 2.338184-.5311356 3.1156-1.0919436.801154-.5993821 1.216568-1.5043897 1.216568-2.6942522 0-1.6141775-.875335-2.9049261-2.590399-3.8692785-1.605276-.88720418-3.79213-1.36789675-6.524957-1.36789675-2.323347 0-4.234248.249248-5.967116 1.32932265-1.278879.8011543-1.528127 2.3441181-1.261076 3.4716686.249248 1.1334849-.157263 2.3263147-1.480652 2.5518248-.724006.1186895-1.629013-.2640842-2.059263-.9257783-.391675-.6112511-.525201-1.3382244-.525201-2.2076252 0-2.8693192 2.219494-4.21941255 3.91082-4.71197408 2.581497-.78335086 4.299528-.98809029 6.679253-.98809029 3.139338 0 5.711933.49256153 7.533817 1.41833982 1.833754.91984385 3.118568 2.05926325 3.795098 3.35891355.718072 1.308552 1.062271 2.6467764 1.062271 3.9286232 0 1.7388015-.388708 3.1482396-1.118649 4.1986419-2.391593 3.2847326-5.786114 2.8574503-13.420817 3.2135189-3.682343 0-4.39448.6676286-4.39448 1.795179 0 1.6705551 1.370864 2.317413 6.679253 3.1334035 5.240142.810056 10.118282 2.7357935 10.118282 9.1242571 0 1.8367204-.43025 3.4182583-.943582 4.5250381 1.086009-.237379 2.074099-.237379 3.005812.0593448 1.059304.3323307 1.744736.8575318 2.139379 1.6023086.400577.7447767.551906 1.5963741.376839 2.2996095-.320462 1.4717501-1.421307 1.7744084-2.706121 1.3738312m-11.827411-17.5957219c-3.124502 0-4.919681 1.133485-4.919681 7.5041452 0 4.4834967 1.563735 7.8186724 4.919681 7.8186724 3.895984 0 5.041337-3.0354846 5.041337-7.7266881 0-6.7118925-2.121575-7.5961295-5.041337-7.5961295" fill-rule="nonzero" transform="matrix(1 -0 -0 -1 0 55.981452)"/></g></svg>
  """
)
let noomLogoSVG = base64EncodedString(
  """
  <svg height="36" viewBox="0 0 156 36" width="156" xmlns="http://www.w3.org/2000/svg"><path d="m51.4345.19202169c-3.6266455.54078283-7.8169 2.8758407-10.3761273 5.78208703-.9291454 1.05500485-2.4607818 3.38465072-2.4607818 3.742851 0 .13191611-.0764636.23972419-.1700636.23972419-.0934818 0-.1699455.11042409-.1699455.24549619 0 .1352281-.1448909.5479445-.3220454.9173167-.1771546.3695523-.4154091 1.0255929-.5294546 1.4580732-.1141636.4324804-.2705182.9435608-.3475727 1.1358009-.2795.6970806-.3774727 1.7958015-.3820818 4.2807635-.0043728 2.523602.0560182 2.9952024.6848636 5.3414442 1.3672455 5.1004841 5.8599273 9.8700079 10.9507273 11.6251294 4.0229091 1.3872011 7.4250091 1.3857611 11.5276909-.0045601 5.1176273-1.7342413 9.061-5.8898447 11.0388909-11.6328093.7718455-2.2416018.7673545-8.3011266-.0081545-10.6584085-1.866091-5.67250056-5.9095637-9.88239193-11.2399182-11.70270939-2.6678364-.91103005-5.4802091-1.17521855-8.1960273-.77019902zm39.7859091-.01974482c-3.9192636.60560689-8.0330546 2.89750553-10.5521 5.87871591-1.6128273 1.90855353-2.0782273 2.69168616-3.3083818 5.56560442-.5165728 1.206973-.7952455 2.6109741-1.1403364 5.7459766-.0872182.7916407.0868636 2.4984021.4922273 4.8250839.6387727 3.667203 3.3705454 7.8766863 6.7075273 10.3354883 8.0839909 5.9571648 19.0070635 4.0340432 24.7756365-4.3621235 1.183473-1.7224814 2.196291-4.1972434 2.659209-6.4975252.106482-.5286004.265673-1.296361.353836-1.7060414.088282-.4099203.160373-1.293361.160373-1.9633215 0-.6698406-.072091-1.5532813-.160373-1.9632016-.088163-.4098003-.247354-1.177561-.353836-1.7060414-.756718-3.760503-2.342246-6.64037331-5.1636-9.3788715-1.952127-1.89493352-3.834646-3.06822246-6.3229637-3.94081516-2.6619273-.93357051-5.5720364-1.23095739-8.1472182-.83292787zm-87.44823455.73473059c-1.42803819.4922056-2.58216637 1.56137045-3.25920755 3.01911962l-.512967 1.10480489.04335665 15.17444413.04352649 15.1742522 2.84792595.04776 2.84792182.0478801v-14.0594513c0-7.7326862.06562636-14.1010193.14588364-14.15204334.08008-.05101204.3278009.27852022.55019545.73228858.22256.45376837.44376091.8642047.49188455.91225273.10813636.10815609.46111.7420686.92459545 1.65991333.19399545.3843963.39106364.7382286.43781636.7862766.04675273.0480481.24382091.4018804.43781637.7862647.45634727.9037207.81544272 1.5500412.92238545 1.6599613s.46603822.7562406.92238542 1.6598413c.1939955.3844803.3910637.7382406.4378164.7863607.1069427.1098.4660382.7561206.9224445 1.6598413.1939364.3844803.3909455.7382406.4377455.7862406.0468.0481201.1879091.2750402.3135364.5044804.3518272.6421205.8415727 1.5294012 1.2166818 2.2038018.7518727 1.3520411.9933182 1.7840414 1.4658091 2.6209221.2712272.4806004.6068636 1.1095209.7460818 1.3978811.1391.2882402.2914364.5635205.3381182.6115205.0839091.0858001.1993727.2883602.8847091 1.5528012.1880272.3471603.3993363.7099206.4695363.8060407.0700818.0961201.3591546.6072005.6422 1.1356809 1.6416637 3.0645625 1.9908909 3.6434429 2.5604091 4.2447634.3452091.3645603 1.0489818.8750407 1.5635455 1.1342409.8088363.4072803 1.1437636.4708804 2.4662182.4672804 1.2806181-.00336 1.6827909-.0772801 2.4653909-.4520404 1.4405181-.6900005 2.4681091-1.9744816 3.0436545-3.804003.1297636-.4125604.1868455-5.1469242.1868455-15.5037725v-14.9098619l-.3825546-.09714848c-.2104818-.05346724-1.4919273-.07460886-2.8479454-.04700164l-2.4653909.05014684-.0849728 14.24030458-.0849727 14.2402914-.4736727-.7862406c-.4449546-.7386006-1.1912728-2.0565616-2.6706728-4.7176838-.3473363-.6246005-1.1150454-2.0006416-1.7059545-3.0577224-.5910273-1.0570809-1.2793182-2.3151619-1.5296273-2.7956423-.2500727-.4804803-.6858091-1.266721-.9680272-1.7473214-1.3016546-2.2153217-2.2584546-3.9498031-2.2584546-4.0939832 0-.0866641-.0580273-.1838162-.1289364-.2159642-.0710272-.03198-.3898818-.5692685-.7085-1.193917-.3187363-.62466047-.6241181-1.17504091-.6787181-1.22310095-.0543637-.04804803-.2579909-.40186832-.4519273-.78627663-.4635091-.91784473-.8165182-1.55175724-.9246546-1.65991333-.0481-.04804803-.277609-.48049238-.5100727-.96099677-.2325463-.48050438-.4802791-.89984472-.5503254-.93182474-.0700582-.03214803-.1275182-.16965614-.1275182-.30577225s-.0765109-.2475842-.1700282-.2475842-.1700282-.08404806-.1700282-.18696015c0-.27310822-1.0128418-1.7567174-1.51951089-2.22585778-.60002091-.55545645-1.30358091-.91977074-2.30605818-1.19426736-1.17776455-.32254706-2.03043455-.28393222-3.28573818.14869332zm117.14082545-.0090864c-1.282273.45534396-2.648455 1.64681291-3.202845 2.79250183-.709328 1.46613718-.744191 2.33715788-.693846 17.36143391l.047982 14.3277715h2.890254 2.890728l.043727-14.1206513c.035455-11.46200121.083909-14.07749931.26-13.89088716.186727.19674016 6.140727 10.77760466 7.651091 13.59640686.789454 1.4731212 1.388636 2.3192419 2.124909 3.0028824 2.126091 1.9744816 5.928 1.7511614 7.809455-.4585203.536545-.6302405 2.408545-3.8360431 4.694181-8.0388065.489273-.8988007.849728-1.5362412 2.972273-5.2512762.658273-1.1532009 1.297636-2.32474984 1.419364-2.60345006l.221-.50653241.114636.41917234c.062636.23064018.121727 6.61308533.131182 14.18341133l.016545 13.7638911 2.848182-.0478801 2.848182-.04776v-15.2175722-15.2176082l-.566091-1.15705293c-1.028182-2.10319369-2.734727-3.17829855-5.045182-3.17829855-1.116818 0-1.526909.08177287-2.295091.45900997-1.567091.76932302-2.193454 1.51559162-3.791272 4.52038202-.281273.52855243-.635819 1.15756893-.788273 1.39782112-.153636.2402522-.387636.67270854-.521182.96100877-.133545.28830024-.367545.72074458-.52.96099677-.153636.2402522-.510545.8692687-.794182 1.39782113-.283636.5285524-.830818 1.5311412-1.216091 2.2277538-.385272.6968405-1.005727 1.8367215-1.378 2.533562-.373454.6968406-.752818 1.3846811-.842636 1.5289212-.091.1441202-.476273.8319607-.856818 1.5288013-.380546.6967205-.746909 1.266601-.815455 1.266241-.067363-.00036-.361636-.4522804-.653545-1.0046408-.291909-.5523605-.846182-1.5741613-1.232637-2.2708818-.966727-1.7452814-1.985454-3.5793629-2.765454-4.9798-1.448909-2.60151813-2.081182-3.75524705-2.545636-4.64408776-.268273-.51212441-.625182-1.14115292-.794182-1.39782112-.169-.25668021-.489273-.84166868-.711455-1.30015304-.507-1.04941285-1.798727-2.30238185-2.852909-2.76716022-1.233818-.54480044-2.791454-.59372568-4.100909-.1289497zm-63.5925727 5.58185607c2.5437454.85179668 4.1705182 2.02981362 5.9733818 4.32521147.1635636.2082722.2974636.4247643.2974636.4808524 0 .056088.1399273.3108362.3110546.5659444.585.8724247 1.1918636 2.7983063 1.5636636 4.962988.2042182 1.189681.0991546 2.3577619-.3811364 4.2370834-.6464545 2.528642-1.2970454 3.730443-2.937409 5.4268844-1.5013819 1.5528012-2.649991 2.2933218-4.6355637 2.9883623-1.1245.3938404-1.6143636.4624804-3.3569545.4711204-1.2199909.00588-2.3137637-.08028-2.7204273-.2140801-2.5608818-.8437207-4.4500182-2.0197217-5.8436182-3.638043-.7511636-.8724007-1.7356182-2.6475621-2.3650545-4.2646834-.4077273-1.0482008-.5968182-3.768723-.3830273-5.5141244.2123727-1.7332814.2713455-1.9455616.9755909-3.5080828 1.5752455-3.49513481 4.8339909-6.07184887 8.4661909-6.69457737 1.3014182-.22312818 3.8064-.03651603 5.0358455.3751443zm39.8260909.06709205c1.781.58096847 3.0889178 1.39170112 4.3635088 2.70479017 1.762918 1.81628545 2.080591 2.34642185 3.25 5.42267235.355491.9355207.3198 5.7813646-.050109 6.8143255-.813918 2.2717218-2.052582 4.3341634-3.285454 5.4704443-1.032909.9519608-2.9786549 2.0862017-4.3208458 2.5189221-1.2413818.3998403-1.7581909.4702803-3.4178182.4651203-1.6492273-.00528-2.1681636-.07872-3.3154727-.4692003-4.1927364-1.4270412-6.5702-4.2090034-7.8395909-9.1731674-.2685091-1.0500008-.3144819-3.4988428-.0809546-4.3035634.7498637-2.5840821 1.1616091-3.647763 1.8110182-4.6794038 1.7418818-2.76733421 4.6701909-4.72305978 7.8096909-5.21614018 1.3475091-.21159616 3.6928273-.00594 5.0760273.44520036z" fill="#7d7d7d" fill-rule="evenodd"/></svg>
  """
)
let shutterflyLogoSVG = base64EncodedString(
  """
  <svg height="45" viewBox="0 0 196 45" width="196" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><mask id="a" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="b" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="c" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="d" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="e" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="f" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="g" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="h" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="i" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><mask id="j" fill="#fff"><path d="m0 0h195.6v45h-195.6z" fill="#fff" fill-rule="evenodd"/></mask><g fill="#7d7d7d" fill-rule="evenodd"><path d="m156.6 10v4h-5.8v19.8h-4v-19.8h-2.8v-4h2.8c0-4.2 1.6-7.6 4.2-8.8 2.6-1.4 5.6-1.2 5.6-1.2v4c-.4 0-1.6-.2-3.2.6s-2.6 2.6-2.6 5.2v.2z" mask="url(#a)"/><path d="m84.6 14v-4h-5.8v-9.6h-4v9.6h-2.8v4h2.8v10.2c0 4.2 1.8 7.4 4.2 8.8 2.6 1.4 5.6 1 5.6 1v-4c-.4 0-1.6.2-3.2-.6s-2.6-2.8-2.6-5.2v-10.2z" mask="url(#b)"/><path d="m100.4 14v-4h-5.8v-9.6h-4v9.6h-2.8v4h2.8v10.2c0 4.2 1.8 7.4 4.2 8.8 2.6 1.4 5.6 1 5.6 1v-4c-.4 0-1.6.2-3.2-.6s-2.6-2.8-2.6-5.2v-10.2z" mask="url(#c)"/><path d="m64 23.8c0 3.8-1.8 6.2-5 6.2-3 0-5-2.4-5-6.2v-13.8h-4v14c0 6.2 3.4 10 9 10s9-3.8 9-10v-14h-4z" mask="url(#d)"/><path d="m162 0h4v33h-4z"/><path d="m11.8 34c-5.8 0-10.8-3.2-11.8-6l3-2.6c1.4 2 4.2 4.6 8.8 4.6s7.4-1.8 7.4-5.4c0-3.8-3.4-5-8.2-6.2-5-1.2-10-2.8-10-9.4-.2-5 4.6-9 10.8-9 5.4 0 9.4 2.6 10.6 4.6l-3.2 2.6c-1.6-2-4.4-3.2-7.4-3.2-4.2 0-7 2-7 5.2 0 3.8 3 4.6 7.6 5.8 5.4 1.4 10.6 3.4 10.6 9.8.2 5.6-4.4 9.2-11.2 9.2" mask="url(#e)"/><path d="m139 9.8c-3 0-5 1-6.4 2.8v-2.6h-4v23.8h4v-14c0-3.8 3.2-6 6.4-6 .4 0 .8 0 1.2.2v-4c-.4-.2-.8-.2-1.2-.2" mask="url(#f)"/><path d="m114 34c-6.6 0-11.2-5.2-11.2-12.2s4.4-12.2 10.8-12.2c6.4.2 10.4 5 10.4 12.4v1.2.2h-17.2c.6 4.2 3.2 7 7.4 7 2.8 0 4.6-.8 6.6-3l.2-.2 2.4 2.2-.2.2c-2.8 3.2-5.2 4.4-9.2 4.4zm6-13.8c-.4-3.6-2-7-6.6-7-3.6 0-6.2 2.8-6.8 7z" fill-rule="nonzero" mask="url(#g)"/><path d="m37 9.8c-2.8 0-4.6 1.2-5.6 2.2v-11.6h-4v33.4h4v-14c0-3.8 2.4-6.2 5.6-6.2s4.8 2.8 4.8 6.6v13.4h4v-13.4c0-7.4-4-10.4-8.8-10.4" mask="url(#h)"/><path d="m185 10v14c0 3.8-2.4 6.2-5.4 6.2s-4.6-2.8-4.6-6.6v-13.6h-3.8v13.4c0 7.6 3.8 10.6 8.6 10.6 2.6 0 4.6-1.2 5.4-2.2v3.4c0 2.6-1 4.2-2.6 5s-2.6.6-3.2.6v4s3 .4 5.6-1c2.4-1.4 4.2-4.6 4.2-8.8v-25z" mask="url(#i)"/><path d="m194.4 30.8c0-.2 0-.4-.2-.4-.2-.2-.4-.4-.8-.4h-1v2.2h.4v-.8h.4l.6.8h.4l-.6-.8c.6 0 .8-.2.8-.6m-1 .4h-.6v-.6h.6c.2 0 .4.2.4.4s0 .2-.4.2m0-2.2c-1.2 0-2.2 1-2.2 2.2s1 2.2 2.2 2.2 2.2-1 2.2-2.2-1-2.2-2.2-2.2m0 4c-1 0-1.8-.8-1.8-1.8s.8-1.8 1.8-1.8 1.8.8 1.8 1.8-.8 1.8-1.8 1.8" fill-rule="nonzero" mask="url(#j)"/></g></svg>
  """
)
let targetLogoSVG = base64EncodedString(
  """
  <svg height="47" viewBox="0 0 242 47" width="242" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m23.4889477 39.1743808c-8.652212 0-15.67379188-7.0120552-15.67379188-15.66776 0-8.6713761 7.02157988-15.67832896 15.67379188-15.67832896 8.6597422 0 15.6725774 7.00695286 15.6725774 15.67832896 0 8.6557048-7.0128352 15.66776-15.6725774 15.66776zm0-39.1743808c-12.9707271 0-23.4889477 10.5233672-23.4889477 23.5066208 0 12.973292 10.5182206 23.4933792 23.4889477 23.4933792 12.9763141 0 23.5110523-10.5200872 23.5110523-23.4933792 0-12.9832536-10.5347382-23.5066208-23.5110523-23.5066208z" fill-rule="nonzero"/><path d="m22.9940287 16c-4.4159686 0-7.9940287 3.5708284-7.9940287 8.0019912 0 4.4165605 3.5779395 7.9980088 7.9940287 7.9980088 4.4201908 0 8.0059713-3.581569 8.0059713-7.9980088 0-4.4310421-3.5857805-8.0019912-8.0059713-8.0019912"/><path d="m65.2422746 12.2879461h-10.2422746v-6.2879461h28v6.2879461h-10.2422746v27.7120539h-7.5154508z"/><path d="m80 40h7.5033583l2.6460432-7.5733352h12.6060015l2.550375 7.5733352h7.694222l-12.606002-34h-7.5995005zm16.4763196-25.6222815h.092827l4.2473094 12.4779713h-8.7281067z" fill-rule="nonzero"/><path d="m115 39.9995223h7.662958v-13.2853028h7.65415c3.85766 0 5.269477 1.570142 5.804842 5.1398626.394917 2.7151467.295576 6.0016016 1.223411 8.1459179h7.654639c-1.364348-1.904042-1.313944-5.9094089-1.462221-8.0513368-.245172-3.4335811-1.313944-7.0009132-5.073242-7.9524566v-.0941034c3.858639-1.5228515 5.515627-4.5193532 5.515627-8.5247201 0-5.1389072-3.954554-9.3773831-10.196887-9.3773831h-18.782788zm7.662958-28.1918597h8.392112c3.409402 0 5.264583 1.4292257 5.264583 4.7113815 0 3.4268935-1.855181 4.85803-5.264583 4.85803h-8.392112z" fill-rule="nonzero"/><path d="m174.576044 36.4058276c-2.574304 3.3265394-5.935252 4.5941724-9.163452 4.5941724-10.331926 0-16.412592-7.7320452-16.412592-17.3704677 0-9.913444 6.080197-17.6295323 16.412592-17.6295323 6.825095 0 13.280555 4.2102687 14.07752 11.7832144h-7.017886c-.843403-3.6996486-3.601586-5.6107192-7.059634-5.6107192-6.593838 0-9.075733 5.6107192-9.075733 11.4570371 0 5.5703577 2.481895 11.1820157 9.075733 11.1820157 4.770999 0 7.524022-2.5714037 7.947131-7.2059376h-7.384705v-5.4675767h14.024982v18.0594293h-4.679529z"/><path d="m186 6h25.611595v6.2879461h-18.07982v7.2819612h16.596953v5.8145827h-16.596953v8.3275639h18.468225v6.2879461h-26z"/><path d="m224.24135 12.2879461h-10.24135v-6.2879461h28v6.2879461h-10.246631v27.7120539h-7.512019z"/></g></svg>
  """
)
let hyundaiLogoSVG = base64EncodedString(
  """
  <svg height="43" viewBox="0 0 339 43" width="339" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m316.843438 11.2490137h-13.870308c-2.328286.1377922-2.978528.7154244-2.978528 3.5433586v7.7957541h16.848836zm7.385217-6.24262598v33.99361228h-7.385217v-9.7713841h-16.848836v9.7713841h-7.385217v-26.6495612c0-4.70866097 1.906039-7.34405108 7.385217-7.34405108zm-39.003574 7.33766338v18.396629c0 5.8566252-3.287689 8.2529322-7.386129 8.2529322h-23.294713v-33.9936123h23.294713c6.29084 0 7.386129 4.00236185 7.386129 7.3440511zm-7.473679 2.045895c0-1.8624762-1.134504-3.1473202-3.120797-3.1473202h-12.700238v21.2400763l12.700238-.0009126c2.892802-.1469175 3.120797-1.8825518 3.120797-3.2595614zm-173.751402-9.3899461h7.385217v13.3986956h16.523259v-13.3986956h7.385217v33.9926998h-7.385217v-13.8722994h-16.523259v13.8722994h-7.385217zm43.951067 0 9.258425 13.8969377 9.147162-13.8969377h8.967503l-14.425705 21.7328431v12.2607692h-7.386129v-12.2625943l-14.526022-21.731018zm68.828979 0h23.799038c3.391655 0 6.675696.47634129 6.579938 7.3440511v26.6495612h-7.385216v-24.2076277c0-2.9274001-.351113-3.5433587-2.646567-3.5433587h-12.960153v27.7509864h-7.38704zm122.219954.00638772v33.99361228h-7.387041v-33.99361228zm-159.982323 33.98722458h23.797214c4.731354 0 6.676608-1.3697094 6.58085-8.1954427v-25.7981696h-7.385216v24.2669422c0 2.9091495-.351113 3.2622991-2.646567 3.2622991h-12.960153l-.000911-27.5292413h-7.385217z"/><path d="m51.3982033 26.4690798c.6471541 3.3202444-1.1057815 6.0781168-2.5623313 8.7550077-1.6178853 2.4906332-4.2880757 4.6312461-7.4975611 4.3109189-7.2020818-.1070756-14.2410155-1.2048258-20.7687518-3.1600808-.2963857-.0800818-.5927714-.268139-.7550131-.5353782-.1350504-.3752146.0543827-.7234354.323577-.9636807 5.9612499-4.7932092 13.0545663-7.0148037 20.067215-9.3452733 2.6158077-.7495295 5.3947635-1.5530466 8.3341483-1.177832 1.2127341.1610633 2.4263746.9915743 2.858717 2.1163184zm24.5710087-14.1906707c3.3445358 2.7308785 6.3654946 6.4533314 5.3403808 10.9514078-1.6722679 6.6404889-8.954111 10.1748846-14.7531192 12.4234729-3.1560092 1.0446623-6.3383033 2.1163184-9.7906981 2.4375453-.2157181-.0269939-.5664864.0260941-.6208691-.2951328l.0806676-.3743149c4.9089448-5.4896507 8.630534-11.6469495 11.8953085-17.8861297 1.5100262-2.8118601 2.9130998-5.7029022 4.2074079-8.5417562.1885267-.2141513.3779598-.3212269.5936778-.4013087 1.2127341.1061758 2.0765126 1.0437625 3.0472438 1.6862163zm-47.0664111-7.06879141-.107859.40130868c-7.0933163 8.00547823-11.7593517 17.29676383-16.1824777 26.53406183-.8628721.8035171-1.6994592-.268139-2.4816637-.6163598-3.93821359-2.5698152-7.49846745-6.7205706-6.47335362-11.6469496 1.64507656-6.4254377 8.30695692-9.8527578 13.86396212-12.18142789 3.2901531-1.23181968 6.716263-2.22249424 10.3299932-2.78486626.3779597-.0008998.8628721-.05398772 1.0513987.29423304zm35.1992003 1.2849076c.4042447.21415127.8900635.29423305 1.1329729.69554172.215718.45529639-.2157181.74952944-.4586274 1.04466227-5.5832902 4.33701302-11.9750698 6.74756452-18.5028061 8.86298312-3.3182509.8035171-6.6627867 2.2494881-10.3571846 1.4459709-.8637785-.2141512-1.6450765-.7765233-2.1308953-1.6070343-.9172548-2.5167272.3235771-5.1405302 1.4021672-7.33603054 1.4293585-2.75787241 3.965405-5.99803506 7.4712761-6.05112298 7.5519438-.05398772 14.6724515 1.07075633 21.4430972 2.94502981zm9.3320707.21415127c5.7183406 3.10609316 12.1916942 8.56785024 11.5173488 15.85079294-.7822045 6.7475645-7.1205077 11.4597921-12.7844656 14.2986461-16.5341525 7.8453147-39.7564702 8.08556-56.8299178 1.2318197-5.77272321-2.3826578-12.24607685-6.4794255-14.67426424-12.6385239-1.8607946-5.0604484.40424471-10.3350481 4.20831433-13.84245 7.95618851-7.175867 18.09765501-9.63860657 28.53641361-11.05848345 11.328822-1.36588917 23.2495091-.16106335 33.3909756 3.29325057 2.2659457.83051101 4.5047 1.74110379 6.6355953 2.86494804z"/></g></svg>
  """
)
let twitchLogoSVG = base64EncodedString(
  """
  <svg height="130" viewBox="0 0 211 130" width="211" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd" transform="matrix(1 -0 -0 -1 0 130)"><path d="m46.9401885 27.6595738-8.4042945-8.3906854h-13.2017356l-7.2020101-7.1896452v7.1896452h-10.80270721v34.7551764h39.61074741zm-44.41372906 31.1582025-2.4002596-9.5880376v-43.1427885h10.80393846v-5.99352231h5.9997256l6.0034192 5.99352231h9.6010385l19.2045392 19.1723872v33.5584389z" transform="translate(128.701686 70.935558)"/><path d="m149.234094 100.990021h4.801135v14.383593h-4.801135zm13.202351 0h4.801135v14.383593h-4.801135z"/><path d="m205.613416 45.6382967-8.400601 8.3869974h-15.605689v10.7872338h-13.205429v-49.1356962h13.205429v25.1683682h10.80086v-25.1683682h13.20543zm-42.009776 8.3869974h-20.404977l-8.402448-8.3869974v-21.5707796l8.402448-8.3906854h20.404977v13.1813236h-15.605689v11.9870446h15.605689zm-33.608559 0h-10.800861v10.7872338h-13.205429v-40.7450108l8.402448-8.3906854h15.603842v13.1813236h-10.800861v11.9870446h10.800861zm-28.807425 10.7872338h-13.2017355v-5.9941369h13.2017355zm0-10.7872338h-13.2017355v-38.3478477h13.2017355zm-18.0028703 0h-13.2029669v-25.1671388h-4.7999036v25.1671388h-13.2035824v-25.1671388h-4.799288v25.1671388h-13.2054293v-38.3484624h40.8105694l8.4006008 8.3906854zm-54.012305 0h-10.8014761v10.7872338h-13.2029668v-40.7450108l8.401832-8.3906854h15.6026109v13.1813236h-10.8014761v11.9870446h10.8014761zm181.2383763-5.9898343v-35.951914l-18.002871-11.98520066h-12.001913v5.99413697l-8.401832-5.99413697h-10.800861v5.99413697l-5.999725-5.99413697h-19.205155l-6.003419 5.99413697-1.201669-5.99413697h-16.801202l-6.870812 5.99413697-.384756-5.99413697h-19.0438651l-.6734763 5.99413697-5.15511-5.99413697h-29.0875267l-6.002188 2.39716306v-2.39716306h-15.6019952l-18.0047173 10.78846306-10.80147603 10.7804726v47.9377293h22.80646773l10.8008604-10.7866191h49.2111702v10.7866191h40.8087223v-10.7866191h10.802707v-5.9904491l6.00342 5.9904491h12.000067l10.803938 10.7866191h22.804621v-10.7866191h13.203582z" transform="translate(.034289 .22392)"/></g></svg>
  """
)
let fordLogoSVG = base64EncodedString(
  """
  <svg height="61" viewBox="0 0 169 61" width="169" xmlns="http://www.w3.org/2000/svg"><path d="m84.5000025 0c46.6905775 0 84.4999975 13.6322117 84.4999975 30.5006403 0 16.8620234-37.810059 30.4993597-84.4999975 30.4993597-46.6841921 0-84.5000025-13.6366957-84.5000025-30.4993597 0-16.867788 37.8132555-30.5006403 84.5000025-30.5006403zm.0031984 58c45.0077481 0 81.4967991-12.5358288 81.4967991-27.9993623 0-15.4667212-36.487772-28.0006377-81.4967991-28.0006377-45.0128684 0-81.5032009 12.534554-81.5032009 28.0006377 0 15.4641711 36.489693 27.9993623 81.5032009 27.9993623zm0-53.5740602c43.4287161 0 78.6316541 11.4481407 78.6316541 25.5746979 0 14.1265567-35.20038 25.57661-78.6316541 25.57661-43.4332002 0-78.63805396-11.4494158-78.63805396-25.57661 0-14.1265572 35.20613286-25.5746979 78.63805396-25.5746979zm-20.4151912 4.57429466c-1.1544074.00359815-2.3147469.04801948-3.4828277.14255416-7.7584812.63946834-15.1432805 4.91705138-15.1566845 11.41147598-.0082978 3.2932942 2.3826128 5.9617922 6.0872803 5.8443771 4.3531749-.1445584 7.9268569-3.559735 9.7977007-7.8655742.7097848-1.6337064-.6047905-2.3122929-1.2303201-1.3717127-1.0895105 1.6431303-2.6071403 2.9650738-4.3928687 3.8264429-2.0482901.9822436-4.2376628.7172256-4.9014897-.9114307-.9331878-2.2977937 1.0066197-5.7361525 5.4331988-7.3540769 6.3938056-2.3179944 13.0836411-.7846409 19.5208559.399607.0919133 0 .4348012.1862307.1316084.3408897-1.1527657.6154807-2.2876912 1.1159867-4.0557656 2.6057647-1.2676574 1.063046-2.9271911 2.4783436-4.2107992 4.019885-1.2740339 1.5194482-2.177108 2.8746814-3.3719974 4.3770851-.1665955.2171544-.3716497.2071434-.3690965.2071434-2.9125418.4816523-5.7637933.8043184-8.3744213 2.5819519-.5399986.3648691-.7743859 1.012528-.4469395 1.5080685.2942535.4393584.9672615.4859941 1.4344934.1533183 1.6219093-1.1880348 3.2917092-1.7472847 5.2065954-1.7990475.0836169.00505.1238239.0183316.1474405.06883.0146806.0284064.0057446.0882537-.0286974.1324415-2.8684999 3.896781-3.5868244 4.7774155-5.7449018 7.1932554-1.1036125 1.2416927-2.1892546 2.2896928-3.402016 3.3805139-4.8995557 4.4573414-10.169473 4.3803038-12.0601043 1.5857065-1.1297828-1.6772635-.9808794-3.4379542-.2404568-4.8986951.9114861-1.7889968 2.7534308-3.100193 4.2853397-3.865914.5687208-.284068.7323029-.9961394.1629432-1.6450765-.3619133-.4229452-1.2396927-.4981016-1.893307-.3806871-2.0068015.362976-4.3781473 1.8485277-5.779206 3.6362625-1.5791427 2.00615-2.36798 4.4416226-2.1030883 7.1749876.4755309 4.9320506 4.6225735 7.7809635 9.3306411 7.7481383 3.7463017-.0286589 7.2750579-1.1401814 11.5211385-5.3609339 3.95807-3.9365506 7.5640271-9.8167192 10.9406112-15.2695611.1059556-.1742286.1811331-.2676308.6943223-.3301249 2.1178685-.2594485 5.2450796-.5547775 7.2493267-.6684038.4455307-.0239876.5360526-.019127.714773.1986619.5221252.6451503 1.3064524 1.1927036 1.9345333 1.5260101.3063842.1628653.452035.2441317.6926756.2479192.2968035.0063126.5278124-.1500547.6771715-.3154451.212556-.2285164.2712401-.5274107.1563485-.719945-.1200044-.2020044-1.5176872-.9605322-1.5591759-1.267326-.0306377-.1912724.1830608-.2374809.1830608-.2374809 1.027655-.3156307 2.0967667-.9652066 2.7446345-2.1803867.6363787-1.1962418.7390791-2.7927465-.4251694-3.6803007-1.0219104-.7796086-2.5659142-.6565842-3.7978274.42603-1.2050988 1.0510509-1.6038559 2.5802217-1.4410927 3.9203912.0293612.2323046.0171699.310462-.3064225.3369747-1.8523347.1451903-3.6371004.1955864-5.6221988.2984821-.1327637.0094688-.1748651-.0764228-.0976324-.1666933 2.2857317-3.8885748 5.6985762-6.6576814 9.4734636-9.384734.2502086-.1836967.173812-.5330156.1635994-.8246586 6.8157191 1.450009 13.4024143 4.1487693 20.4734483 4.0913252 2.9240376-.0233564 5.7234246-.4588748 8.3991626-1.8962581 2.35339-1.2568428 3.308382-2.4195454 3.378594-3.627781.054893-.8351602-.538242-1.3630734-1.382709-1.1831635-7.144436 1.6071937-13.9601045 1.5894511-21.0681527.7473471-8.1184822-.964963-15.9087381-2.95146706-23.9895939-2.92642964zm14.2611588 11.26957514c.1669759.0087492.3231967.0635774.4495775.1696293.3765958.3149995.1983477 1.1009288-.1820778 1.6450765-.4155312.60033-1.1202577 1.1185648-1.7630192 1.2448174-.1289339.0233564-.2405831-.0308998-.293561-.3105522h-.0006382c-.1046791-.7404709.141872-1.7321088.9499499-2.4309162.2529276-.2189687.5614884-.3326342.839788-.3180548zm57.3530265.1419015c-1.298927 0-3.002433.0022725-4.356252.0022725-.322335 0-.488998.0385444-.641549.3320818-.499147.9374239-6.587391 9.8718624-7.721002 11.6072019-.190216.2638679-.423759.227062-.450567-.0740492-.114891-1.0302201-1.023327-2.2143924-2.455031-2.7812665-1.091483-.4336764-2.158718-.511892-3.267442-.3679648-2.002326.2632366-3.78609 1.298575-5.355025 2.4645166-2.363603 1.7605903-4.402611 4.0398408-7.035583 5.7253106-1.437442.9172238-3.405249 1.7173046-4.7220547.5242191-1.1916884-1.081983-1.057712-3.4858613.7658997-5.3442972.192131-.19506.422629-.0323076.386247.1425535-.172338.8408408.039637 1.6768021.691354 2.2632445.795312.6975449 1.933876.777076 2.907908.3112043 1.150207-.557404 1.825731-1.6351911 2.0236-2.8585774.30447-1.8969424-1.187284-3.5702864-3.052384-3.7041142-1.515951-.1041587-2.96921.412217-4.3849497 1.5573266-.7104263.5763423-1.1146472 1.0030365-1.7280539 1.8577655-.1499974.2108419-.3797233.2322692-.3720639-.0789427.0708563-2.4284651-.9556945-3.7949977-3.0065365-3.8398173-1.590637-.0366127-3.2914041.8078155-4.6165009 1.8430863-1.452767 1.142584-2.7229838 2.65639-4.084463 4.0792551-.1691461.1754911-.3172478.1673586-.3644811-.172891-.0414886-1.6090875-.4546264-3.1677264-1.2154774-4.2743289-.2687252-.3850699-.8349625-.5758518-1.311131-.3157715-.2195708.1180464-.9847494.4622653-1.5407038.9009918-.2763847.2228357-.3831702.5452543-.2618956.9587313.7340429 2.4032142.5725499 5.1365856-.4231908 7.4457418-.9146781 2.1134656-2.6922694 4.0212839-4.780764 4.6664335-1.3761661.4273645-2.8072952.2183059-3.6926122-.9766728-1.2159497-1.6488571-.7243154-4.5159571 1.0871689-6.8977093 1.6002049-2.0957899 3.9128085-3.4278611 6.2215249-4.2857464.2719103-.102265.3272753-.2724568.2506808-.4984488-.1257425-.3724448-.3253477-.8777666-.4076867-1.10944-.211273-.5510921-.8043247-.6413362-1.5275104-.5636907-1.6768058.1912724-3.1888824.7537045-4.6831317 1.5371012-3.912751 2.0516015-5.8736839 6.0222651-6.7341013 8.1470932-.4136164 1.0194882-.7677189 1.6571417-1.2253772 2.2214902-.6165917.7594078-1.3909054 1.4500399-2.8066448 2.6677444-.1276593.1117331-.2233385.344537-.1161057.560429.1448931.2935368.8807322 1.3111483 1.088817 1.4020501.2304248.1111019.4977012-.0439668.6049347-.1197192.9906305-.657144 2.1759744-1.6994369 2.7561837-2.4064507.2029753-.2417727.4126207-.140026.5204912.2273688.5412803 1.8912611 1.9586798 3.4351054 3.918885 4.0808862 3.5872182 1.1848793 7.3084895-.5299994 10.1169911-3.5152386 1.7846699-1.896943 2.4288228-3.1173359 3.1130666-3.9468142 1.1591485-1.4070831 3.4467951-4.5544175 6.1704044-6.5750875.9989321-.744889 2.181742-1.3130862 2.7766319-.936222.4768069.3030056.630717 1.0067148-.1352402 2.3702413-2.7765809 4.966139-6.8644396 10.8009671-7.613795 12.2168884-.1365935.2455609-.0172976.4381002.2450703.4381002 1.4533989-.0063125 2.8947342-.0032825 4.2140928-.0032825.2189324-.0101001.3180265-.1078554.4278119-.2599895 2.1312662-3.2667815 4.1373834-6.3775113 6.2871663-9.5925294.1212745-.1893787.2316982-.0425717.2361662.0401225.0446801.7455209.2315259 1.7663877.6834395 2.4367881.8131906 1.2385358 1.9648329 1.7706165 3.2426966 1.7788228 1.016166.0113626 1.529936-.1400045 2.625894-.5408557.766754-.281847 1.492267-.6631488 2.157512-1.1339061.321065-.2177851.377068.1473725.368771.2035553-.492764 2.5938561.116264 5.6665763 2.748592 6.9410948 3.150623 1.521342 6.611524-.6166264 8.603006-2.5463946.194684-.1862224.404718-.1666542.424505.2335665.042127.7373139.381728 1.6117747 1.004709 2.2240991 1.668501 1.6400189 5.036213.990287 8.415981-1.5720057 2.170208-1.6393877 4.4405-3.9566353 6.491342-6.4103518.075962-.0946887.13263-.2481881-.01417-.4022166-.312761-.3200495-.7644-.6863433-1.073976-.968517-.141061-.1174151-.348689-.0837888-.468049.0052394-2.101912 1.9575441-3.993756 4.1903987-6.729487 6.0368414-.922337.6299995-2.391744 1.1388324-3.052384.2639032-.25723-.3396189-.227671-.8100994.025723-1.4268419.79851-1.9480752 13.423197-20.771057 14.078092-21.8795533l.001277-.0013256c.112338-.1931662-.006383-.334365-.255303-.334365zm-17.689891 11.7676969c.330562-.0028406.640074.0594578.921916.1921379 1.554887.7265826 1.058261 2.4897112.36316 3.8740692-.047698.0875691-.057795.1904262-.028021.285434.025532.1439278.216743.2834147.405044.349697.065744.0239876.103052.0706461.028404.2221489-.53745 1.1268026-1.030253 1.7763868-1.703652 2.7548429-.617862.9045987-1.315044 1.6097774-2.160149 2.2890154-1.273402 1.0321132-3.041342 2.1550822-4.503039 1.4000932-.649782-.3307814-.93006-1.2203532-.917295-1.9406233.033829-2.0263513.951157-4.1056837 2.650302-6.1497095 1.683425-2.0290348 3.510962-3.2646618 4.943374-3.2771057z" fill="#7d7d7d" fill-rule="evenodd"/></svg>
  """
)
let appleLogoSVG = base64EncodedString(
  """
  <svg height="93" viewBox="0 0 78 93" width="78" xmlns="http://www.w3.org/2000/svg"><path d="m76.3652412 72.4752345c-1.4004097 3.2491632-3.0580383 6.2399966-4.978602 8.9897274-2.6179113 3.7485881-4.7613961 6.3433252-6.4133093 7.7842113-2.5607494 2.3651108-5.3044107 3.5763707-8.2424153 3.6452558-2.109189 0-4.6527924-.6027609-7.6136603-1.825497-2.9705837-1.2170072-5.7005269-1.8197588-8.1966878-1.8197588-2.6179104 0-5.4255916.6027516-8.4287562 1.8197588-3.0077418 1.2227361-5.4307365 1.8599442-7.2832798 1.9230912-2.8173979.1205493-5.6256476-1.1251605-8.4287562-3.74285-1.7890947-1.5671801-4.0268931-4.253764-6.7076799-8.0597609-2.87627079-4.0643231-5.24096393-8.7773239-7.09350709-14.1504944-1.98400999-5.8037131-2.97858731-11.4237271-2.97858731-16.8646342 0-6.2325324 1.34096463-11.6079991 4.02689463-16.1126222 2.11090434-3.6182774 4.91915595-6.4724873 8.43389867-8.5677958 3.5147464-2.0953048 7.3124308-3.1630498 11.4022021-3.2313639 2.2377966 0 5.1723731.6951824 8.8191552 2.0614379 3.636495 1.3708469 5.9714656 2.0660303 6.9951924 2.0660303.765367 0 3.3592705-.8128665 7.7565599-2.4334258 4.158364-1.5028809 7.6679627-2.1251597 10.543091-1.8800377 7.7908558.6314625 13.644 3.7158697 17.5365702 9.2727375-6.9677564 4.2399833-10.4144816 10.1785985-10.3458908 17.7969034.0628754 5.9340228 2.2063603 10.8720566 6.4190238 14.7928667 1.9091293 1.819756 4.0411853 3.226195 6.4133029 4.2250549-.5144294 1.4982876-1.0574457 2.9334292-1.6347588 4.3111655zm-17.8680933-70.61470448c0 4.65106093-1.6919272 8.99374408-5.0643416 13.01328668-4.0697676 4.7784496-8.9923503 7.5396604-14.3304883 7.1039526-.0680194-.5579842-.1074592-1.1452429-.1074592-1.7623527 0-4.4650145 1.9354243-9.2434621 5.3724337-13.15049148 1.7159286-1.97819734 3.8982828-3.62304177 6.5447737-4.93516569 2.6407737-1.2925465 5.1386496-2.0073519 7.4879076-2.12975943.0685954.62177472.0971741 1.24358758.0971741 1.86046957z" fill="#7d7d7d"/></svg>
  """
)
let squarespaceLogoSVG = base64EncodedString(
  """
  <?xml version="1.0" encoding="UTF-8"?>
  <svg width="705px" height="102px" viewBox="0 0 705 102" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <defs>
          <polygon id="path-1" points="0.441008333 0.396383333 33.6288333 0.396383333 33.6288333 50.8807167 0.441008333 50.8807167"></polygon>
      </defs>
      <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
          <g id="squarespace">
              <g id="squarespace-logo">
                  <g id="Group">
                      <path d="M26.1545935,54 L65.6521739,14.0187881 C68.3357,11.3024034 71.9062611,9.80874639 75.7122438,9.80874639 C79.5154239,9.80874639 83.0859849,11.3009849 85.7667084,14.0173697 L88.8440052,17.1323466 L95,10.9009742 L91.9227032,7.78599722 C87.5996338,3.40999358 81.8430149,1 75.7094412,1 C69.5786701,1.00141848 63.8206498,3.41141205 59.4975804,7.78883417 L20,47.7686276 L26.1545935,54 Z" id="Fill-1" fill="#7D7D7D"></path>
                      <path d="M79,27.2992382 L72.8148815,21.0770968 L33.1318482,60.9990813 C27.5591873,66.605099 18.4919979,66.6065153 12.920745,61.001914 C7.34808412,55.3958963 7.34808412,46.2730161 12.920745,40.6669984 L47.1634646,6.22072503 L40.9783461,0 L6.7370344,34.4462734 C-2.24567813,43.4827547 -2.24567813,58.1875742 6.7370344,67.2226391 C11.0805561,71.5921602 16.8644092,74 23.0241846,74 C29.185368,74 34.9720371,71.5907438 39.3155587,67.2212227 L79,27.2992382 Z" id="Fill-3" fill="#7D7D7D"></path>
                      <path d="M118.26188,34.7760743 C113.919747,30.4064695 108.135868,28 101.973249,28 C95.812038,28.0014164 90.0253432,30.4078859 85.6818022,34.7789071 L46,74.7002393 L52.1823302,80.9224998 L91.8669483,40.9997512 C97.4410419,35.3936262 106.506864,35.3950426 112.078141,40.9983348 C114.772967,43.709331 116.256952,47.3183271 116.256952,51.1638626 C116.256952,55.0108144 114.772967,58.6212269 112.078141,61.3322232 L77.8366772,95.7791559 L84.0218233,102 L118.26188,67.5544837 C127.24604,58.5178295 127.24604,43.8127285 118.26188,34.7760743" id="Fill-5" fill="#7D7D7D"></path>
                      <path d="M98.8455215,48 L59.348679,87.9812119 C53.8009604,93.594128 44.7780352,93.596965 39.2331191,87.9826303 L36.1558798,84.8676534 L30,91.0990258 L33.0772393,94.2140028 C37.4002279,98.5900064 43.1567393,101 49.2915997,101 C55.4222563,100.998582 61.1787676,98.5885879 65.5031576,94.2111658 L105,54.2313724 L98.8455215,48 Z" id="Fill-7" fill="#7D7D7D"></path>
                      <path d="M161.475082,61.4105051 C161.984567,63.9616431 163.178496,65.9588687 165.054072,67.397899 C166.928248,68.8397845 169.39449,69.5592997 172.452798,69.5592997 C175.462116,69.5592997 177.78839,68.8512054 179.433018,67.4335892 C181.077646,66.0174007 181.89926,64.1515152 181.89926,61.8359327 C181.89926,60.7024108 181.679509,59.7459125 181.240009,58.9664377 C180.799109,58.186963 180.186047,57.5259798 179.399425,56.9820606 C178.610004,56.4409966 177.638624,55.9784512 176.481086,55.6015623 C175.323548,55.2232458 174.026041,54.8220875 172.589966,54.3966599 L168.840215,53.3345185 C166.616118,52.7206465 164.624369,51.976862 162.864967,51.1017374 C161.104166,50.2280404 159.599506,49.2001616 158.349589,48.0195286 C157.099672,46.8388956 156.149287,45.4812391 155.501234,43.9451313 C154.853181,42.4104512 154.528454,40.6259394 154.528454,38.5958788 C154.528454,36.4701684 154.94556,34.5100606 155.779771,32.7141279 C156.612582,30.9210505 157.793915,29.3835152 159.322369,28.1086599 C160.850823,26.8338047 162.702604,25.8301953 164.880511,25.096404 C167.055619,24.3668956 169.509264,24 172.242845,24 C177.383882,24 181.458359,25.239165 184.470478,27.7189226 C187.479797,30.2001077 189.239198,33.5178721 189.750083,37.6750707 L181.41357,38.383165 C180.902685,36.2574545 179.885115,34.6042828 178.356661,33.4236498 C176.828207,32.2430168 174.697889,31.6519865 171.965708,31.6519865 C169.418284,31.6519865 167.426535,32.2544377 165.99186,33.4593401 C164.554385,34.6642424 163.836348,36.211771 163.836348,38.1004983 C163.836348,39.1869091 164.0463,40.0948687 164.463406,40.8272323 C164.880511,41.5610236 165.480975,42.1977374 166.268997,42.740229 C167.055619,43.2841481 168.017201,43.7681077 169.150945,44.1921077 C170.286088,44.6175354 171.570997,45.0686599 173.007072,45.539771 L176.55107,46.6732929 C178.772367,47.3813872 180.776714,48.1251717 182.55851,48.9046465 C184.341707,49.6841212 185.858963,50.6177778 187.108881,51.7041886 C188.360197,52.7905993 189.32178,54.0897239 189.992228,55.6015623 C190.664076,57.1134007 191,58.9792862 191,61.1992189 C191,63.5619125 190.536705,65.7233131 189.611514,67.6819933 C188.683524,69.6435286 187.388817,71.3081212 185.720395,72.6771987 C184.053372,74.0477037 182.07422,75.1112727 179.780139,75.8650505 C177.487458,76.6202559 174.952632,77 172.174261,77 C167.033224,77 162.748794,75.7722559 159.322369,73.3153401 C155.894545,70.8584242 153.788022,67.1509226 153,62.1899798 L161.475082,61.4105051 Z" id="Fill-9" fill="#7D7D7D"></path>
                      <path d="M226.860781,32.6167276 C224.36183,32.6167276 222.127326,33.0870889 220.160067,34.0249695 C218.191409,34.9642712 216.524976,36.2659359 215.160767,37.9313845 C213.79376,39.5982542 212.751364,41.5706456 212.033581,43.8442956 C211.317196,46.1222087 210.959004,48.5976451 210.959004,51.272026 C210.959004,53.9478279 211.32839,56.4346326 212.069959,58.7352822 C212.808731,61.0345108 213.863719,63.0282176 215.229327,64.7192448 C216.593536,66.40743 218.261368,67.7332521 220.230027,68.6967113 C222.195886,69.6573285 224.43039,70.137637 226.93074,70.137637 C229.43109,70.137637 231.664195,69.681486 233.632853,68.7663419 C235.598713,67.8511977 237.266545,66.5722696 238.632153,64.9281364 C239.997761,63.2868453 241.05135,61.3030857 241.791521,58.9811206 C242.531692,56.6577345 242.902477,54.1112464 242.902477,51.3430775 C242.902477,48.6203816 242.531692,46.1094194 241.791521,43.8101908 C241.05135,41.5123833 239.997761,39.5399919 238.632153,37.8972797 C237.266545,36.2559886 235.587519,34.9642712 233.596474,34.0249695 C231.606828,33.0870889 229.361131,32.6167276 226.860781,32.6167276 M226.93074,25 C230.680565,25 234.107178,25.6465692 237.209179,26.9397077 C240.30978,28.2328461 242.94865,30.0418189 245.125787,32.3694681 C247.300126,34.6985384 248.988946,37.4837596 250.195047,40.727974 C251.398349,43.9721884 252,47.5219245 252,51.3771823 C252,55.3759643 251.363369,58.9839626 250.091507,62.2040195 C248.815447,65.4254974 247.0007,68.2107186 244.638869,70.5611043 L251.306003,78.5316687 L251.306003,81 L242.833916,81 L238.180215,75.2178238 C236.559955,75.9695493 234.822163,76.5564352 232.972436,76.9799026 C231.11991,77.4033699 229.128865,77.6151035 227.0007,77.6151035 C223.157129,77.6151035 219.696936,76.9671133 216.618721,75.6753959 C213.539107,74.3822574 210.922625,72.5718636 208.770673,70.2442144 C206.617322,67.9165652 204.950888,65.1441332 203.771373,61.9212343 C202.590458,58.7011774 202,55.1869671 202,51.3771823 C202,47.5219245 202.590458,43.9849777 203.771373,40.7620788 C204.950888,37.543443 206.628515,34.7681689 208.805653,32.4405197 C210.979992,30.1128705 213.607668,28.2911084 216.687281,26.9738124 C219.766895,25.6593585 223.180915,25 226.93074,25" id="Fill-11" fill="#7D7D7D" fill-rule="nonzero"></path>
                      <path d="M286,69.7029564 C289.552705,69.7029564 292.320413,68.5824206 294.304518,66.3384941 C296.287228,64.0945675 297.279978,60.6587334 297.279978,56.0295644 L297.279978,25 L306,25 L306,56.2422521 C306,59.9264597 305.538483,63.0782344 304.615449,65.700431 C303.691021,68.3212001 302.377579,70.470916 300.670943,72.1481512 C298.964306,73.8253864 296.864473,75.0529798 294.374233,75.8323588 C291.882599,76.6117379 289.091188,77 286,77 C282.861405,77 280.05884,76.6117379 277.592303,75.8323588 C275.122978,75.0529798 273.035694,73.8253864 271.329057,72.1481512 C269.622421,70.470916 268.307585,68.3212001 267.383157,65.700431 C266.460123,63.0782344 266,59.9264597 266,56.2422521 L266,25 L274.720022,25 L274.720022,56.0295644 C274.720022,60.6587334 275.711378,64.0945675 277.695482,66.3384941 C279.679587,68.5824206 282.447295,69.7029564 286,69.7029564" id="Fill-13" fill="#7D7D7D"></path>
                      <path d="M330.982023,54.2032215 L347.667612,54.2032215 L344.921434,46.26462 C343.840551,43.1554046 342.973859,40.6242564 342.317103,38.6753844 C341.658928,36.7251094 341.071677,35.007745 340.556768,33.521888 L338.375145,33.521888 C338.092867,34.3104164 337.810589,35.100348 337.52973,35.8888764 C337.247453,36.6788079 336.931131,37.5613425 336.579348,38.5350769 C336.226146,39.5102144 335.84032,40.6242564 335.417612,41.8786059 C334.994905,43.1301493 334.478578,44.5935571 333.868631,46.26462 L330.982023,54.2032215 Z M315,73.5628578 L332.953711,26 L346.260479,26 L364,73.5628578 L364,76 L355.270669,76 L350.202437,61.7237064 L328.306768,61.7237064 L323.238536,76 L315,76 L315,73.5628578 Z" id="Fill-15" fill="#7D7D7D" fill-rule="nonzero"></path>
                      <path d="M383.645495,48.8413077 L391.245776,48.8413077 C394.593552,48.8413077 397.230471,48.2309527 399.15934,47.013049 C401.08821,45.7937421 402.054752,43.8041252 402.054752,41.0413919 C402.054752,38.2351621 401.076971,36.280623 399.124219,35.1763715 C397.172871,34.0735232 394.547192,33.5206959 391.245776,33.5206959 L383.645495,33.5206959 L383.645495,48.8413077 Z M413,76 L404.562424,76 L389.293024,56.3620036 L383.645495,56.3620036 L383.645495,76 L375,76 L375,26 L391.245776,26 C393.801213,26 396.231617,26.1739862 398.531369,26.5219587 C400.832526,26.8699312 402.913121,27.6711099 404.773152,28.9240915 C408.722208,31.5226603 410.700248,35.4457696 410.700248,40.68921 C410.700248,42.9650624 410.363082,44.9490669 409.687345,46.6440297 C409.013013,48.3375894 408.118119,49.7757822 407.004067,50.9600112 C405.887205,52.1442402 404.597545,53.106777 403.135088,53.8476217 C401.669821,54.5912726 400.146956,55.1483092 398.56649,55.5187316 L413,73.5613863 L413,76 Z" id="Fill-17" fill="#7D7D7D" fill-rule="nonzero"></path>
                      <polygon id="Fill-19" fill="#7D7D7D" points="424 26 456.509796 26 456.509796 33.6593894 432.599693 33.6593894 432.599693 46.7514873 454.832117 46.7514873 454.832117 54.2719722 432.599693 54.2719722 432.599693 68.3392075 457 68.3392075 457 76 424 76"></polygon>
                      <path d="M476.476169,61.4105051 C476.984236,63.9616431 478.178122,65.9588687 480.053628,67.397899 C481.929134,68.8397845 484.395285,69.5592997 487.452081,69.5592997 C490.461289,69.5592997 492.787477,68.8512054 494.433444,67.4335892 C496.076611,66.0174007 496.899595,64.1515152 496.899595,61.8359327 C496.899595,60.7024108 496.679853,59.7459125 496.238969,58.9664377 C495.799484,58.186963 495.185046,57.5259798 494.398453,56.9820606 C493.61046,56.4409966 492.637716,55.9784512 491.481621,55.6015623 C490.322726,55.2232458 489.025267,54.8220875 487.589245,54.3966599 L483.839632,53.3345185 C481.617017,52.7206465 479.623941,51.976862 477.864604,51.1017374 C476.103867,50.2280404 474.599263,49.2001616 473.350792,48.0195286 C472.099521,46.8388956 471.149171,45.4812391 470.501142,43.9451313 C469.853112,42.4104512 469.528398,40.6259394 469.528398,38.5958788 C469.528398,36.4701684 469.945488,34.5100606 470.779669,32.7141279 C471.612449,30.9210505 472.793738,29.3835152 474.322136,28.1086599 C475.850534,26.8338047 477.702247,25.8301953 479.880074,25.096404 C482.055101,24.3668956 484.510055,24 487.242136,24 C492.382983,24 496.457311,25.239165 499.469319,27.7189226 C502.478527,30.2001077 504.239263,33.5178721 504.748729,37.6750707 L496.412523,38.383165 C495.903057,36.2574545 494.884125,34.6042828 493.357127,33.4236498 C491.828729,32.2430168 489.69709,31.6519865 486.965009,31.6519865 C484.41768,31.6519865 482.426004,32.2544377 480.991381,33.4593401 C479.555359,34.6642424 478.837348,36.211771 478.837348,38.1004983 C478.837348,39.1869091 479.045893,40.0948687 479.462983,40.8272323 C479.880074,41.5610236 480.480516,42.1977374 481.268508,42.740229 C482.055101,43.2841481 483.016648,43.7681077 484.15175,44.1921077 C485.286851,44.6175354 486.571713,45.0686599 488.006335,45.539771 L491.550203,46.6732929 C493.772818,47.3813872 495.775691,48.1251717 497.558821,48.9046465 C499.340552,49.6841212 500.859153,50.6177778 502.107624,51.7041886 C503.358895,52.7905993 504.320442,54.0897239 504.992265,55.6015623 C505.662689,57.1134007 506,58.9792862 506,61.1992189 C506,63.5619125 505.536722,65.7233131 504.610166,67.6819933 C503.68221,69.6435286 502.387551,71.3081212 500.71919,72.6771987 C499.052228,74.0477037 497.073149,75.1112727 494.780552,75.8650505 C492.486556,76.6202559 489.951823,77 487.173554,77 C482.034107,77 477.748435,75.7722559 474.322136,73.3153401 C470.894438,70.8584242 468.787993,67.1509226 468,62.1899798 L476.476169,61.4105051 Z" id="Fill-21" fill="#7D7D7D"></path>
                      <path d="M527.86012,49.2587833 L536.366065,49.2587833 C537.925583,49.2587833 539.355141,49.1325065 540.65474,48.8785498 C541.95291,48.6259962 543.088274,48.2008643 544.056546,47.601751 C545.026247,47.0040409 545.781728,46.1986755 546.325845,45.185655 C546.868535,44.1740375 547.13988,42.9309126 547.13988,41.4576832 C547.13988,39.9395555 546.868535,38.6641598 546.325845,37.6286901 C545.781728,36.5932203 545.036244,35.7766304 544.092249,35.1775171 C543.146827,34.5784039 542.024317,34.153272 540.726146,33.9007184 C539.42512,33.6481648 538.019839,33.5204849 536.508878,33.5204849 L527.86012,33.5204849 L527.86012,49.2587833 Z M519,26 L537.571407,26 C541.020341,26 543.915161,26.3942642 546.254439,27.1841958 C548.593716,27.9727242 550.483133,29.0629139 551.925544,30.457571 C553.3651,31.8494219 554.406207,33.485408 555.043153,35.3669323 C555.680099,37.2456505 556,39.2773039 556,41.4590863 C556,44.0603884 555.562992,46.3221461 554.688976,48.2485689 C553.814961,50.1749916 552.551065,51.7646762 550.89729,53.0190257 C549.242087,54.2719722 547.234136,55.2120328 544.872009,55.8392075 C542.508453,56.4663823 539.839277,56.7792682 536.863054,56.7792682 L527.86012,56.7792682 L527.86012,76 L519,76 L519,26 Z" id="Fill-23" fill="#7D7D7D" fill-rule="nonzero"></path>
                      <path d="M573.982023,54.2032215 L590.667612,54.2032215 L587.921434,46.26462 C586.840551,43.1554046 585.972441,40.6242564 585.315684,38.6753844 C584.658928,36.7251094 584.071677,35.007745 583.556768,33.521888 L581.373726,33.521888 C581.092867,34.3104164 580.810589,35.100348 580.528312,35.8888764 C580.247453,36.6788079 579.929713,37.5613425 579.57793,38.5350769 C579.226146,39.5102144 578.84032,40.6242564 578.417612,41.8786059 C577.994905,43.1301493 577.478578,44.5935571 576.868631,46.26462 L573.982023,54.2032215 Z M558,73.5628578 L575.953711,26 L589.259061,26 L607,73.5628578 L607,76 L598.270669,76 L593.202437,61.7237064 L571.306768,61.7237064 L566.237118,76 L558,76 L558,73.5628578 Z" id="Fill-25" fill="#7D7D7D" fill-rule="nonzero"></path>
                      <path d="M660,62.7802625 C659.205666,64.7324043 658.163985,66.5693837 656.879199,68.2926052 C655.591586,70.0158267 654.036839,71.5255766 652.213545,72.8148328 C650.390251,74.104089 648.272968,75.1236969 645.864524,75.8736563 C643.456079,76.6236158 640.779088,77 637.832135,77 C634.090849,77 630.68878,76.3483498 627.625928,75.0464538 C624.563077,73.7473667 621.948275,71.9454978 619.782937,69.6464646 C617.617598,67.3446227 615.945539,64.6046022 614.766758,61.4207854 C613.587977,58.238373 613,54.7877167 613,51.0688165 C613,47.3527251 613.587977,43.9020688 614.766758,40.718252 C615.945539,37.5358397 617.627492,34.781775 619.816859,32.4574623 C622.006225,30.1359585 624.633747,28.3102144 627.696599,26.9872522 C630.75945,25.6614811 634.184134,25 637.973476,25 C643.490001,25 648.110426,26.2794253 651.827685,28.8340626 C655.546357,31.3886998 658.176706,34.781775 659.720146,39.0104791 L650.811446,40.7519581 C649.594503,38.1973208 647.898415,36.1861935 645.724596,34.7227894 C643.549364,33.2593853 640.919015,32.5276832 637.832135,32.5276832 C635.354434,32.5276832 633.143867,33.0023767 631.20326,33.9517636 C629.262653,34.9011505 627.625928,36.2086642 626.293086,37.875709 C624.960244,39.5413493 623.942592,41.5089397 623.241542,43.77848 C622.540493,46.0466159 622.189968,48.4762599 622.189968,51.0688165 C622.189968,53.7077189 622.5518,56.1500027 623.276877,58.3956679 C624.000541,60.6427375 625.053529,62.5850483 626.433014,64.2296224 C627.812498,65.8727921 629.484558,67.1564306 631.449193,68.0819424 C633.412414,69.0088586 635.658317,69.4723168 638.18266,69.4723168 C641.457523,69.4723168 644.157129,68.6816291 646.285719,67.1016583 C648.414308,65.5216875 650.06234,63.5934208 651.231227,61.315454 L660,62.7802625 Z" id="Fill-27" fill="#7D7D7D"></path>
                      <g id="Group-31" transform="translate(671.000000, 25.000000)">
                          <g id="Fill-29-Clipped">
                              <mask id="mask-2" fill="white">
                                  <use xlink:href="#path-1"></use>
                              </mask>
                              <g id="path-1"></g>
                              <polygon id="Fill-29" fill="#7D7D7D" mask="url(#mask-2)" points="0.441008333 0.396383333 33.1362583 0.396383333 33.1362583 8.12996667 9.08975833 8.12996667 9.08975833 21.3488833 31.4490083 21.3488833 31.4490083 28.9422167 9.08975833 28.9422167 9.08975833 43.1457167 33.6292583 43.1457167 33.6292583 50.8807167 0.441008333 50.8807167"></polygon>
                          </g>
                      </g>
                  </g>
              </g>
          </g>
      </g>
  </svg>
  """
)
let foxLogoSVG = base64EncodedString(
  """
  <svg height="423" viewBox="0 0 1000 423" width="1000" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m0 0v422.39016h127.84344v-136.32469h116.23375v-115.5737h-116.23375v-55.28327h142.52695l-7.73915-115.2085z"/><path d="m475.47971 0c-117.00234 0-211.19605 94.19368-211.19606 211.19606.00001 117.00233 94.19371 211.1941 211.19606 211.1941s211.1941-94.19177 211.1941-211.1941c0-117.00238-94.19175-211.19606-211.1941-211.19606zm0 86.988239c19.75546 0 35.65729 15.901801 35.65729 35.657281v177.0991c0 19.75548-15.90184 35.65925-35.65729 35.65925-19.75546 0-35.65924-15.90377-35.65924-35.65925v-177.0991c0-19.75548 15.90378-35.657281 35.65924-35.657281z" fill-rule="nonzero"/><path d="m623.31711 0 119.83765 211.19489-119.83765 211.19489h137.00949l51.33194-90.46856 51.33387 90.46856h137.00759l-119.83574-211.19489 119.83574-211.19489h-137.00759l-51.33387 90.466616-51.32998-90.466616z"/></g></svg>
  """
)
let doximityLogoSVG = base64EncodedString(
  """
  <svg height="266" viewBox="0 0 1085 266" width="1085" xmlns="http://www.w3.org/2000/svg"><g fill="#7d7d7d" fill-rule="evenodd"><path d="m543.6 89.7h-18c-3.1 0-5.6 2.5-5.6 5.6v122.4c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-122.4c0-3.1-2.5-5.6-5.6-5.6z"/><path d="m737.6 86.9c-18.4 0-33.1 7.7-44.9 23.5l-.9 1.2-.7-1.3c-7.5-15.1-21.6-23.3-39.7-23.3-21.2 0-32.8 12.3-40.6 23l-1.7 2.3v-16.9c0-3.1-2.5-5.6-5.6-5.6h-18c-3.1 0-5.6 2.5-5.6 5.6v122.4c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-69.9c0-21 11.7-34.5 29.9-34.5 18 0 28.4 12.3 28.4 33.8v70.7c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-69.9c0-21.3 11.5-34.5 29.9-34.5 24.7 0 28.4 21.3 28.4 34v70.5c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-79.9c0-32.7-16.9-51.2-46.5-51.2z"/><path d="m834.8 89.8h-18c-3.1 0-5.6 2.5-5.6 5.6v122.4c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-122.4c0-3.1-2.5-5.6-5.6-5.6z"/><path d="m936.6 89.8h-30.9v-31.6c0-3.1-2.5-5.6-5.6-5.6h-18c-3.1 0-5.6 2.5-5.6 5.6v31.6h-11.5c-3.1 0-5.6 2.5-5.6 5.6v13.7c0 3.1 2.5 5.6 5.6 5.6h11.6v72.2c0 26.1 12.4 38.8 38.1 38.8 9.1 0 16.7-1.6 23.8-4.9 2-.9 3.2-2.9 3.2-5.1v-12c0-1.7-.8-3.4-2.2-4.4-1.4-1.1-3.2-1.4-4.9-.9-3.6 1-7.3 1.5-11.3 1.5-11.7 0-17.6-6-17.6-17.9v-67.4h30.9c3.1 0 5.6-2.5 5.6-5.6v-13.7c0-3-2.5-5.5-5.6-5.5z"/><path d="m1083.9 92.2c-1-1.5-2.8-2.4-4.6-2.4h-18.2c-2.4 0-4.5 1.5-5.3 3.7l-34.5 98.6-37.5-98.7c-.8-2.2-2.9-3.6-5.2-3.6h-19.1c-1.9 0-3.6.9-4.6 2.5-1 1.5-1.2 3.5-.5 5.2l52.8 127.1-.2.3c-5.9 13.2-12.3 16-20.1 16-4.2 0-8.6-.9-13-2.6-2.8-1.1-5.9.2-7.1 2.9l-5.2 11.4c-.6 1.4-.7 2.9-.1 4.3.5 1.4 1.6 2.5 3 3.1 8.2 3.6 16.4 5.2 25.7 5.2 21.3 0 33.2-10.1 43.8-37.4l50.4-130.4c.8-1.7.5-3.6-.5-5.2z"/><path d="m213.1 37.9h-18c-3.1 0-5.6 2.5-5.6 5.6v69.1l-1.7-2.2c-12-15.8-26.9-23.5-45.4-23.5-30.8 0-61.9 23.8-61.9 69.4v.5c0 45 31.9 69.4 61.9 69.4 18.6 0 33.5-8.2 45.4-25l1.7-2.4v19c0 3.1 2.5 5.6 5.6 5.6h18c3.1 0 5.6-2.5 5.6-5.6v-174.3c0-3.1-2.5-5.6-5.6-5.6zm-103.2 118.9v-.5c0-25.7 16.8-44.3 39.9-44.3 22.9 0 40.2 19 40.2 44.3v.5c0 24.8-17.6 44.3-40.2 44.3-22.7-.1-39.9-19.1-39.9-44.3z" fill-rule="nonzero"/><path d="m308.9 86.9c-40 0-71.4 30.7-71.4 69.9v.5c0 38.7 31.1 69.1 70.9 69.1 40.2 0 71.7-30.6 71.7-69.6v-.5c0-39-31.3-69.4-71.2-69.4zm0 114.1c-23.7 0-42.2-19.5-42.2-44.3v-.5c0-25.5 17.5-44 41.7-44s42.5 19.2 42.5 44.5v.5c0 25.4-17.6 43.8-42 43.8z" fill-rule="nonzero"/><path d="m456.7 154.9 40.7-56.4c1.2-1.7 1.4-3.9.4-5.8s-2.9-3-5-3h-17c-1.8 0-3.6.9-4.6 2.4l-30.1 43.7-30.1-43.7c-1-1.5-2.8-2.4-4.6-2.4h-17.7c-2.1 0-4 1.2-5 3-1 1.9-.8 4.1.4 5.8l40.7 56.7-42.5 59.2c-1.2 1.7-1.4 3.9-.4 5.8s2.9 3 5 3h17c1.8 0 3.6-.9 4.6-2.4l31.9-46.5 32.2 46.5c1 1.5 2.8 2.4 4.6 2.4h17.8c2.1 0 4-1.2 5-3 1-1.9.8-4.1-.4-5.8z"/><path d="m42 124.9c-.7-7.8-.5-17.2 3.2-30.1 3.1-10.4 10.5-21.9 19.1-30 8.4-7.9 19.8-14.1 32.2-16.9 11.8-2.7 21.7-2.5 29.2-1.6 1.1 0 1.9.5 2.3 1 .8.8.9 2.6.5 3.1-.4.4-1.4.8-2.4.8-16.3 1-33.8 9.8-50.6 25.6-15.4 14.5-26.4 32.9-28.5 48.8-.1 1-.5 1.9-1 2.3s-2.4.3-3.1-.5c-.4-.6-.8-1.4-.9-2.5z"/><path d="m1 106.3c-.9-10.3-.7-22.9 4.3-40.1 4.1-13.9 13.9-29.1 25.4-39.9 11.2-10.5 26.3-18.7 42.9-22.5 15.7-3.6 28.9-3.3 38.8-2.2 1.4 0 2.5.7 3.1 1.3 1 1.1 1.2 3.5.6 4.1-.5.5-1.8 1-3.1 1.1-21.7 1.4-45 13.1-67.3 34.1-20.6 19.4-35.2 43.8-38 65-.2 1.3-.7 2.5-1.3 3.1s-3.1.4-4.2-.7c-.6-.6-1.1-1.7-1.2-3.3z"/><path d="m534.6 48.9c-8 0-14.6 6.5-14.6 14.6 0 8 6.5 14.6 14.6 14.6 8 0 14.6-6.5 14.6-14.6 0-8-6.5-14.6-14.6-14.6z"/><path d="m825.8 48.9c-8 0-14.6 6.5-14.6 14.6 0 8 6.5 14.6 14.6 14.6 8 0 14.6-6.5 14.6-14.6 0-8-6.6-14.6-14.6-14.6z"/></g></svg>
  """
)
