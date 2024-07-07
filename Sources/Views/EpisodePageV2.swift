import Dependencies
import Models
import StyleguideV2

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
        rawValue: permission.isViewable ? episode.fullVideo.vimeoId : episode.trailerVideo.vimeoId
      )
    )

    if let transcript {
      PageModule(theme: .content) {
        LazyVGrid(columns: [.desktop: [3, 6], .mobile: [1]]) {
          TableOfContents(
            episodePageData: episodePageData,
            tableOfContents: transcript.tableOfContents
          )

          VStack {
            if !permission.isViewable, currentUser.map({ $0.episodeCreditCount > 0 }) ?? true {
              UnlockEpisodeCallout(episode: episode)
            }

            article {
              transcript
                .color(.gray150.dark(.gray800))
                .linkColor(.black.dark(.white))
                .linkUnderline(true)
            }
          }
          .inlineStyle("margin-left", "4rem", media: .desktop)
          .inlineStyle("min-width", "0")
        }
        .inlineStyle("min-width", "0")
      }
    }

    if !subscriberState.isActiveSubscriber {
      GetStartedModule(style: .solid)
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

private struct TableOfContents: HTML {
  let episodePageData: EpisodePageData
  let tableOfContents: [HTMLMarkdown.Section]

  var body: some HTML {
    VStack {
      ul {
        HTMLForEach(tableOfContents) { section in
          if let timestamp = section.timestamp {
            li {
              HStack(alignment: .firstTextBaseline) {
                Link(href: section.anchor) {
                  HTMLText(section.title)
                }
                .linkColor(.offBlack.dark(.offWhite))
                Spacer()
                Link(href: timestamp.anchor) {
                  HTMLText(timestamp.formatted())
                }
                .attribute("data-timestamp", "\(timestamp.duration)")
                .linkColor(.gray800.dark(.gray300))
                .inlineStyle("font-variant-numeric", "tabular-nums")
              }
              .fontStyle(.body(.small))
            }
          }
        }
      }
      .inlineStyle("margin", "1rem")
      .listStyle(.reset)
    }
    .flexContainer(direction: "column")
    .inlineStyle("align-self", "start", media: .desktop)
    .inlineStyle("border", "1px solid #ccc")
    .inlineStyle("border-radius", "6px")
    .inlineStyle("position", "sticky", media: .desktop)
    .inlineStyle("top", "1rem", media: .desktop)
  }
}

struct UnlockEpisodeCallout: HTML {
  let episode: Episode

  var body: some HTML {
    HTMLEmpty()
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
#endif
