import Css
import Foundation
import Html
import HtmlCssSupport
import Optics
import Prelude

var videoJsHead: [ChildOf<Tag.Head>] {
  let videoJsAssets: [ChildOf<Tag.Head>] = [
    link([
      href("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.3.0/alt/video-js-cdn.min.css"),
      rel(.stylesheet)
      ]),
    .init(script([
      onload("videoJsLoaded()"),
      src("https://cdnjs.cloudflare.com/ajax/libs/video.js/7.3.0/video.min.js"),
      `defer`(true)
      ]))
  ]

  return [
    style(".vjs-subs-caps-button" % display(.none)),
    .init(.element("script", [], [.raw("""
window.HELP_IMPROVE_VIDEOJS = false

function videoJsLoaded() {
  video.addEventListener('webkitplaybacktargetavailabilitychanged', function(event) {
    if (event.availability != "available") { return }

    videojs("episode-video").ready(function() {
      var existingAirplayControl = document.getElementsByClassName('vjs-airplay-control')
      if (existingAirplayControl.length != 0) { return }

      var controlBar = document.getElementsByClassName('vjs-control-bar')[0]
      var video = document.getElementsByTagName('video')[0]

      var template = document.createElement('div')
      template.innerHTML = '\(render(airplayButton))'

      controlBar.insertBefore(template.firstChild, controlBar.childNodes[controlBar.childNodes.length - 1])

      var airplayControl = document.getElementsByClassName('vjs-airplay-control')[0]
      airplayControl.addEventListener('click', function() {
        video.webkitShowPlaybackTargetPicker()
      })
    })
  })
}
""")]))
    ]
    + (Current.envVars.appEnv == .testing ? [] : videoJsAssets)
}

let airplayButton = button(
  [
    `class`("vjs-airplay-control vjs-control vjs-button"),
    type(.button),
    title("AirPlay")
  ],
  [
    img(
      base64: airplaySvgBase64,
      type: .image(.svg),
      alt: "AirPlay",
      [style(verticalAlign(.middle))]
    )
  ]
)

let videoJsClasses: CssSelector =
  ".video-js"
    | ".vjs-default-skin"
    | ".vjs-big-play-centered"

struct VideoJsOptions: Encodable {
  let control: Bool
  let playbackRates: [Double]

  static let `default` = VideoJsOptions(control: true, playbackRates: [1, 1.25, 1.5, 1.75, 2])

  var jsonString: String {
    if #available(OSX 10.13, *) {
      return ((try? String(data: jsonEncoder.encode(VideoJsOptions.default), encoding: .utf8)) ?? nil)
        ?? "{}"
    } else {
      return ((try? String(data: JSONEncoder().encode(VideoJsOptions.default), encoding: .utf8)) ?? nil)
        ?? "{}"
    }
  }
}

@available(OSX 10.13, *)
private let jsonEncoder = JSONEncoder()
  |> \.outputFormatting .~ .sortedKeys
