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
        window.addEventListener("load", function (event) {
          var player = new Vimeo.Player(document.querySelector("iframe"));

          jump(window.location.hash, false);

          document.addEventListener("click", function (event) {
            var target = event.target;
            if (target.tagName != "A") { return; }
            var hash = new URL(target.href).hash;
            jump(hash, true);
          });

          function jump(hash, play) {
            var time = +((/^#t(\\d+)$/.exec(hash) || [])[1] || "");
            if (time <= 0) { return; }
            player.setCurrentTime(time);
            if (play) { player.play(); }
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
