import Cloudflare
import Dependencies
import EnvVars
import Foundation
import Models
import StyleguideV2

struct VideoHeader: HTML {
  let title: String
  let subtitle: String
  let blurb: String
  let videoID: Episode.Video.ID
  var adURL: String? = "https://opencdn.b-cdn.net/pub/5.0/e-v-1/vmap_ad_sample.xml"
  let poster: String
  let progress: Progress?
  let trackProgress: Bool

  struct Progress {
    let percent: Int
    let seconds: Int
  }

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
            switch videoID {
            case .cloudflare:
              // <div style="position: relative; padding-top: 56.25%;">
              // </div>
              iframe()
                .attribute("src", src)
                .attribute("loading", "lazy")
                .attribute(
                  "allow",
                  "accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
                )
                .attribute("allowfullscreen")
                .inlineStyle("border", "none")
                .inlineStyle("position", "absolute")
                .inlineStyle("top", "0")
                .inlineStyle("left", "0")
                .inlineStyle("width", "100%")
                .inlineStyle("height", "100%")
              script()
                .attribute("async")
                .attribute("src", "https://embed.cloudflarestream.com/embed/sdk.latest.js")
              script {
                #"""
                window.addEventListener("load", function(event) {
                  const iframe = document.querySelector("iframe")
                  const player = new Stream(iframe)
                  const trackProgress = \#(trackProgress)

                  jump(window.location.hash, false)

                  let lastSeenPercent = 0
                  if (trackProgress) {
                    player.addEventListener("timeupdate", function(data) {
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
                    player.currentTime = time
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
                    player.currentTime = time
                    if (play) { player.play() }
                  }
                })
                """#
              }
            case .vimeo:
              iframe()
                .attribute("src", src)
                .attribute("frameborder", "0")
                .attribute("allow", "autoplay; fullscreen")
                .attribute("allowfullscreen")
                .inlineStyle("width", "100%")
                .inlineStyle("height", "100%")
                .inlineStyle("position", "absolute")
              script()
                .attribute("async")
                .attribute("src", "https://player.vimeo.com/api/player.js")
              script {
                #"""
                window.addEventListener("load", function(event) {
                  const iframe = document.querySelector("iframe")
                  const player = new Vimeo.Player(iframe)
                  const trackProgress = \#(trackProgress)

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

  private var src: String {
    let seconds = progress.map { Int(Double($0.seconds * $0.percent) / 100) }
    switch videoID {
    case .cloudflare(let id):
      @Dependency(\.envVars.cloudflare.customerSubdomain) var customerSubdomain
      let timestamp = seconds.map { "&startTime=\($0)s" } ?? ""
      var src = "https://\(customerSubdomain)/\(id)/iframe?poster=\(poster)&startTime=\(timestamp)"
      if let adURL {
        src.append("&ad-url=\(adURL)")
      }
      return src
    case .vimeo(let id):
      let timestamp = seconds.map { "#\($0)s" } ?? ""
      return "https://player.vimeo.com/video/\(id)?pip=1\(timestamp)"
    }
  }
}
