import Css
import Foundation
import Html
import HtmlCssSupport

let videoJsHead: [ChildOf<Element.Head>] = [
  style(".vjs-subs-caps-button" % display(.none)),
  link([
    href("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/alt/video-js-cdn.min.css"),
    rel(.stylesheet)
    ]),
  script("window.HELP_IMPROVE_VIDEOJS = false;"),
  .init(script([
    src("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/video.min.js"),
    `defer`(true)
    ]))
]

let videoClasses: CssSelector =
  ".video-js"
    | ".vjs-default-skin"
    | ".vjs-big-play-centered"

struct VideoJsOptions: Encodable {
  let control: Bool
  let playbackRates: [Double]

  static let `default` = VideoJsOptions(control: true, playbackRates: [0.5, 1, 1.5, 2])

  var jsonString: String {
    return ((try? String(data: JSONEncoder().encode(VideoJsOptions.default), encoding: .utf8)) ?? nil)
      ?? "{}"
  }
}
