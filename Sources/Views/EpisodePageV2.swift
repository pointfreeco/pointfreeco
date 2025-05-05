import Dependencies
import Foundation
import Models
import PointFreeRouter
import Styleguide
import StyleguideV2

public enum EpisodePermission: Equatable {
  case loggedIn(user: User, subscriptionPermission: SubscriberPermission)
  case loggedOut(isEpisodeSubscriberOnly: Bool)

  public enum SubscriberPermission: Equatable {
    case isNotSubscriber(creditPermission: CreditPermission)
    case isSubscriber

    public enum CreditPermission: Equatable {
      case hasNotUsedCredit(isEpisodeSubscriberOnly: Bool)
      case hasUsedCredit
    }
  }

  public var isViewable: Bool {
    switch self {
    case .loggedIn(_, .isSubscriber),
      .loggedIn(_, .isNotSubscriber(.hasUsedCredit)),
      .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(false))),
      .loggedOut(false):
      return true
    default:
      return false
    }
  }
}

public struct EpisodePageData {
  var context: Context
  var emergencyMode: Bool
  var episode: Episode
  var episodeProgress: Int?
  var permission: EpisodePermission

  public enum Context {
    case collection(Episode.Collection, section: Episode.Collection.Section)
    case direct(previousEpisode: Episode?, nextEpisode: Episode?)
  }

  public init(
    context: Context,
    emergencyMode: Bool,
    episode: Episode,
    episodeProgress: Int?,
    permission: EpisodePermission
  ) {
    self.context = context
    self.emergencyMode = emergencyMode
    self.episode = episode
    self.episodeProgress = episodeProgress
    self.permission = permission
  }

  public var collection: Episode.Collection? {
    guard case let .collection(collection, section: _) = self.context else { return nil }
    return collection
  }

  public var section: Episode.Collection.Section? {
    guard
      let collection = self.collection,
      let section = collection.sections
        .first(where: { $0.coreLessons.contains(where: { $0.episode == self.episode }) })
    else { return nil }
    return section
  }

  public var route: SiteRoute {
    switch context {
    case let .collection(collection, section: section):
      return .collections(
        .collection(collection.slug, .section(section.slug, .episode(.left(self.episode.slug))))
      )
    case .direct:
      return .episodes(.show(episode))
    }
  }
}

public struct EpisodeDetail: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.subscriberState) var subscriberState

  let episodePageData: EpisodePageData
  let transcript: HTMLMarkdown?

  public init(episodePageData: EpisodePageData) {
    self.episodePageData = episodePageData
    self.transcript = episodePageData.episode.transcript.map {
      HTMLMarkdown($0, previewOnly: !episodePageData.permission.isViewable)
    }
  }

  private var episode: Episode { episodePageData.episode }
  private var permission: EpisodePermission { episodePageData.permission }

  public var body: some HTML {
    let isSubscriberOnly = episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)

    VideoHeader(
      title: episode.fullTitle,
      subtitle: """
        Episode #\(episode.sequence) \
        • \(headerDateFormatter.string(from: episode.publishedAt)) \
        • \(isSubscriberOnly ? "Subscriber-Only" : "Free Episode")
        """,
      blurb: episode.blurb,
      vimeoVideoID: VimeoVideo.ID(
        rawValue: permission.isViewable
          ? episode.fullVideo.vimeoId
          : episode.trailerVideo.vimeoId
      ),
      progress: episodePageData.episodeProgress.map {
        .init(percent: $0, seconds: episode.length.rawValue)
      }
    )

    if let transcript {
      PageModule(theme: .content) {
        LazyVGrid(columns: [.desktop: [30, 70], .mobile: [1]]) {
          TableOfContents(
            episodePageData: episodePageData,
            tableOfContents: transcript.tableOfContents
          )

          VStack {
            UnlockEpisodeCallout(episode: episode, permission: permission)

            article {
              transcript
                .color(.gray150.dark(.gray800))
                .linkColor(.black.dark(.white))
                .linkUnderline(true)
            }

            div {
              Divider()
            }
            .inlineStyle("margin", "5rem 0 2.5rem")

            div {
              if !episode.references.isEmpty {
                Header(4) {
                  "References"
                }
                .attribute("id", "references")

                ul {
                  HTMLForEach(episode.references) { reference in
                    li {
                      Header(5) {
                        Link(href: reference.link) {
                          HTMLText(reference.title)
                        }
                      }
                      div {
                        if let author = reference.author {
                          HTMLText(author)
                        }
                        if reference.author != nil && reference.publishedAt != nil {
                          " • "
                        }
                        if let publishedAt = reference.publishedAt {
                          HTMLText(publishedAt.monthDayYear())
                        }
                      }
                      .fontStyle(.body(.small))
                      .color(.gray500)
                      if let blurb = reference.blurb {
                        HTMLMarkdown(blurb)
                          .color(.gray400.dark(.gray650))
                          .inlineStyle("margin", "0")
                      }
                      div {
                        Link(href: reference.link) {
                          HTMLText(reference.link)
                        }
                      }
                      .linkUnderline(true)
                      .inlineStyle("margin-top", "0.25rem")
                      .inlineStyle("word-break", "break-all")
                    }
                  }
                }
                .linkColor(.offBlack.dark(.offWhite))
                .listStyle(.reset)
                .flexContainer(
                  direction: "column",
                  rowGap: "2rem"
                )
              }

              if let codeSampleDirectory = episode.codeSampleDirectory {
                div {
                  Header(4) {
                    "Downloads"
                  }
                  .attribute("id", "downloads")
                }
                .inlineStyle("margin-top", "4rem")
                div {
                  Header(5) {
                    "Sample code"
                  }
                  .inlineStyle("margin", "1rem 0 0")
                  let gitHubRouter = GitHubRouter()
                  div {
                    Link(
                      href:
                        gitHubRouter
                        .url(for: .episodeCodeSample(directory: codeSampleDirectory))
                        .absoluteString
                    ) {
                      HStack(alignment: .center, spacing: 0.5) {
                        SVG(base64: gitHubSvgBase64(fill: "currentColor"), description: "")
                          .inlineStyle("filter", "invert()", media: .dark)
                          .inlineStyle("height", "20px")
                          .inlineStyle("horizontal-align", "middle")
                          .inlineStyle("vertical-align", "middle")
                          .inlineStyle("width", "20px")
                        HTMLText(codeSampleDirectory)
                      }
                    }
                  }
                  .linkColor(.offBlack.dark(.offWhite))
                  .linkUnderline(true)
                  .inlineStyle("margin-top", "0.25rem")
                }
              }
            }
            .color(.black.dark(.offWhite))
          }
          .inlineStyle("margin-left", "4rem", media: .desktop)
          .inlineStyle("min-width", "0")
        }
        .inlineStyle("min-width", "0")
      }
    }

    if currentUser == nil {
      GetStartedModule(style: .gradient)
    } else if subscriberState.isNonSubscriber {
      UpgradeModule()
    }

    script {
      #"""
      window.addEventListener("load", function(event) {
        const iframe = document.querySelector("iframe")
        const player = new Vimeo.Player(iframe)
        const trackProgress = \#(permission.isViewable)

        jump(window.location.hash, false)

        let lastSeenPercent = 0
        if (trackProgress) {
          player.on('timeupdate', function(data) {
            if (Math.abs(data.percent - lastSeenPercent) >= 0.01) {
              lastSeenPercent = data.percent

              const httpRequest = new XMLHttpRequest()
              httpRequest.open(
                "POST",
                window.location.pathname + "/progress?percent=" + Math.round(data.percent * 100)
              )
              httpRequest.send()
            }
          })
        }

        document.addEventListener("click", function(event) {
          const target = event.target
          const time = Number(target.dataset.timestamp)
          if (target.tagName != "A") { return }
          if (target.dataset.timestamp == undefined) { return }
          if (time < 0) { return }
          if (isElementVisible(iframe)) { event.preventDefault() }
          player.setCurrentTime(time)
          player.play()

          function isElementVisible(element) {
            const rect = element.getBoundingClientRect()
            const viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight)
            return rect.bottom >= 0 && rect.top < viewHeight
          }
        })

        function jump(hash, play) {
          const time = +((/^#t(\d+)$/.exec(hash) || [])[1] || "")
          if (time <= 0) { return }
          player.setCurrentTime(time)
          if (play) { player.play() }
        }
      })
      """#
    }
  }
}

let headerDateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateFormat = "MMM d, yyyy"
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()

private struct TableOfContents: HTML {
  let episodePageData: EpisodePageData
  let tableOfContents: [HTMLMarkdown.Section]

  var body: some HTML {
    VStack(spacing: 0) {
      switch episodePageData.context {
      case .collection(let collection, let section):
        TableOfContentsSection(type: .collection(collection, section: section))
        HTMLForEach(section.coreLessons) { lesson in
          if case let .episode(episode) = lesson {
            if episode.id == episodePageData.episode.id {
              TableOfContentsSection(type: .focusedEpisode(episode, tableOfContents))
            } else {
              TableOfContentsSection(type: .episode(episode))
            }
          }
        }
      case .direct(let previousEpisode, let nextEpisode):
        if let previousEpisode {
          TableOfContentsSection(type: .episode(previousEpisode, sequence: .previous))
        }
        TableOfContentsSection(type: .focusedEpisode(episodePageData.episode, tableOfContents))
        if let nextEpisode {
          TableOfContentsSection(type: .episode(nextEpisode, sequence: .next))
        }
      }
    }
    .flexContainer(direction: "column")
    .inlineStyle("align-self", "start", media: .desktop)
    .inlineStyle("border", "1px solid #ccc")
    .inlineStyle("border", "1px solid #555", media: .dark)
    .inlineStyle("border-radius", "6px")
    .inlineStyle("position", "sticky", media: .desktop)
    .inlineStyle("top", "1rem", media: .desktop)
  }
}

struct UnlockEpisodeCallout: HTML {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  let episode: Episode
  let permission: EpisodePermission

  var body: some HTML {
    switch permission {
    case .loggedIn(_, .isSubscriber):
      HTMLEmpty()
    case .loggedOut(isEpisodeSubscriberOnly: true):
      Callout(
        "Unlock This Episode",
        icon: SVG(base64: circleLockSvgBase64, description: "Locked")
      ) {
        """
        Our Free plan includes 1 subscriber-only episode of your choice, plus weekly updates from \
        our newsletter.
        """
      } callToAction: {
        Button(color: .purple) {
          Label("Sign in with GitHub", icon: .gitHubIcon)
            .fontStyle(.body(.regular))
        }
        .attribute(
          "href",
          siteRouter.loginPath(redirect: currentRoute)
        )
      }

    case .loggedIn(let user, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true)))
    where user.episodeCreditCount > 0:
      Callout(
        "Unlock This Episode",
        icon: SVG(base64: circleLockSvgBase64, description: "Locked")
      ) {
        """
        You have \(user.episodeCreditCount) episode \
        credit\(user.episodeCreditCount == 1 ? "" : "s"). \
        Spend \(user.episodeCreditCount == 1 ? "it" : "one") to watch this episode for free?
        """
      } callToAction: {
        form {
          Button(tag: input, color: .purple)
            .attribute("value", "Redeem this episode")
            .attribute("type", "submit")
        }
        .attribute(
          "action",
          siteRouter.path(for: .episodes(.episode(param: .right(episode.id), .useCredit)))
        )
        .attribute("method", "post")
      }

    case .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: true))):
      Callout(
        "Subscribe to Point-Free",
        icon: SVG(base64: lockSvgBase64, description: "Locked")
      ) {
        "Access this episode, plus all past and future episodes, when you become a subscriber."
      } callToAction: {
        Button(color: .purple) {
          "See plans and pricing"
        }
        .attribute("href", siteRouter.path(for: .pricingLanding))
        if currentUser == nil {
          Paragraph {
            "Already a subscriber? "
            Link("Log in", href: siteRouter.loginPath(redirect: currentRoute))
          }
        }
      } bar: {
        SVG(base64: lockSvgBase64, description: "Locked")
        "This episode is for subscribers only."
      }

    case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
      Callout("Subscribe to Point-Free") {
        "Access all past and future episodes when you become a subscriber."
      } callToAction: {
        Button(color: .purple) {
          "See plans and pricing"
        }
        .attribute("href", siteRouter.path(for: .pricingLanding))
      } bar: {
        SVG(base64: unlockSvgBase64, description: "Free")
        "You unlocked this episode with a credit."
      }

    case .loggedOut(isEpisodeSubscriberOnly: false),
      .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isEpisodeSubscriberOnly: false))):

      Callout("Subscribe to Point-Free") {
        "Access all past and future episodes when you become a subscriber."
      } callToAction: {
        Button(color: .purple) {
          "See plans and pricing"
        }
        .attribute("href", siteRouter.path(for: .pricingLanding))
        if currentUser == nil {
          Paragraph {
            "Already a subscriber? "
            Link("Log in", href: siteRouter.loginPath(redirect: currentRoute))
          }
        }
      } bar: {
        SVG(base64: unlockSvgBase64, description: "Free")
        "This episode is free for everyone."
      }
    }
  }
}

struct Callout<Message: HTML, CallToAction: HTML, Bar: HTML>: HTML {
  let title: String
  let icon: SVG?
  let message: Message
  let callToAction: CallToAction
  let bar: Bar?

  init(
    _ title: String,
    icon: SVG? = nil,
    @HTMLBuilder message: () -> Message,
    @HTMLBuilder callToAction: () -> CallToAction,
    @HTMLBuilder bar: () -> Bar? = { Never?.none }
  ) {
    self.title = title
    self.icon = icon
    self.message = message()
    self.callToAction = callToAction()
    self.bar = bar()
  }

  var body: some HTML {
    VStack {
      if let bar {
        div {
          HStack(spacing: 0.5) {
            bar
          }
          .inlineStyle("justify-content", "center")
        }
        .backgroundColor(.gray900.dark(.gray150))
        .fontStyle(.body(.small))
        .inlineStyle("border-bottom", "1px solid #ccc")
        .inlineStyle("border-bottom", "1px solid #555", media: .dark)
        .inlineStyle("font-weight", "600")
        .inlineStyle("line-height", "3")
      }
      VStack(spacing: 0.5) {
        if let icon {
          div {
            icon
          }
          .inlineStyle("filter", "invert()", media: .dark)
          .inlineStyle("height", "3rem")
          .inlineStyle("margin-top", "1rem")
          .inlineStyle("text-align", "center")
        }
        Header(4) {
          HTMLText(title)
        }
        .color(.offBlack.dark(.offWhite))
        Paragraph {
          message
        }
        .inlineStyle("margin-bottom", "1rem")
        .inlineStyle("text-wrap", "balance")
        VStack(alignment: .center, spacing: 0.5) {
          callToAction
        }
        .fontStyle(.body(.small))
      }
      .inlineStyle("padding", "1rem 2rem 2rem")
    }
    .linkColor(.purple)
    .color(.gray650.dark(.gray500))
    .inlineStyle("border", "1px solid #ccc")
    .inlineStyle("border", "1px solid #555", media: .dark)
    .inlineStyle("border-radius", "6px")
    .inlineStyle("overflow", "hidden")
    .inlineStyle("text-align", "center")
  }
}

struct TableOfContentsSection: HTML {
  let type: SectionType

  var body: some HTML {
    HTMLGroup {
      switch type {
      case .collection(let collection, let section):
        CollectionSection(collection: collection, section: section)
      case .episode(let episode, let sequence):
        EpisodeSection(episode: episode, sequence: sequence)
      case .focusedEpisode(let episode, let tableOfContents):
        FocusedEpisodeSection(episode: episode, tableOfContents: tableOfContents)
      }
    }
    .linkColor(.offBlack.dark(.offWhite))
    .inlineStyle("padding", "1.5rem 1rem")
    .inlineStyle("border-top", "1px solid #ccc", pseudo: .not(.firstChild))
    .inlineStyle("border-top", "1px solid #555", media: .dark, pseudo: .not(.firstChild))
  }

  struct PlayIcon: HTML {
    var body: some HTML {
      SVG(base64: playIconSvgBase64(), description: "")
        .flexItem(basis: "1.25rem")
        .inlineStyle("margin-top", "2px")
        .inlineStyle("filter", "invert(100%)", media: .dark)
    }
  }
  struct ReferencesIcon: HTML {
    var body: some HTML {
      SVG(base64: referencesIconSvgBase64, description: "")
        .flexItem(basis: "1.25rem")
        .inlineStyle("margin-top", "2px")
        .inlineStyle("filter", "invert(100%)", media: .dark)
    }
  }
  struct DownloadIcon: HTML {
    var body: some HTML {
      div {
        SVG(base64: downloadIconSvgBase64, description: "")
          .inlineStyle("max-width", "1rem")
      }
      .inlineStyle("text-align", "center")
      .flexItem(basis: "1.25rem")
      .inlineStyle("margin-top", "2px")
      .inlineStyle("filter", "invert(100%)", media: .dark)
    }
  }

  struct FocusedEpisodeSection: HTML {
    let episode: Episode
    let tableOfContents: [HTMLMarkdown.Section]
    @Dependency(\.linkStyle) var linkStyle
    var body: some HTML {
      VStack(spacing: 1) {
        HStack(alignment: .center, spacing: 0.5) {
          PlayIcon()
          div {
            Header(5) {
              HTMLText(episode.fullTitle)
            }
            .color(linkStyle.color)
            .inlineStyle("word-wrap", "balance")
          }
        }
        HStack(spacing: 0.5) {
          div {
            div()
              .inlineStyle("width", "2px")
              .inlineStyle("height", "100%")
              .inlineStyle("margin", "0 auto")
              .background(.gray800)
          }
          .flexItem(grow: "0", shrink: "0", basis: "1.25rem")
          .inlineStyle("text-align", "center")
          ul {
            HTMLForEach(tableOfContents) { section in
              li {
                HStack(alignment: .center, spacing: 0.25) {
                  Link(href: section.anchor) {
                    HTMLMarkdown(section.title)
                  }
                  .linkColor(.offBlack.dark(.offWhite))
                  .inlineStyle("line-height", "1.35")
                  .inlineStyle("word-break", "break-all")

                  if let timestamp = section.timestamp {
                    Link(href: timestamp.anchor) {
                      HTMLText(timestamp.formatted())
                    }
                    .attribute("data-timestamp", "\(timestamp.duration)")
                    .linkColor(.gray(0.66))
                    .inlineStyle("font-variant-numeric", "tabular-nums")
                  }
                }
                .fontStyle(.body(.small))
                .inlineStyle("justify-content", "space-between")
              }
            }
          }
          .flexContainer(direction: "column", rowGap: "0.25rem")
          .inlineStyle("width", "100%")
          .inlineStyle("margin", "0")
          .listStyle(.reset)
        }
        if !episode.references.isEmpty {
          HStack(alignment: .center, spacing: 0.5) {
            ReferencesIcon()
            div {
              Link(href: "#references") {
                Header(5) { "References" }
                  .color(linkStyle.color)
              }
            }
          }
        }
        if episode.codeSampleDirectory != nil {
          HStack(alignment: .center, spacing: 0.5) {
            DownloadIcon()
            div {
              Link(href: "#downloads") {
                Header(5) { "Downloads" }
                  .color(linkStyle.color)
              }
            }
          }
        }
      }
      .backgroundColor(.gray(0xfa).dark(.gray(0x19)))
      .inlineStyle("border-radius", "0 0 6px 6px")
    }
  }

  struct EpisodeSection: HTML {
    let episode: Episode
    let sequence: TableOfContentsSection.SectionType.Sequence?

    var body: some HTML {
      VStack(spacing: 0) {
        HTMLGroup {
          switch sequence {
          case .previous:
            Header(6) {
              "Previous episode"
            }
          case .next:
            Header(6) {
              "Next episode"
            }
          case nil:
            HTMLEmpty()
          }
        }
        .uppercase()
        .color(.gray650.dark(.gray400))
        div {
          HStack(alignment: .center, spacing: 0.5) {
            PlayIcon()
            div {
              Link(destination: .episodes(.show(episode))) {
                Header(5) {
                  HTMLText(episode.fullTitle)
                }
                .inlineStyle("word-wrap", "balance")
              }
            }
          }
        }
      }
    }
  }

  struct CollectionSection: HTML {
    let collection: Episode.Collection
    let section: Episode.Collection.Section
    var body: some HTML {
      VStack(spacing: 0) {
        Header(6) {
          "Collection"
        }
        .uppercase()
        .color(.gray650.dark(.gray400))
        Link(
          destination: .collections(.collection(collection.slug, .section(section.slug, .show)))
        ) {
          Header(5) {
            HTMLText(section.title)
          }
        }
      }
    }
  }

  enum SectionType {
    case collection(Episode.Collection, section: Episode.Collection.Section)
    case episode(Episode, sequence: Sequence? = nil)
    case focusedEpisode(Episode, [HTMLMarkdown.Section])
    enum Sequence {
      case previous
      case next
    }
  }
}

extension HTML {
  fileprivate func truncateOverflow() -> some HTML {
    self
      .inlineStyle("white-space", "nowrap")
      .inlineStyle("overflow", "hidden")
      .inlineStyle("text-overflow", "ellipsis")
  }
  fileprivate func uppercase() -> some HTML {
    self
      .inlineStyle("text-transform", "uppercase")
      .inlineStyle("letter-spacing", "0.54pt")
  }
}

#if DEBUG && canImport(SwiftUI)
  import SwiftUI
  import Transcripts

  #Preview("Episode Detail", traits: .fixedLayout(width: 500, height: 1000)) {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        EpisodeDetail(
          episodePageData: EpisodePageData(
            context: .direct(previousEpisode: nil, nextEpisode: nil),
            emergencyMode: false,
            episode: .mock,
            episodeProgress: 30,
            permission: .loggedOut(isEpisodeSubscriberOnly: false)
          )
        )
      }
    }
  }

  #Preview("Sidebar", traits: .fixedLayout(width: 400, height: 1000)) {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        TableOfContents(
          episodePageData: EpisodePageData(
            context: .direct(previousEpisode: nil, nextEpisode: nil),
            emergencyMode: false,
            episode: .mock,
            episodeProgress: 30,
            permission: .loggedOut(isEpisodeSubscriberOnly: false)
          ),
          tableOfContents: [
            HTMLMarkdown.Section(
              title: "Introduction",
              id: "1",
              level: 1,
              timestamp: Timestamp(format: "00:01:03", speaker: "Brandon")
            ),
            HTMLMarkdown.Section(
              title: "Binding",
              id: "2",
              level: 1,
              timestamp: Timestamp(format: "00:03:03", speaker: "Stephen")
            ),
          ]
        )
        .inlineStyle("margin", "2rem")
      }
    }
  }
#endif
