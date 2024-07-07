import Models
import StyleguideV2

struct VideoHeader: HTML {
  let title: String
  let subtitle: String
  let blurb: String
  let vimeoVideoID: VimeoVideo.ID

  var body: some HTML {
    CenterColumn {
      VStack(alignment: .center, spacing: 0) {
        Header(3) {
          HTMLRaw(title)
        }
        .color(.offWhite)
        .inlineStyle("text-align", "center")
        .inlineStyle("text-wrap", "balance")

        span {
          HTMLText(subtitle)
        }
        .color(.gray800)

        HTMLMarkdown(blurb)
          .color(.gray900)
          .inlineStyle("max-width", "768px")
          .linkStyle(.init(color: .offWhite, underline: true))
          .inlineStyle("margin-top", "2rem")
          .inlineStyle("text-align", "justify")
      }
      .inlineStyle("padding", "3rem 2rem 6rem")
      .inlineStyle("padding", "4rem 3rem 6rem", media: .desktop)
    }
    .inlineStyle("background", "linear-gradient(#121212, #242424)")
    .inlineStyle("padding-bottom", "2rem")

    CenterColumn {
      div {
        div {
          div {
            iframe()
              .attribute("src", "https://player.vimeo.com/video/\(vimeoVideoID)?pip=1")
              .attribute("frameborder", "0")
              .attribute("allow", "autoplay; fullscreen")
              .attribute("allowfullscreen")
              .inlineStyle("width", "100%")
              .inlineStyle("height", "100%")
              .inlineStyle("position", "absolute")
            script()
              .attribute("async")
              .attribute("src", "https://player.vimeo.com/api/player.js")
          }
          .inlineStyle("width", "100%")
          .inlineStyle("position", "relative")
          .inlineStyle("padding-bottom", "56.25%")
        }
        .inlineStyle("box-shadow", "0rem 1rem 20px rgba(0,0,0,0.2)")
        .inlineStyle("margin", "0 4rem", media: .desktop)
      }
    }
    .inlineStyle("margin-top", "-4rem")
    .inlineStyle("padding-bottom", "4rem")
  }
}
