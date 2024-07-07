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
      VStack(spacing: 3) {
        if let transcript {
          article {
            transcript
              .color(.gray150.dark(.gray800))
              .linkColor(.black.dark(.white))
              .linkUnderline(true)
          }
        }
      }
      .inlineStyle("margin", "0 auto", media: .desktop)
      .inlineStyle("width", "60%", media: .desktop)
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
