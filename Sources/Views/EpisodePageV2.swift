import Dependencies
import Models
import StyleguideV2

public struct EpisodeDetail: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.subscriberState) var subscriberState

  let episode: Episode
  let transcript: HTMLMarkdown?

  public init(episode: Episode) {
    self.episode = episode
    self.transcript = episode.privateTranscript.map { HTMLMarkdown($0) }
  }

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
      vimeoVideoID: VimeoVideo.ID(rawValue: episode.fullVideo.vimeoId)
    )

    if !subscriberState.isActiveSubscriber {
      GetStartedModule(style: .solid)
    }

    if let transcript {
      PageModule(theme: .content) {
        LazyVGrid(columns: [.desktop: [3, 6], .mobile: [1]]) {
          div {
            ul {
              HTMLForEach(transcript.tableOfContents) { section in
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
                      .inlineStyle("font-variant-numeric", "tabular-nums")
                      .linkColor(.gray800.dark(.gray300))
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

          VStack {
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
  }
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
import Transcripts

#Preview("Clips Index", traits: .fixedLayout(width: 500, height: 1000)) {
  HTMLPreview {
    PageLayout(layoutData: SimplePageLayoutData(title: "")) {
      EpisodeDetail(episode: .mock)
    }
  }
}
#endif
