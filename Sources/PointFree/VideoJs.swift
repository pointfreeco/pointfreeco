import Css
import Foundation
import Html
import HtmlCssSupport

var videoJsHead: [ChildOf<Element.Head>] {
  let videoJsAssets: [ChildOf<Element.Head>] = [
    link([
      href("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/alt/video-js-cdn.min.css"),
      rel(.stylesheet)
      ]),
    .init(script([
      src("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.2.4/video.min.js"),
      `defer`(true)
      ]))
  ]

  return [
    style(".vjs-subs-caps-button" % display(.none)),
    script("window.HELP_IMPROVE_VIDEOJS = false;")
    ]
    + (Current.envVars.appEnv == .testing ? [] : videoJsAssets)
}

let videoJsClasses: CssSelector =
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
