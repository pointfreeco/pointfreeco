import Css
import Foundation
import Html
import HtmlCssSupport
import Models
import Styleguide
import View

public func videoView(forEpisode episode: Episode, isEpisodeViewable: Bool) -> Node {
  let episodeSource = isEpisodeViewable
    ? episode.fullVideo.streamingSource
    : episode.trailerVideo?.streamingSource ?? ""

  return div(
    [
      `class`([outerVideoContainerClass]),
      style(outerVideoContainerStyle)
    ],
    episodeSource.hasPrefix("https://player.vimeo.com")
      ? [
        iframe(
          [
            `class`([innerVideoContainerClass]),
            src(episodeSource),
            Attribute("frameborder", "0"),
            Attribute("allow", "autoplay; fullscreen"),
            Attribute("allowfullscreen", "")
          ],
          [
          ]
        ),
        script([src("https://player.vimeo.com/api/player.js")]),
        script(
          """
window.addEventListener("load", function (event) {
  var player = new Vimeo.Player(document.querySelector("iframe"));

  jump(window.location.hash);

  document.addEventListener("click", function (event) {
    var target = event.target;
    if (target.tagName != "A") { return; }
    var hash = new URL(target.href).hash;
    jump(hash);
    player.play();
  });

  function jump(hash) {
    var time = +((/^#t(\\d+)$/.exec(hash) || [])[1] || "");
    if (time <= 0) { return; }
    player.setCurrentTime(time);
  }
});
"""
        )
        ]
      : [
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
              src: episodeSource,
              [type(.application(.init(rawValue: "vnd.apple.mpegurl")))]
            )
          ]
        ),
        script(
          """
var hasPlayed = false;
var video = document.getElementsByTagName("video")[0];
video.addEventListener("play", function () {
  hasPlayed = true;
});
document.addEventListener("keypress", function (event) {
  if (hasPlayed && event.key === " ") {
    if (video.paused) {
      video.play();
    } else {
      video.pause();
    }
    event.preventDefault();
  }
});
document.addEventListener("click", function (event) {
  var target = event.target;
  if (target.tagName != "A") { return; }
  var hash = new URL(target.href).hash;
  var time = +((/^#t(\\d+)$/.exec(hash) || [])[1] || "");
  if (time <= 0) { return; }
  var video = document.getElementsByTagName("video")[0];
  video.currentTime = time;
  video.play();
});
"""
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
