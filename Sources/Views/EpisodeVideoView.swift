import Css
import Foundation
import Html
import HtmlCssSupport
import Models
import Styleguide
import View

public func videoView(forEpisode episode: Episode, isEpisodeViewable: Bool) -> Node {
  return div(
    [
      `class`([outerVideoContainerClass]),
      style(outerVideoContainerStyle)
    ],
    [
      video(
        [
          id("episode-video"),
          `class`([
            innerVideoContainerClass,
            videoJsClasses
            ]),
          style(position(.absolute)),
          controls(true),
          playsinline(true),
          autoplay(true),
          poster(episode.image),
          data("setup", VideoJsOptions.default.jsonString)
        ],
        [
          source(
            src: isEpisodeViewable
              ? episode.fullVideo.streamingSource
              : episode.trailerVideo?.streamingSource ?? "",
            [type(.application(.init(rawValue: "vnd.apple.mpegurl")))]
          )
        ]
      )
    ]
  )
}

private let videoJsClasses: CssSelector =
  ".video-js"
    | ".vjs-default-skin"
    | ".vjs-big-play-centered"

public struct VideoJsOptions: Encodable {
  let control: Bool
  let playbackRates: [Double]
  let playsinline: Bool

  static let `default` = VideoJsOptions(
    control: true,
    playbackRates: [1, 1.25, 1.5, 1.75, 2],
    playsinline: true
  )

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
private let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .sortedKeys
  return encoder
}()
