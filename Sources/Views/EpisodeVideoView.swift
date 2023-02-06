import Css
import Foundation
import Html
import HtmlCssSupport
import Models
import Styleguide

public func videoView(
  forEpisode episode: Episode,
  isEpisodeViewable: Bool,
  episodeProgress: Int?
) -> Node {
  let episodeSourceRoot =
    isEpisodeViewable
    ? episode.fullVideo.streamingSource
    : episode.trailerVideo.streamingSource

  let episodeSource =
    episodeSourceRoot
    + (episodeProgress.map { "#t=\(Int(Double(episode.length.rawValue * $0) / 100.0))s" } ?? "")

  return .div(
    attributes: [
      .class([outerVideoContainerClass]),
      .style(outerVideoContainerStyle),
      .id("episode-video"),
    ],
    .iframe(
      attributes: [
        .class([innerVideoContainerClass]),
        .src(episodeSource),
        Attribute("frameborder", "0"),
        Attribute("allow", "autoplay; fullscreen"),
        Attribute("allowfullscreen", ""),
      ]
    ),
    .script(attributes: [.async(true), .src("https://player.vimeo.com/api/player.js")]),
    .script(
      safe: """
        function isElementVisible(element) {
          var rect = element.getBoundingClientRect();
          var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
          return rect.bottom >= 0 && rect.top < viewHeight;
        }

        window.addEventListener("load", function (event) {
          const iframe = document.querySelector("iframe")
          const player = new Vimeo.Player(iframe)

          jump(window.location.hash, false);

          document.addEventListener("click", function (event) {
            const target = event.target
            const time = Number(target.dataset.timestamp)
            if (target.tagName != "A") { return }
            if (target.dataset.timestamp == undefined) { return }
            if (time < 0) { return }
            if (isElementVisible(iframe)) { event.preventDefault() }
            player.setCurrentTime(time)
            player.play()
          });

          function jump(hash, play) {
            var time = +((/^#t(\\d+)$/.exec(hash) || [])[1] || "")
            if (time <= 0) { return }
            player.setCurrentTime(time)
            if (play) { player.play() }
          }
        });
        """
    ),
    progressPollingScript(isEpisodeViewable: isEpisodeViewable)
  )
}

private func progressPollingScript(isEpisodeViewable: Bool) -> Node {
  isEpisodeViewable
    ? Node.script(
      safe: """
        window.addEventListener("load", function (event) {
          var player = new Vimeo.Player(document.querySelector("iframe"));

          var lastSeenPercent = 0
          player.on('timeupdate', function(data) {
            if (Math.abs(data.percent - lastSeenPercent) >= 0.01) {
              lastSeenPercent = data.percent;

              var httpRequest = new XMLHttpRequest();
              httpRequest.open(
                "POST",
                window.location.pathname + "/progress?percent=" + Math.round(data.percent * 100)
              );
              httpRequest.send();
            }
          });
        });
        """)
    : []
}
