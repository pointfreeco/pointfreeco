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
        LazyVGrid(columns: [.desktop: [30, 70], .mobile: [1]]) {
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
    VStack(spacing: 0) {
      TableOfContentsSection(type: .collection(.swiftUI, section: .modernSwiftUI))
      TableOfContentsSection(type: .episode(.mock))
      TableOfContentsSection(
        type: .focusedEpisode(
          episodePageData.episode,
          tableOfContents
        )
      )
      TableOfContentsSection(type: .episode(.mock))
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
  let episode: Episode

  var body: some HTML {
    HTMLEmpty()
  }
}

struct TableOfContentsSection: HTML {
  let type: SectionType

  var body: some HTML {
    HTMLGroup {
      switch type {
      case .collection(let collection, section: let section):
        CollectionSection(collection: collection, section: section)
      case .episode(let episode):
        EpisodeSection(episode: episode)
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
              HTMLText(episode.fullTitle + ": Lorem Ipsum Edition")
            }
            .color(linkStyle.color)
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
                    HTMLText(section.title + " Hello world")
                  }
                  .linkColor(.offBlack.dark(.offWhite))
                  .inlineStyle("line-height", "1.35")

                  Spacer()
                  if let timestamp = section.timestamp {
                    Link(href: timestamp.anchor) {
                      HTMLText(timestamp.formatted())
                    }
                    .attribute("data-timestamp", "\(timestamp.duration)")
                    .linkColor(.gray800.dark(.gray300))
                    .inlineStyle("font-variant-numeric", "tabular-nums")
                  }
                }
                .fontStyle(.body(.small))
              }
            }
          }
          .flexContainer(direction: "column", rowGap: "0.25rem")
          .inlineStyle("width", "100%")
          .inlineStyle("margin", "0")
          .listStyle(.reset)
        }
      }
      .backgroundColor(.gray(0.97))
    }
  }

  struct EpisodeSection: HTML {
    let episode: Episode
    var body: some HTML {
      VStack(spacing: 0) {
        Header(6) {
          "Previous episode" // TODO
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
    case episode(Episode)
    case focusedEpisode(Episode, [HTMLMarkdown.Section])
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

@testable import StyleguideV2

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
          )
        ]
      )
      .inlineStyle("margin", "2rem")
    }
  }
}
#endif
