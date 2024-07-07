import Dependencies
import Models
import StyleguideV2

public struct EpisodeDetail: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode

  let episode: Episode
  let transcript: HTMLMarkdown?

  public init(episode: Episode) {
    self.episode = episode
    self.transcript = episode.privateTranscript.map { HTMLMarkdown($0) }
  }

  public var body: some HTML {
    VideoHeader(
      title: episode.fullTitle,
      subtitle: """
        Episode #\(episode.sequence) • \
        \(headerDateFormatter.string(from: episode.publishedAt)) \
        • \(episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) ? "Subscriber-Only" : "Free Episode")
        """,
      blurb: episode.blurb,
      vimeoVideoID: VimeoVideo.ID(rawValue: episode.fullVideo.vimeoId)
    )
    
    PageModule(theme: .content) {
      if let transcript {
        ul {
          HTMLForEach(transcript.tableOfContents) { section in
            if let timestamp = section.timestamp {
              li {
                HStack {
                  div {
                    HTMLText(section.title)
                  }
                  Spacer()
                  Link(href: "#t\(timestamp.duration)") {
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
        .listStyle(.reset)

        VStack(spacing: 3) {
          article {
            transcript
              .color(.gray150.dark(.gray800))
              .linkColor(.black.dark(.white))
              .linkUnderline(true)
          }
        }
        .inlineStyle("margin", "0 auto", media: .desktop)
        .inlineStyle("max-width", "60%", media: .desktop)
      }
    }
  }
}
