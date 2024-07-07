import Dependencies
import Models
import StyleguideV2

public struct EpisodeDetail: HTML {
  @Dependency(\.currentUser) var currentUser

  let episode: Episode
  let transcript: HTMLMarkdown?

  public init(episode: Episode) {
    self.episode = episode
    self.transcript = episode.privateTranscript.map { HTMLMarkdown($0) }
  }

  public var body: some HTML {
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
    } title: {
      VStack {
        Link(destination: .episodes(.show(episode))) {
          Header(3) {
            HTMLMarkdown(episode.title)
          }
        }
        .linkColor(.offBlack.dark(.offWhite))

        div {
          HTMLText(episode.publishedAt.weekdayMonthDayYear())
        }
        .color(.gray500)
      }
      .inlineStyle("text-align", "center")
      .inlineStyle("width", "100%")
    }
  }
}
